//
//  GameScene.swift
//  Battleship
//
//  Created by Sean Hudson on 12/30/15.
//  Copyright (c) 2015 Sean Hudson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var score = 0
    var viewController: UIViewController?
    var time = 0
    var timer: NSTimer?
    var level = 1
    
    /* in game display */
    var scoreLabel: SKLabelNode?
    var levelLabel: SKLabelNode?
    var pauseButton: SKSpriteNode?
    
    /* pause menu */
    var grayOut: SKShapeNode?
    var whiteOutline: SKShapeNode?
    var menuLabel: SKLabelNode?
    var restartLabel: SKLabelNode?
    var resumeLabel: SKLabelNode?

    var nextLevel: SKLabelNode?
    
    struct bitMasks {
        static let none : UInt32 = 0x0
        static let blue : UInt32 = 0x1 << 0 //same team
        static let red : UInt32 = 0x1 << 1  //other team
        static let gray : UInt32 = 0x1 << 2 //neutral
        static let bullet : UInt32 = 0x1 << 3
       // static let ownself : UInt32 = 0x1 << 31
    }
    
    struct zPositions {
        static let bullet: CGFloat = 90
        static let phage: CGFloat = 100
        static let label: CGFloat = 110
        static let pausedTint: CGFloat = 200
        static let whiteOutline: CGFloat = 210
        static let pausedLabel: CGFloat = 220
    }
    
    func updateTimer() {
        time++
        scoreLabel?.text = String(time)
    }
    
    override func didMoveToView(view: SKView) {
        /* initializes the game board */
        gameBoard()
        ///print(self.children)
    }
    
    func gameBoard() {
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.whiteColor()
        winFlag = false
        /* timer-score Label */
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel?.fontSize = 30
        scoreLabel?.position = CGPoint(x:CGRectGetMidX(self.frame), y: (scene?.frame.size.height)! * 1.0)
        scoreLabel?.fontColor = UIColor.darkGrayColor()
        scoreLabel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        scoreLabel?.zPosition = zPositions.label
        scoreLabel?.text = String(time)
        self.addChild(scoreLabel!)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        self.paused = false
        
        /* level label */
        levelLabel = SKLabelNode(fontNamed: "Arial")
        levelLabel?.fontSize = 30
        levelLabel?.position = CGPoint(x: (scene?.frame.size.width)!, y: (scene?.frame.size.height)! * 1.0)
        levelLabel?.fontColor = UIColor.darkGrayColor()
        levelLabel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        levelLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        levelLabel?.zPosition = zPositions.label
        levelLabel?.text = "Level \(level)"
        print(levelLabel?.frame)
        self.addChild(levelLabel!)
        
        /* pause label */
        print(scoreLabel?.frame.width)
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "pause"))
        pauseButton?.size = CGSize(width: (levelLabel?.frame.size.height)!, height: (levelLabel?.frame.size.height)!)
        pauseButton?.position = CGPoint(x: 0, y: (scene?.frame.size.height)! * 1.0)
        pauseButton?.anchorPoint = CGPoint(x: 0, y: 1)
        pauseButton?.zPosition = zPositions.label
        pauseButton?.color = UIColor.darkGrayColor()
        pauseButton?.colorBlendFactor = 1.0
        pauseButton?.name = "pause"
        self.addChild(pauseButton!)
        
        /* places phages */
        let phageBlue = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! * 0.1), team: "Blue")
        let phageRed = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! * 0.87), team: "Red")
        let phageGray1 = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 4, y: (scene?.frame.size.height)! / 2), team: "Gray")
        let phageGray2 = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2), team: "Gray")
        let phageGray3 = Phage(coordinate: CGPoint(x: (scene?.frame.size.width)! * 0.75, y: (scene?.frame.size.height)! / 2), team: "Gray")
        self.addChild(phageBlue)
        self.addChild(phageBlue.strengthLabel!)
        self.addChild(phageRed)
        self.addChild(phageRed.strengthLabel!)
        self.addChild(phageGray1)
        self.addChild(phageGray1.strengthLabel!)
        self.addChild(phageGray2)
        self.addChild(phageGray2.strengthLabel!)
        self.addChild(phageGray3)
        self.addChild(phageGray3.strengthLabel!)
    }
    
    /* collision tree (Kind of like not being able to pass over nodes, to fix add reciever instance var to bullet and another gaurd statement)*/
    func didBeginContact(contact: SKPhysicsContact) {
        /* Checks for bullet and bluePhage collision */
        if (contact.bodyA.categoryBitMask == bitMasks.blue && contact.bodyB.categoryBitMask == bitMasks.bullet) {
            if let bullet = contact.bodyB.node as? Bullet {
                let teamBullet = bullet.team
                if let bluePhage = contact.bodyA.node as? Phage {
                    guard(bullet.senderName != bluePhage.name) else {return}
                    switch teamBullet {
                    case "Blue":
                        //bluePhage.strengthLabel.text? = String(bluePhage.strength + bullet.strength)
                        let sumStrength = bluePhage.strength + bullet.strength
                        if(sumStrength > bluePhage.maxCap) {
                            bluePhage.strength = bluePhage.maxCap
                        }
                        else {
                            bluePhage.strength = sumStrength
                        }
                    case "Red":
                        bluePhage.strengthLabel?.text? = String(bluePhage.strength - bullet.strength)
                        bluePhage.strength -= bullet.strength
                        if(bluePhage.strength < 0) {
                            bluePhage.strengthLabel?.removeFromParent()
                            bluePhage.removeFromParent()
                            let newPhage = Phage(coordinate: bluePhage.coordinate, team: "Red")
                            newPhage.strength = abs(bluePhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    default:
                        return
                    }
                }
                bullet.removeFromParent()
            }
        }
        else if (contact.bodyA.categoryBitMask == bitMasks.bullet && contact.bodyB.categoryBitMask == bitMasks.blue) {
            if let bullet = contact.bodyA.node as? Bullet {
                let teamBullet = bullet.team
                if let bluePhage = contact.bodyB.node as? Phage {
                    guard(bullet.senderName != bluePhage.name) else {return}
                    switch teamBullet {
                    case "Blue":
                        //bluePhage.strengthLabel.text? = String(bluePhage.strength + bullet.strength)
                        let sumStrength = bluePhage.strength + bullet.strength
                        if(sumStrength > bluePhage.maxCap) {
                            bluePhage.strength = bluePhage.maxCap
                        }
                        else {
                            bluePhage.strength = sumStrength
                        }
                    case "Red":
                        bluePhage.strengthLabel?.text? = String(bluePhage.strength - bullet.strength)
                        bluePhage.strength -= bullet.strength
                        if(bluePhage.strength < 0) {
                            bluePhage.strengthLabel?.removeFromParent()
                            bluePhage.removeFromParent()
                            let newPhage = Phage(coordinate: bluePhage.coordinate, team: "Red")
                            newPhage.strength = abs(bluePhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    default:
                        return
                    }
                }
                bullet.removeFromParent()
            }
        }
        
        /* Checks for bullet and redPhage collision */
        else if (contact.bodyA.categoryBitMask == bitMasks.red && contact.bodyB.categoryBitMask == bitMasks.bullet) {
            if let bullet = contact.bodyB.node as? Bullet {
                let teamBullet = bullet.team
                if let redPhage = contact.bodyA.node as? Phage {
                    guard(bullet.senderName != redPhage.name) else {return}
                    switch teamBullet {
                    case "Blue":
                        redPhage.strengthLabel?.text? = String(redPhage.strength - bullet.strength)
                        redPhage.strength -= bullet.strength
                        if(redPhage.strength < 0) {
                            redPhage.strengthLabel?.removeFromParent()
                            redPhage.removeFromParent()
                            let newPhage = Phage(coordinate: redPhage.coordinate, team: "Blue")
                            newPhage.strength = abs(redPhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    case "Red":
                        //redPhage.strengthLabel.text? = String(redPhage.strength + bullet.strength)
                        let sumStrength = redPhage.strength + bullet.strength
                        if(sumStrength > redPhage.maxCap) {
                            redPhage.strength = redPhage.maxCap
                        }
                        else {
                            redPhage.strength = sumStrength
                        }
                    default:
                        return
                    }
                }
                bullet.removeFromParent()
            }
        }
        else if (contact.bodyA.categoryBitMask == bitMasks.bullet && contact.bodyB.categoryBitMask == bitMasks.red) {
            if let bullet = contact.bodyA.node as? Bullet {
                let teamBullet = bullet.team
                if let redPhage = contact.bodyB.node as? Phage {
                    guard(bullet.senderName != redPhage.name) else {return}
                    switch teamBullet {
                    case "Blue":
                        redPhage.strengthLabel?.text? = String(redPhage.strength - bullet.strength)
                        redPhage.strength -= bullet.strength
                        if(redPhage.strength < 0) {
                            redPhage.strengthLabel?.removeFromParent()
                            redPhage.removeFromParent()
                            let newPhage = Phage(coordinate: redPhage.coordinate, team: "Blue")
                            newPhage.strength = abs(redPhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    case "Red":
                        //redPhage.strengthLabel.text? = String(redPhage.strength + bullet.strength)
                        let sumStrength = redPhage.strength + bullet.strength
                        if(sumStrength > redPhage.maxCap) {
                            redPhage.strength = redPhage.maxCap
                        }
                        else {
                            redPhage.strength = sumStrength
                        }
                    default:
                        return
                    }
                }
                bullet.removeFromParent()
            }
        }
            
        /* Checks for bullet and grayPhage collision */
        else if (contact.bodyA.categoryBitMask == bitMasks.gray && contact.bodyB.categoryBitMask == bitMasks.bullet) {
            if let bullet = contact.bodyB.node as? Bullet {
                let teamBullet = bullet.team
                if let grayPhage = contact.bodyA.node as? Phage {
                    guard(bullet.senderName != grayPhage.name) else {return}
                    switch teamBullet {
                    case "Blue":
                        grayPhage.strengthLabel?.text? = String(grayPhage.strength - bullet.strength)
                        grayPhage.strength -= bullet.strength
                        if(grayPhage.strength < 0) {
                            grayPhage.strengthLabel?.removeFromParent()
                            grayPhage.removeFromParent()
                            let newPhage = Phage(coordinate: grayPhage.coordinate, team: "Blue")
                            newPhage.strength = abs(grayPhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    case "Red":
                        grayPhage.strengthLabel?.text? = String(grayPhage.strength - bullet.strength)
                        grayPhage.strength -= bullet.strength
                        if(grayPhage.strength < 0) {
                            grayPhage.strengthLabel?.removeFromParent()
                            grayPhage.removeFromParent()
                            let newPhage = Phage(coordinate: grayPhage.coordinate, team: "Red")
                            newPhage.strength = abs(grayPhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    default:
                        return
                    }
                }
                bullet.removeFromParent()
            }
        }
        else if (contact.bodyA.categoryBitMask == bitMasks.bullet && contact.bodyB.categoryBitMask == bitMasks.gray) {
            if let bullet = contact.bodyA.node as? Bullet {
                let teamBullet = bullet.team
                if let grayPhage = contact.bodyB.node as? Phage {
                    guard(bullet.senderName != grayPhage.name) else {return}
                    switch teamBullet {
                    case "Blue":
                        grayPhage.strengthLabel?.text? = String(grayPhage.strength - bullet.strength)
                        grayPhage.strength -= bullet.strength
                        if(grayPhage.strength < 0) {
                            grayPhage.strengthLabel?.removeFromParent()
                            grayPhage.removeFromParent()
                            let newPhage = Phage(coordinate: grayPhage.coordinate, team: "Blue")
                            newPhage.strength = abs(grayPhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    case "Red":
                        grayPhage.strengthLabel?.text? = String(grayPhage.strength - bullet.strength)
                        grayPhage.strength -= bullet.strength
                        if(grayPhage.strength < 0) {
                            grayPhage.strengthLabel?.removeFromParent()
                            grayPhage.removeFromParent()
                            let newPhage = Phage(coordinate: grayPhage.coordinate, team: "Red")
                            newPhage.strength = abs(grayPhage.strength)
                            self.addChild(newPhage)
                            self.addChild(newPhage.strengthLabel!)
                        }
                    default:
                        return
                    }
                }
                bullet.removeFromParent()
            }
        }
        
    }
        
    var senderPhage: Phage?
    
    func getDesiredNodeAtPoint<T>(point: CGPoint, type: T) -> T? {
        let nodeArray = nodesAtPoint(point)
        for node in nodeArray {
            if let found = node as? T {
                return found
            }
        }
        return nil
    }
    func unpause() {
        grayOut?.removeFromParent()
        whiteOutline?.removeFromParent()
        menuLabel?.removeFromParent()
        restartLabel?.removeFromParent()
        resumeLabel?.removeFromParent()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        self.paused = false
    }
    
    func pauseButtonClicked() {
        /* pauses motion */
        self.paused = true
        timer?.invalidate()
        
        /* creates tint */
        self.grayOut = SKShapeNode(rectOfSize: CGSize(width: (self.scene?.frame.size.width)!, height: (self.scene?.frame.size.height)!))
        grayOut?.fillColor = UIColor.cyanColor()
        grayOut?.alpha = 0.5
        grayOut?.position = CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2)
        grayOut?.zPosition = zPositions.pausedTint
        self.addChild(grayOut!)
        
        /* creates whiteOutline */
        self.whiteOutline = SKShapeNode(rectOfSize: CGSize(width: (self.scene?.frame.size.width)! * 0.75, height: (self.scene?.frame.size.height)! * 0.5), cornerRadius: 20.0)
        whiteOutline?.fillColor = UIColor.whiteColor()
        whiteOutline?.position = CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2)
        whiteOutline?.zPosition = zPositions.whiteOutline
        self.addChild(whiteOutline!)
        
        /* creates Menu Label */
        self.menuLabel = SKLabelNode(text: "Menu")
        menuLabel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        menuLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        menuLabel?.position = (whiteOutline?.position)!
        menuLabel?.fontName = "Arial"
        menuLabel?.fontColor = UIColor.cyanColor()
        menuLabel?.zPosition = zPositions.pausedLabel
        menuLabel?.name = "menu"
        self.addChild(menuLabel!)
        
        /* creates restart Label */
        self.restartLabel = SKLabelNode(text: "Restart")
        restartLabel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        restartLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        restartLabel?.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! + whiteOutline!.frame.size.height * 0.25)
        restartLabel?.fontName = "Arial"
        restartLabel?.fontColor = UIColor.cyanColor()
        restartLabel?.zPosition = zPositions.pausedLabel
        restartLabel?.name = "restart"
        self.addChild(restartLabel!)
        
        /* creates resume Label */
        self.resumeLabel = SKLabelNode(text: "Resume")
        resumeLabel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        resumeLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        resumeLabel?.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! - whiteOutline!.frame.size.height * 0.25)
        resumeLabel?.fontColor = UIColor.cyanColor()
        resumeLabel?.fontName = "Arial"
        resumeLabel?.zPosition = zPositions.pausedLabel
        resumeLabel?.name = "resume"
        self.addChild(resumeLabel!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let startLocation = touch.locationInNode(self)
            if let selectedPhage = getDesiredNodeAtPoint(startLocation, type: Phage()) where selectedPhage.team == "Blue" {
                senderPhage = selectedPhage
            }
            else {
                print("Here 1")
                senderPhage = nil
                //if let otherPhage = node as? Phage where otherPhage.name?.containsString("Red") == false {
                if let didPause = nodeAtPoint(startLocation) as? SKSpriteNode where didPause.name == "pause" {
                    pauseButtonClicked()
                }
                else if let clickedResume = nodeAtPoint(startLocation) as? SKLabelNode where clickedResume.name == "resume" {
                    unpause()
                }
                else if let clickedRestart = nodeAtPoint(startLocation) as? SKLabelNode where clickedRestart.name == "restart" {
                    removeAllChildren()
                    removeAllActions()
                    self.paused = false
                    time = 0
                    senderPhage = nil
                    level = 1
                    gameBoard()
                }
                else if let clickedMenu = nodeAtPoint(startLocation) as? SKLabelNode where clickedMenu.name == "menu" {
                    removeAllChildren()
                    removeAllActions()
                    self.paused = false
                    time = 0
                    senderPhage = nil
                    level = 1
                    //let mainMenu = MainMenuViewController()
                    self.viewController?.performSegueWithIdentifier("toMainMenu", sender: viewController)
                }
                else if let nextLevel = nodeAtPoint(startLocation) as? SKLabelNode where nextLevel.name == "nextLevel" {
                    removeAllChildren()
                    removeAllActions()
                    self.paused = false
                    time = 0
                    senderPhage = nil
                    level++
                    gameBoard()
                }
                else if let playAgain = nodeAtPoint(startLocation) as? SKLabelNode where playAgain.name == "playAgain" {
                    removeAllChildren()
                    removeAllActions()
                    self.paused = false
                    time = 0
                    senderPhage = nil
                    level = 0
                    score = 0
                    gameBoard()
                }
            }
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
                if let endNode = getDesiredNodeAtPoint(endLocation, type: Phage()) {
                    guard(startNode.name != endNode.name) else {return} //checks for different node
                    let bullet = Bullet(shooter: startNode)
                    bullet.position = startNode.position
                    self.addChild(bullet)
                    let moveToDestination = SKAction.moveTo(endNode.position, duration: NSTimeInterval(calculateDistance(startNode.position, end: endNode.position) / startNode.bulletSpeed))
                    bullet.runAction(moveToDestination)
                    //bullet.escapeSelf()
                    
                }
            }
        }
    }
    
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor
        }
    
    func lose() {
        timer?.invalidate()
        /* creates tint */
        score += calcScore(time, level: level)
        let defaults = NSUserDefaults.standardUserDefaults()
        let highscore = defaults.valueForKey("highscore") as? Int ?? 0
        let highlevel = defaults.valueForKey("highLevel") as? Int ?? 0
        if(score > highscore) {
            defaults.setInteger(score, forKey: "highscore")
        }
        if(level > highlevel) {
            defaults.setInteger(level, forKey: "highLevel")
        }
        self.grayOut = SKShapeNode(rectOfSize: CGSize(width: (self.scene?.frame.size.width)!, height: (self.scene?.frame.size.height)!))
        grayOut?.fillColor = UIColor.cyanColor()
        grayOut?.alpha = 0.5
        grayOut?.position = CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2)
        grayOut?.zPosition = zPositions.pausedTint
        self.addChild(grayOut!)
        
        /* creates whiteOutline */
        self.whiteOutline = SKShapeNode(rectOfSize: CGSize(width: (self.scene?.frame.size.width)! * 0.75, height: (self.scene?.frame.size.height)! * 0.5), cornerRadius: 20.0)
        whiteOutline?.fillColor = UIColor.whiteColor()
        whiteOutline?.position = CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2)
        whiteOutline?.zPosition = zPositions.whiteOutline
        self.addChild(whiteOutline!)
        
        let didLoseLabel = SKLabelNode(text: "You Lost!")
        didLoseLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        didLoseLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        didLoseLabel.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! + whiteOutline!.frame.size.height * 0.35)
        didLoseLabel.fontName = "Arial"
        didLoseLabel.fontColor = UIColor.redColor()
        didLoseLabel.zPosition = zPositions.pausedLabel
        didLoseLabel.name = "lost"
        adjustLabelFontSizeToFitRect(didLoseLabel, rect: (whiteOutline?.frame)!)
        self.addChild(didLoseLabel)
        
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        scoreLabel.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! + whiteOutline!.frame.size.height * 0.10)
        scoreLabel.fontName = "Arial"
        scoreLabel.fontColor = UIColor.darkGrayColor()
        scoreLabel.fontSize = 32
        scoreLabel.zPosition = zPositions.pausedLabel
        scoreLabel.name = "lostScore"
        adjustLabelFontSizeToFitRect(scoreLabel, rect: (whiteOutline?.frame)!)
        self.addChild(scoreLabel)
        
        let levelLabel = SKLabelNode(text: "Level Reached: \(level)")
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelLabel.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! - whiteOutline!.frame.size.height * 0.05)
        levelLabel.fontName = "Arial"
        levelLabel.fontColor = UIColor.darkGrayColor()
        levelLabel.zPosition = zPositions.pausedLabel
        levelLabel.name = "winLevel"
        adjustLabelFontSizeToFitRect(levelLabel, rect: (whiteOutline?.frame)!)
        self.addChild(levelLabel)
        
        nextLevel = SKLabelNode(text: "Play Again")
        nextLevel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        nextLevel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        nextLevel?.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! - whiteOutline!.frame.size.height * 0.25)
        nextLevel?.fontName = "Arial"
        nextLevel?.fontColor = UIColor.darkGrayColor()
        nextLevel?.zPosition = zPositions.pausedLabel
        nextLevel?.name = "playAgain"
        let fadingAction = SKAction.sequence([SKAction.fadeInWithDuration(1.5), SKAction.fadeOutWithDuration(1.5)])
        nextLevel?.runAction(SKAction.repeatActionForever(fadingAction))
        self.addChild(nextLevel!)
    }
    
    func calcScore(time: Int, level: Int) -> Int {
        let timeD = Double(time)
        let levelD = Double(level)
        return Int((100 - timeD) * (1 + levelD / 10.0))
    }
    
    func win(){
        timer?.invalidate()
        /* creates tint */
        score += calcScore(time, level: level)
        self.grayOut = SKShapeNode(rectOfSize: CGSize(width: (self.scene?.frame.size.width)!, height: (self.scene?.frame.size.height)!))
        grayOut?.fillColor = UIColor.cyanColor()
        grayOut?.alpha = 0.5
        grayOut?.position = CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2)
        grayOut?.zPosition = zPositions.pausedTint
        self.addChild(grayOut!)
        
        /* creates whiteOutline */
        self.whiteOutline = SKShapeNode(rectOfSize: CGSize(width: (self.scene?.frame.size.width)! * 0.75, height: (self.scene?.frame.size.height)! * 0.5), cornerRadius: 20.0)
        whiteOutline?.fillColor = UIColor.whiteColor()
        whiteOutline?.position = CGPoint(x: (scene?.frame.size.width)! / 2, y: (scene?.frame.size.height)! / 2)
        whiteOutline?.zPosition = zPositions.whiteOutline
        self.addChild(whiteOutline!)
        
        let didWinLabel = SKLabelNode(text: "You Won!")
        didWinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        didWinLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        didWinLabel.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! + whiteOutline!.frame.size.height * 0.35)
        didWinLabel.fontName = "Arial"
        didWinLabel.fontColor = UIColor.greenColor()
        didWinLabel.zPosition = zPositions.pausedLabel
        didWinLabel.name = "win"
        adjustLabelFontSizeToFitRect(didWinLabel, rect: (whiteOutline?.frame)!)
        self.addChild(didWinLabel)
        
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        scoreLabel.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! + whiteOutline!.frame.size.height * 0.10)
        scoreLabel.fontName = "Arial"
        scoreLabel.fontColor = UIColor.darkGrayColor()
        scoreLabel.fontSize = 32
        scoreLabel.zPosition = zPositions.pausedLabel
        scoreLabel.name = "winScore"
        adjustLabelFontSizeToFitRect(scoreLabel, rect: (whiteOutline?.frame)!)
        self.addChild(scoreLabel)
        
        let levelLabel = SKLabelNode(text: "Level Completed: \(level)")
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelLabel.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! - whiteOutline!.frame.size.height * 0.05)
        levelLabel.fontName = "Arial"
        levelLabel.fontColor = UIColor.darkGrayColor()
        levelLabel.zPosition = zPositions.pausedLabel
        levelLabel.name = "winLevel"
        adjustLabelFontSizeToFitRect(levelLabel, rect: (whiteOutline?.frame)!)
        self.addChild(levelLabel)
        
        nextLevel = SKLabelNode(text: "Next Level")
        nextLevel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        nextLevel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        nextLevel?.position = CGPoint(x: (whiteOutline?.position.x)!, y: (whiteOutline?.position.y)! - whiteOutline!.frame.size.height * 0.25)
        nextLevel?.fontName = "Arial"
        nextLevel?.fontColor = UIColor.darkGrayColor()
        nextLevel?.zPosition = zPositions.pausedLabel
        nextLevel?.name = "nextLevel"
        let fadingAction = SKAction.sequence([SKAction.fadeInWithDuration(1.5), SKAction.fadeOutWithDuration(1.5)])
        nextLevel?.runAction(SKAction.repeatActionForever(fadingAction))
        self.addChild(nextLevel!)
    }

    var winFlag = false
    var loseFlag = false
    
    override func update(currentTime: CFTimeInterval) {
        print("# Nodes: \(self.children.count)")
        var blueCount = 0
        var redCount = 0
        print("Phages: \(Phage.phageCount), Labels: \(Phage.phageLabelCount), Bullets: \(Bullet.bulletCount)")
        enumerateChildNodesWithName("phage.*") { node, _ in
            if let phage = node as? Phage  {
                let team = phage.team
                switch team {
                    case "Blue":
                        blueCount++
                    case "Red":
                        redCount++
                default:
                    break
                }
            }
        }
        if(redCount == 0 && winFlag == false) {
            enumerateChildNodesWithName("*") { node, _ in
                node.paused = true
            }
            winFlag = true
            win()
        }
        else if(blueCount == 0 && winFlag == false) {
            enumerateChildNodesWithName("*") { node, _ in
                node.paused = true
            }
            loseFlag = true
            lose()
            
        }
        /* Called before each frame is rendered */
    }
}
