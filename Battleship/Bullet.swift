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
    static var bulletCount = 0
    let strength: Int
    let team: String
    let senderName: String?
    let bulletSpeed: Double
    
    init(shooter: Phage) {
        strength = shooter.transferStrength()
        team = shooter.team
        senderName = shooter.name
        bulletSpeed = shooter.bulletSpeed
        super.init(texture: SKTexture(imageNamed: "phage"), color: shooter.color, size: shooter.getSize(strength))
        self.colorBlendFactor = 1.0
        self.zPosition = GameScene.zPositions.bullet
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = GameScene.bitMasks.bullet
        self.physicsBody?.collisionBitMask = GameScene.bitMasks.none
        self.physicsBody?.contactTestBitMask = (GameScene.bitMasks.blue | GameScene.bitMasks.red | GameScene.bitMasks.gray)        

        Bullet.bulletCount++
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Bullet.bulletCount--
//        print("Bullet was deleted")
    }
    
   /* func escapeSelf() {
        let waitRadius = SKAction.waitForDuration(NSTimeInterval(self.size.width + 3 / CGFloat(bulletSpeed)))
        let changeBitMask = SKAction.runBlock({
            self.physicsBody?.categoryBitMask = GameScene.bitMasks.bullet
            self.physicsBody?.contactTestBitMask = (GameScene.bitMasks.blue | GameScene.bitMasks.red | GameScene.bitMasks.gray)
        })
        let escapeSequence = SKAction.sequence([waitRadius, changeBitMask])
        runAction(escapeSequence)
    }*/
}