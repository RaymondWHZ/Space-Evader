//
//  GameScene.swift
//  SpaceEvader
//
//  Created by iD Student on 7/18/17.
//  Copyright © 2017 iD Student. All rights reserved.
//

import SpriteKit
import GameplayKit

struct BodyType{
    static let None: UInt32 = 0
    static let Meteor: UInt32 = 1
    static let Bullet: UInt32 = 2
    static let Hero: UInt32 = 4
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
    
    var enemies = [Enemy]()
    var enemyHealth = 1
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        
        let xCoord = size.width * 0.5
        let yCoord = size.height * 0.5
        
        hero.size.height = 50
        hero.size.width = 50
        
        hero.position = CGPoint(x: xCoord, y: yCoord)
        
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
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        physicsWorld.gravity = CGVector(dx:0,dy:0)
        physicsWorld.contactDelegate = self
        
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height-50)
        
        addChild(scoreLabel)
        scoreLabel.text = "0"
        
        levelLabel.fontColor = UIColor.yellow
        levelLabel.fontSize = 20
        levelLabel.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.9)
        
        addChild(levelLabel)
        levelLabel.text = "Level: 1"
        
        addEnemies()
    }
    
    func addEnemies(){
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMeteor), SKAction.wait(forDuration: 1.0)])), withKey:"addEnemies")
    }
    
    func stopEnemies(){
        for enemy in enemies {
            explodeEnemy(meteor: enemy)
        }
        removeAction(forKey: "addEnemies")
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
    
    func addMeteor(){
        let meteor=Enemy("Fire")
        meteor.size.height=35
        meteor.size.width=50
        
        let randomY = random() * (size.height - meteor.size.height) + meteor.size.height/2
        meteor.position = CGPoint(x:size.width + meteor.size.width, y:randomY)
        
        meteor.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        meteor.physicsBody?.isDynamic = true
        meteor.physicsBody?.categoryBitMask = BodyType.Meteor
        meteor.physicsBody?.contactTestBitMask = BodyType.Bullet
        meteor.physicsBody?.collisionBitMask = 0
        
        addChild(meteor)
        enemies.append(meteor)
        
        let moveAction = SKAction.move(to: CGPoint(x: -meteor.size.width/2, y: randomY), duration: 5.0)
        meteor.run(SKAction.sequence([moveAction,SKAction.removeFromParent()]))
    }
    
    func random()->CGFloat{
       return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
            if self.died{
                return
            }
            
            let bullet = SKSpriteNode()
            bullet.color = .green
            bullet.size = CGSize(width:5,height:5)
            bullet.position = self.hero.position
            
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
            bullet.physicsBody?.isDynamic = true
            bullet.physicsBody?.categoryBitMask = BodyType.Bullet
            bullet.physicsBody?.contactTestBitMask = BodyType.Meteor
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(bullet)
            
            guard let touch = touches.first else { return }
            let touchLocation = touch.location(in: self)
            let vector = CGVector(dx: -(self.hero.position.x - touchLocation.x), dy: -(self.hero.position.y - touchLocation.y))
            
            var actionMove: SKAction
            actionMove = SKAction.sequence([
                SKAction.repeat(SKAction.move(by: vector, duration: 0.5), count:10),SKAction.removeFromParent()
                ])
            bullet.run(actionMove)
        }), SKAction.wait(forDuration: 0.1)])), withKey: "Shooting")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAction(forKey: "Shooting")
    }
    
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
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
        var actionMove: SKAction
        if hero.position.x - heroSpeed <= hero.size.width/2{
            actionMove = SKAction.move(to: CGPoint(x: hero.size.width/2, y: hero.position.y), duration: 0.5)
        }else{
            actionMove = SKAction.move(to: CGPoint(x: hero.position.x - heroSpeed, y: hero.position.y), duration: 0.5)
        }
        hero.run(actionMove)
    }
    
    func swipedRight(sender:UISwipeGestureRecognizer){
        var actionMove: SKAction
        if hero.position.x + heroSpeed >= size.width-hero.size.width/2{
            actionMove = SKAction.move(to: CGPoint(x: size.width + hero.size.width/2, y: hero.position.y), duration: 0.5)
        }else{
            actionMove = SKAction.move(to: CGPoint(x: hero.position.x + heroSpeed, y: hero.position.y), duration: 0.5)
        }
        hero.run(actionMove)
    }
    
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
                    heroHitMeteor(player: bodyBNode, meteor: bodyANode)
                }
            default:
                break
            }
        case BodyType.Bullet:
            switch contactB {
            case BodyType.Meteor:
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? Enemy {
                    bulletHitMeteor(bullet: bodyANode, meteor: bodyBNode)
                }
            default:
                break
            }
        case BodyType.Hero:
            switch contactB {
            case BodyType.Meteor:
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? Enemy {
                    heroHitMeteor(player: bodyANode, meteor: bodyBNode)
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func bulletHitMeteor(bullet:SKSpriteNode, meteor:Enemy){
        meteorScore+=1
        scoreLabel.text = "\(meteorScore)"
        
        checkLevelIncrease()
        
        if let meteorIndex = enemies.index(of: meteor) {
            enemies.remove(at: meteorIndex)
        }
        
        explodeEnemy(meteor: meteor)
        bullet.removeFromParent()
    }
    
    func explodeEnemy(meteor:Enemy){
        let explosions:[SKSpriteNode] = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
        
        for explosion in explosions{
            explosion.color = .orange
            explosion.size = CGSize(width: 3, height: 3)
            explosion.position = meteor.position
            
            let randomExplosionX = (random() * (1000 + size.width)) - size.width
            let randomExplosionY = (random() * (1000 + size.height)) - size.height
            
            let moveExplosion = SKAction.move(to: CGPoint(x: randomExplosionX, y: randomExplosionY), duration: 10.0)
            explosion.run(SKAction.sequence([moveExplosion, SKAction.removeFromParent()]))
            
            addChild(explosion)
        }
        
        meteor.removeFromParent()
    }
    
    func heroHitMeteor(player:SKSpriteNode, meteor:Enemy){
        player.removeFromParent()
        meteor.removeFromParent()
        died=true
        
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        addChild(gameOverLabel)
    }
    
    
}
