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
        self.backgroundColor = SKColor.whiteColor()
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
        
        
        /* places phages on the screen */
        let phageBlue = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! * 0.1), team: "Blue")
        let phageRed = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! * 0.9), team: "Red")
        let phageGray1 = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 4, y: (scene?.frame.size.height)! / 2), team: "Gray")
        let phageGray2 = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2), team: "Gray")
        let phageGray3 = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! * 0.75, y: (scene?.frame.size.height)! / 2), team: "Gray")
        self.addChild(phageBlue)
        self.addChild(phageBlue.strengthLabel)
        self.addChild(phageRed)
        self.addChild(phageRed.strengthLabel)
        self.addChild(phageGray1)
        self.addChild(phageGray1.strengthLabel)
        self.addChild(phageGray2)
        self.addChild(phageGray2.strengthLabel)
        self.addChild(phageGray3)
        self.addChild(phageGray3.strengthLabel)
        ///print(self.children)
    }
    var senderPhage: Phage?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let startLocation = touch.locationInNode(self)
            
            if let selectedPhage = nodeAtPoint(startLocation) as? Phage {
                senderPhage = selectedPhage
            }
            else {
                senderPhage = nil
            }
            
            /*let sprite = Phage(coordinate: location, team: "Blue")
            
            //How can we put this inside the Phage class?
            self.addChild(sprite)
            self.addChild(sprite.strengthLabel)*/
            
            /*
            self.addChild(sprite)
            
            let strengthLabel = SKLabelNode(fontNamed: "Arial")
            sprite.strengthLabel = strengthLabel
            strengthLabel.fontSize = CGFloat(sprite.strength/2)
            strengthLabel.fontColor = UIColor.blackColor()
            strengthLabel.position = CGPoint(x:CGRectGetMidX(sprite.frame), y:CGRectGetMidY(sprite.frame))
            //strengthLabel.position = labelLocation(sprite.coordinate, size: sprite.size)
            strengthLabel.zPosition = 1
            strengthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            strengthLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center

            let actionwait = SKAction.waitForDuration(1.0)
            // increment timer
            let actionrun = SKAction.runBlock({
                sprite.strengthLabel.text = String(sprite.strength)
                sprite.strength++
            })
            // repeats sequence forever
            sprite.strengthLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionrun,actionwait])))
            // add node to scene
*/
        }
    }
    
    
    func calculateDistance(start: CGPoint, end: CGPoint) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return Double(sqrt(dx * dx + dy * dy))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            if let startNode = senderPhage {
                guard(startNode.strength != 0) else {return} //checks case for shooting
                let endLocation = touch.locationInNode(self)
                if let endNode = nodeAtPoint(endLocation) as? Phage {
                    let bullet = Bullet(shooter: startNode)
                    bullet.position = startNode.position
                    self.addChild(bullet)
                    let moveToDestination = SKAction.moveTo(endNode.position, duration: NSTimeInterval(calculateDistance(startNode.position, end: endNode.position)))
                    bullet.runAction(moveToDestination)
                }
            }
        }
    }
   /*
    func labelLocation(phageCoordinate: CGPoint, size: CGSize) -> CGPoint {
        let x = phageCoordinate.x
        var y = phageCoordinate.y
        y = y - size.height * 0.15
        let newPoint: CGPoint = CGPoint(x: x, y: y)
        return newPoint
    }
    */
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
