//
//  GameScene.swift
//  Battleship
//
//  Created by Sean Hudson on 12/30/15.
//  Copyright (c) 2015 Sean Hudson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        
        /* timer */
        // setup
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 45
        scoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        // wait one second between each increment
        let actionwait = SKAction.waitForDuration(1.0)
        var timesecond = Int()
        // increment timer
        let actionrun = SKAction.runBlock({
            timesecond++
            scoreLabel.text = String(timesecond)
        })
        // repeats sequence forever
        scoreLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionwait,actionrun])))
        // add node to scene
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = Phage(coordinate: location, team: "Blue")
            self.addChild(sprite)
            
            let strengthLabel = SKLabelNode(fontNamed: "Arial")
            
            sprite.strengthLabel = strengthLabel
            strengthLabel.fontSize = CGFloat(sprite.strength/2)
            strengthLabel.fontColor = UIColor.blackColor()
            strengthLabel.position = CGPoint(x:CGRectGetMidX(sprite.frame), y:CGRectGetMidY(sprite.frame))
            strengthLabel.position = labelLocation(sprite.coordinate, size: sprite.size)
            strengthLabel.zPosition = 1

            let actionwait = SKAction.waitForDuration(1.0)
            // increment timer
            let actionrun = SKAction.runBlock({
                strengthLabel.text = String(sprite.strength)
                sprite.strength++
                /*if let strengthString = strengthLabel.text, strength = Int(strengthString) {
                    sprite.strength = strength
                }*/
            })
            // repeats sequence forever
            strengthLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionrun,actionwait])))
            // add node to scene
            self.addChild(strengthLabel)
            
        }
    }
   
    func labelLocation(phageCoordinate: CGPoint, size: CGSize) -> CGPoint {
        let x = phageCoordinate.x
        var y = phageCoordinate.y
        y = y - size.height * 0.15
        let newPoint: CGPoint = CGPoint(x: x, y: y)
        return newPoint
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
