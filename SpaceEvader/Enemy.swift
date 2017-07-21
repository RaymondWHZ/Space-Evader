//
//  File.swift
//  SpaceEvader
//
//  Created by iD Student on 7/19/17.
//  Copyright © 2017 iD Student. All rights reserved.
//

import SpriteKit

class Enemy: SKSpriteNode {
    
    var life:Int
    
    init(_ imageNamed: String, life:Int) {
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        self.life=life
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
