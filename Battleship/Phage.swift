//
//  Phage.swift
//  Battleship
//
//  Created by Sean Hudson on 1/1/16.
//  Copyright © 2016 Sean Hudson. All rights reserved.
//

import Foundation
import SpriteKit



class Phage: SKSpriteNode {
    static var currentPhageCount = 0
    static var totalPhageCount = 0
    static var bluePhageCount = 0
    static var redPhageCount = 0
    var strengthLabel: SKLabelNode?
    var coordinate: CGPoint
    var maxCap = 100
    var bulletSpeed: Double = 100.0 //pixels per second
    var transferRatio = 0.5 //how much of the strength is transfered (bullet:phage)
    var strength: Int = 0 {
       willSet{
            if (newValue >= maxCap-1) {
                strengthLabel?.text = String(strength)
                self.removeActionForKey("runStrengthLabel")
                self.strengthLabel?.removeActionForKey("runStrengthLabel")
            }
                /* re-executes actions if the strength went down from the maxCap */
            else if (strength == maxCap && newValue < strength) {
                let actionwait = SKAction.waitForDuration(Double(rechargeTime))
                let actionrun = SKAction.runBlock({ [unowned self] in
                    self.strengthLabel?.text = String(++self.strength)})
                let firstRunSequence = SKAction.sequence([SKAction.runBlock({
                    [unowned self] in
                    self.strengthLabel?.text = String(self.strength)}), actionwait])
                let runSequence = SKAction.sequence([actionrun, actionwait])
                strengthLabel?.runAction(SKAction.sequence([firstRunSequence, SKAction.repeatActionForever(runSequence)]), withKey: "runStrengthLabel")
            }
        }
        didSet {
            size = getSize(strength)
            strengthLabel?.fontSize = CGFloat(max(20,strength/2))
            setPhysics(team)
            /* calls AI function */
            if (team == "Red") {
                if let endNode = phageAI(){
                    let bullet = Bullet(shooter: self)
                    bullet.position = self.position
                    parent?.addChild(bullet)
                    let moveToDestination = SKAction.moveTo(endNode.position, duration: NSTimeInterval(calculateDistance(self.position, end: endNode.position) / self.bulletSpeed))
                    bullet.runAction(moveToDestination)
                }
            }
        }
    }
    var rechargeTime: Double = 0.0 // units per second
    var AIThreshhold: Int?
    
    var team: String
    /* assigns the appropriate values to each team */
    func getTeamValues(team: String) {
        self.texture = SKTexture(imageNamed: "phage")
        switch team {
        case "Blue":
            self.strength = 50
            self.rechargeTime = 1
            self.color = UIColor.blueColor()
            self.colorBlendFactor = 1.0
        case "Red":
            AIThreshhold = 10 + Int(arc4random_uniform(UInt32(maxCap)/2))
            self.strength = 50
            self.rechargeTime = 1
            self.color = UIColor.redColor()
            self.colorBlendFactor = 1.0
        default:
            self.strength = (1 + Int(arc4random_uniform(4))) * 10
            self.rechargeTime = 0
            self.color = UIColor.grayColor()
            self.colorBlendFactor = 1.0
        }
        self.size = getSize(self.strength)
    }
    
    /* very very inefficient (but no other way to scale physicsbodies) */
    private func setPhysics(team: String) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.pinned = true
        switch team {
            case "Blue":
                self.physicsBody?.categoryBitMask = GameScene.bitMasks.blue
                self.physicsBody?.collisionBitMask = GameScene.bitMasks.none
                self.physicsBody?.contactTestBitMask = (GameScene.bitMasks.bullet)
            case "Red":
                self.physicsBody?.categoryBitMask = GameScene.bitMasks.red
                self.physicsBody?.collisionBitMask = GameScene.bitMasks.none
                self.physicsBody?.contactTestBitMask = (GameScene.bitMasks.bullet)
            case "Gray":
                self.physicsBody?.categoryBitMask = GameScene.bitMasks.gray
                self.physicsBody?.collisionBitMask = GameScene.bitMasks.none
                self.physicsBody?.contactTestBitMask = (GameScene.bitMasks.bullet)
        default:
            return
        }
    }
    
    func calculateDistance(start: CGPoint, end: CGPoint) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return Double(sqrt(dx * dx + dy * dy))
    }

    func phageAI() -> Phage? {
        var allOtherPhages: [Phage] = []
        var lessThanHalf:[Phage] = []
        var minNode: Phage?
        parent?.enumerateChildNodesWithName("phage.*") { node, _ in
            /* finds Phage nodes that aren't red */
            if let otherPhage = node as? Phage where otherPhage.name?.containsString("Red") == false {
                allOtherPhages.append(otherPhage)
                if(minNode == nil) {minNode = otherPhage}
                else {
                    if(otherPhage.strength < minNode?.strength) {
                        minNode = otherPhage
                    }
                }
                if(otherPhage.strength < self.strength / 2) {
                    lessThanHalf.append(otherPhage)
                }
            
            }
            
        }
        if(lessThanHalf.count > 0) {
            /* sorts by closest distance */
            lessThanHalf.sortInPlace({ (first, second) -> Bool in
                calculateDistance(self.position, end: first.position) < calculateDistance(self.position, end: second.position)
            })
            return lessThanHalf.first
        }
        else if (allOtherPhages.count > 0) {
            if (strength > AIThreshhold!) {
                let randNum = Int(arc4random_uniform(20))
                switch randNum {
                case randNum where 0...2 ~= randNum:
                    return minNode
                case randNum where 3...5 ~= randNum:
                    return allOtherPhages[Int(arc4random_uniform(UInt32(allOtherPhages.count)))]
                default:
                    return nil
                }
            }
            return nil
        }
        else {return nil}
    }
    
    /* Calculates the strength of the cell */
    func getSize(strength: Int) -> CGSize {
        return CGSize(width: 50 + strength / 2, height: 50 + strength / 2)
    }
    
    /* updates current strength and calculates transfered strength*/
    func transferStrength() -> Int {
        let transferedStrength = Int(Double(strength) * transferRatio)
        self.strength = strength - transferedStrength
        return transferedStrength
    }
    
    /* Initializes the cell */
    init(coordinate: CGPoint, team: String = "None") {
        self.coordinate = coordinate
        self.team = team
        let texture = SKTexture(imageNamed: "phage")
        super.init(texture: texture, color: UIColor.grayColor(), size: CGSize(width: 100, height: 100))
        self.position = coordinate
        self.zPosition = GameScene.zPositions.phage
        getTeamValues(team)
        self.name = "phage_\(team)_\(Phage.totalPhageCount)"
        Phage.currentPhageCount++
        Phage.totalPhageCount++
        switch team {
            case "Blue":
                Phage.bluePhageCount++
            case "Red":
                Phage.redPhageCount++
            default:
                break
        }
    }
    
    init() {
        self.coordinate = CGPoint(x: 100, y: 100)
        self.team = "Gray"
        super.init(texture: SKTexture(imageNamed: "phage"), color: UIColor.whiteColor(), size: CGSize(width: 100, height: 100))
        Phage.currentPhageCount++
        Phage.phageLabelCount++
        Phage.totalPhageCount++
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static var phageLabelCount = 0
    deinit {
        Phage.currentPhageCount--
        switch team {
        case "Blue":
            Phage.bluePhageCount--
        case "Red":
            Phage.redPhageCount--
        default:
            break
        }
        Phage.phageLabelCount--
//        print("Phage was deleted")
    }
}