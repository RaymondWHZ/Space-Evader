//
//  File.swift
//  SpaceEvader
//
//  Created by iD Student on 7/19/17.
//  Copyright © 2017 iD Student. All rights reserved.
//

import SpriteKit

class Enemy: SKSpriteNode {
    
    init(_ imageNamed: String) {
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
