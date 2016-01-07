//
//  Bullet.swift
//  Battleship
//
//  Created by Sean Hudson on 1/6/16.
//  Copyright © 2016 Sean Hudson. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    let strength: Int
    
    init(shooter: Phage) {
        strength = shooter.transferStrength()
        super.init(texture: SKTexture(imageNamed: "phage"), color: shooter.color, size: shooter.getSize(strength))
        self.colorBlendFactor = 1.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}