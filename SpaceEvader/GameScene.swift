//
//  GameScene.swift
//  SpaceEvader
//
//  Created by iD Student on 7/18/17.
//  Copyright © 2017 iD Student. All rights reserved.
//

import SpriteKit
import GameplayKit

//used in collisions
struct BodyType{
    static let None: UInt32 = 0
    static let Meteor: UInt32 = 1
    static let Rock: UInt32 = 2
    static let Bullet: UInt32 = 3
    static let Hero: UInt32 = 4
}

struct Level{
    var enemyPassSecond:Double
    var enemyLife:Int
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let hero = SKSpriteNode(imageNamed: "Spaceship")
    let heroSpeed: CGFloat = 100.0
    
    var meteorScore = 0
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    
    var died = false
    
    var level = 1
    var levelLabel = SKLabelNode(fontNamed: "Arial")
    var levelLimit = 5
    var levelIncrease = 5
    
    let gameOverLabel = SKLabelNode(fontNamed: "Arial")
    let restartLabel = SKLabelNode(fontNamed: "Arial")
    
    var enemies = [Enemy]()
    
    var levels:[Level] = []
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        addStar()
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addStar), SKAction.wait(forDuration: 0.3)])))
        
        let xCoord = size.width * 0.2
        let yCoord = size.height * 0.5
        
        hero.size = CGSize(width: 50, height: 50)
        hero.position = CGPoint(x: xCoord, y: yCoord)
        
        //setup physical body of the hero
        hero.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.categoryBitMask = BodyType.Hero
        hero.physicsBody?.contactTestBitMask = BodyType.Meteor
        hero.physicsBody?.collisionBitMask = 0
        
        addChild(hero)
        
        //Gesture Recognizers
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        //it's in space!!!
        physicsWorld.gravity = CGVector(dx:0,dy:0)
        physicsWorld.contactDelegate = self
        
        //score board
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height-50)
        
        addChild(scoreLabel)
        scoreLabel.text = "0"
        
        //level
        levelLabel.fontColor = UIColor.yellow
        levelLabel.fontSize = 20
        levelLabel.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.9)
        
        addChild(levelLabel)
        levelLabel.text = "Level: 1"
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        restartLabel.text = "Start again!"
        restartLabel.fontColor = UIColor.green
        restartLabel.fontSize = 25
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2-100)
        
        addEnemies()
    }
    
    func addStar(){
        let star=SKSpriteNode()
        star.color = .white
        star.size = CGSize(width: 1,height: 1)
        
        let randomY = random() * (size.height - star.size.height) + star.size.height/2
        star.position = CGPoint(x:size.width + star.size.width, y:randomY)
        
        addChild(star)
        
        let moveAction = SKAction.move(to: CGPoint(x: -star.size.width/2, y: randomY), duration: TimeInterval(3*random()+2))
        star.run(SKAction.sequence([moveAction,SKAction.removeFromParent()]))
    }
    
    //game start
    func addEnemies(){
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMeteor), SKAction.wait(forDuration: 1.0)])), withKey:"Enemies")
        if(level>2){
            var interval = 12.0
            for _ in 1...level-2{
                interval /= 5
                interval *= 4
            }
            run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addRock), SKAction.wait(forDuration: interval)])),withKey:"Rocks")
        }
    }
    
    //game stop
    func stopEnemies(){
        for enemy in enemies {
            explodeEnemy(meteor: enemy)
        }
        removeAction(forKey: "Enemies")
        removeAction(forKey: "Rocks")
        enemies = [Enemy]()
    }
    
    func increaselevel(){
        levelLimit = levelLimit + levelIncrease
        level += 1
        levelLabel.text = "Level: \(level)"
    }
    
    func checkLevelIncrease() {
        if meteorScore >= levelLimit {
            let runEnemies = SKAction.sequence([SKAction.run(stopEnemies), SKAction.run(increaselevel), SKAction.wait(forDuration: 3.0), SKAction.run(addEnemies)])
            run(runEnemies)
        }
    }
    
    //add an enemy
    func addMeteor(){
        let meteor=Enemy("Fire", life:level/2)
        meteor.size.height=35
        meteor.size.width=50
        
        let randomY = random() * (size.height - meteor.size.height) + meteor.size.height/2
        meteor.position = CGPoint(x:size.width + meteor.size.width, y:randomY)
        
        meteor.physicsBody = SKPhysicsBody(rectangleOf: meteor.size)
        meteor.physicsBody?.isDynamic = true
        meteor.physicsBody?.categoryBitMask = BodyType.Meteor
        meteor.physicsBody?.contactTestBitMask = BodyType.Bullet | BodyType.Rock
        meteor.physicsBody?.collisionBitMask = 0
        
        addChild(meteor)
        enemies.append(meteor)
        
        let moveAction = SKAction.move(to: CGPoint(x: -meteor.size.width/2, y: randomY), duration: 5.0)
        meteor.run(SKAction.sequence([moveAction,SKAction.removeFromParent()]))
    }
    
    //add a rock
    func addRock(){
        let rock = SKSpriteNode(texture: SKTexture(imageNamed: "Rock"))
        rock.size.height=100
        rock.size.width=100
        
        let randomY = random() * (size.height - rock.size.height) + rock.size.height/2
        rock.position = CGPoint(x:size.width + rock.size.width, y:randomY)
        
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.isDynamic = true
        rock.physicsBody?.categoryBitMask = BodyType.Rock
        rock.physicsBody?.contactTestBitMask = BodyType.Hero | BodyType.Bullet | BodyType.Meteor
        rock.physicsBody?.collisionBitMask = 0
        
        addChild(rock)
        
        let moveAction = SKAction.move(to: CGPoint(x: -rock.size.width/2, y: randomY), duration: 3.0)
        rock.run(SKAction.sequence([moveAction,SKAction.removeFromParent()]))
    }
    
    //random tool
    func random()->CGFloat{
       return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if self.died{
            
            let maxX = touchLocation.x<restartLabel.position.x+80
            let minX = touchLocation.x>restartLabel.position.x-80
            let maxY = touchLocation.y<restartLabel.position.y+20
            let minY = touchLocation.y>restartLabel.position.y-20
            
            if !maxX || !minX || !maxY || !minY{
                return
            }
            
            //restart
            removeAllChildren()
            
            level=1
            levelLabel.text = "Level: 1"
            levelLimit=5
            meteorScore=0
            scoreLabel.text = "0"
            
            hero.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
            
            addChild(hero)
            
            addChild(scoreLabel)
            addChild(levelLabel)
            died=false
            checkLevelIncrease()
            
            removeAction(forKey: "Rocks")
            
            return
        }
        
        //shoot
        let bullet = SKSpriteNode()
        bullet.color = .yellow
        bullet.size = CGSize(width:5,height:5)
        bullet.position = self.hero.position
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = BodyType.Bullet
        bullet.physicsBody?.contactTestBitMask = BodyType.Meteor | BodyType.Rock
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let vector = CGVector(dx: -(self.hero.position.x - touchLocation.x), dy: -(self.hero.position.y - touchLocation.y))
        let distance = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        
        var actionMove: SKAction
        actionMove = SKAction.sequence([SKAction.repeat(SKAction.move(by: vector, duration: TimeInterval(distance/500)), count:10), SKAction.removeFromParent()])
        bullet.run(actionMove)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //moving part{

    func swipedUp(sender:UISwipeGestureRecognizer){
        var actionMove: SKAction
        if hero.position.y + heroSpeed >= size.height - hero.size.height/2{
            actionMove = SKAction.move(to: CGPoint(x: hero.position.x, y: size.height - hero.size.height/2), duration: 0.5)
        }
        else{
            actionMove = SKAction.move(to: CGPoint(x: hero.position.x, y: hero.position.y + heroSpeed), duration: 0.5)
        }
        hero.run(actionMove)
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        var actionMove: SKAction
        if hero.position.y - heroSpeed <= hero.size.height/2{
            actionMove = SKAction.move(to: CGPoint(x: hero.position.x, y: hero.size.height/2), duration: 0.5)
        }else{
            actionMove = SKAction.move(to: CGPoint(x: hero.position.x, y: hero.position.y - heroSpeed), duration: 0.5)
        }
        hero.run(actionMove)
    }
    
    //}
    
    //collision handler{
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let contactA = bodyA.categoryBitMask
        let contactB = bodyB.categoryBitMask
        
        switch contactA {
            
        case BodyType.Meteor:
            switch contactB {
            case BodyType.Bullet:
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? Enemy {
                    bulletHitMeteor(bullet: bodyBNode, meteor: bodyANode)
                }
            case BodyType.Hero:
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? Enemy {
                    heroGetHit(player: bodyBNode)
                    explodeEnemy(meteor: bodyANode)
                }
            case BodyType.Rock:
                if let bodyANode = contact.bodyA.node as? Enemy {
                    explodeEnemy(meteor: bodyANode)
                }
            default:
                break
            }
        case BodyType.Rock:
            switch contactB {
            case BodyType.Meteor:
                if let bodyBNode = contact.bodyB.node as? Enemy {
                    if let meteorIndex = enemies.index(of: bodyBNode) {
                        enemies.remove(at: meteorIndex)
                    }
                    
                    explodeEnemy(meteor: bodyBNode)
                }
                
            case BodyType.Hero:
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode{
                    heroGetHit(player: bodyBNode)
                }
            case BodyType.Bullet:
                contact.bodyB.node?.removeFromParent()
            default:
                break
            }
        case BodyType.Bullet:
            switch contactB {
            case BodyType.Meteor:
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? Enemy {
                    bulletHitMeteor(bullet: bodyANode, meteor: bodyBNode)
                }
            case BodyType.Rock:
                contact.bodyA.node?.removeFromParent()
            default:
                break
            }
        case BodyType.Hero:
            switch contactB {
            case BodyType.Meteor:
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? Enemy {
                    heroGetHit(player: bodyANode)
                    explodeEnemy(meteor: bodyBNode)
                }
            case BodyType.Rock:
                if let bodyANode = contact.bodyA.node as? SKSpriteNode{
                    heroGetHit(player: bodyANode)
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func bulletHitMeteor(bullet:SKSpriteNode, meteor:Enemy){
        meteor.life-=1
        if meteor.life>0{
            let spark = SKSpriteNode()
            spark.color = .orange
            spark.size = CGSize(width: 3, height: 3)
            spark.position = meteor.position
            
            let randomExplosionX = (random() * (1900 + size.width)) - size.width
            let randomExplosionY = (random() * (1000 + size.height)) - size.height
            
            let moveExplosion = SKAction.move(to: CGPoint(x: randomExplosionX, y: randomExplosionY), duration: 5.0)
            spark.run(SKAction.sequence([moveExplosion, SKAction.removeFromParent()]))
            
            addChild(spark)
            bullet.removeFromParent()
        }
        else{
            meteorScore+=1
            scoreLabel.text = "\(meteorScore)"
            
            checkLevelIncrease()
            
            if let meteorIndex = enemies.index(of: meteor) {
                enemies.remove(at: meteorIndex)
            }
            
            explodeEnemy(meteor: meteor)
            bullet.removeFromParent()
        }
    }
    
    func explodeEnemy(meteor:Enemy){
        for _ in 0...5{
            let explosion = SKSpriteNode()
            explosion.color = .orange
            explosion.size = CGSize(width: 3, height: 3)
            explosion.position = meteor.position
            
            let randomExplosionX = (random() * (100 + size.width)) - size.width
            let randomExplosionY = (random() * (1000 + size.height)) - size.height
            
            let moveExplosion = SKAction.move(to: CGPoint(x: randomExplosionX, y: randomExplosionY), duration: 5.0)
            explosion.run(SKAction.sequence([moveExplosion, SKAction.removeFromParent()]))
            
            addChild(explosion)
        }
        
        meteor.removeFromParent()
    }
    
    func heroGetHit(player:SKSpriteNode){
        player.removeFromParent()
        died=true
        
        for _ in 0...99{
            let explosion = SKSpriteNode()
            explosion.color = .orange
            explosion.size = CGSize(width: 3, height: 3)
            explosion.position = player.position
            
            let randomExplosionX = (random() * (100 + size.width)) - size.width
            let randomExplosionY = (random() * (1000 + size.height)) - size.height
            
            let moveExplosion = SKAction.move(to: CGPoint(x: randomExplosionX, y: randomExplosionY), duration: 10.0)
            explosion.run(SKAction.sequence([moveExplosion, SKAction.removeFromParent()]))
            
            addChild(explosion)
        }
        
        addChild(gameOverLabel)
        addChild(restartLabel)
    }
    
    //}
}
