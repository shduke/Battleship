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
        /* Setup your scene here */
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello World!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel);
        
        /* timer */
        // setup
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 45;
        scoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        // wait one second between each increment
        let actionwait = SKAction.waitForDuration(1.0)
        var timesecond = Int()
        // increment timer
        let actionrun = SKAction.runBlock({
            timesecond++
            scoreLabel.text = String(timesecond);
        })
        // repeats sequence forever
        scoreLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionwait,actionrun])))
        // add node to scene
        self.addChild(scoreLabel);
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = Phage(coordinate: location, size: CGSize(width: 100, height: 100), rechargeTime: 10)
            self.addChild(sprite)
            let strengthLabel = SKLabelNode(fontNamed: "Chalkduster")
            strengthLabel.fontSize = 45;
            strengthLabel.color = UIColor.blackColor()
            strengthLabel.position = sprite.coordinate;
            strengthLabel.text = String(sprite.strength);
            // add node to scene
            self.addChild(strengthLabel);
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
