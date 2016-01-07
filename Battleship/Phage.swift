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
    static var phageCount = 0
    lazy var strengthLabel = SKLabelNode(fontNamed: "Arial")
    var coordinate: CGPoint
    var maxCap = 100
    var bulletSpeed = 100 //pixels per second
    var transferRatio = 0.5 //how much of the strength is transfered (bullet:phage)
    var strength: Int = 0 {
       willSet{
            print("neValue: \(newValue)")
            if (newValue == maxCap-1) {
                print("Here \(newValue)")
                self.removeActionForKey("runStrengthLabel")
                self.strengthLabel.removeActionForKey("runStrengthLabel")
                print(self.strengthLabel.hasActions().description)
            }
                /* re-executes actions if the strength went down from the maxCap */
            else if (strength == maxCap && newValue < strength) {
                let actionwait = SKAction.waitForDuration(Double(rechargeTime))
                let actionrun = SKAction.runBlock({self.strengthLabel.text = String(++self.strength)})
                let firstRunSequence = SKAction.sequence([SKAction.runBlock({self.strengthLabel.text = String(self.strength)}), actionwait])
                let runSequence = SKAction.sequence([actionrun, actionwait])
                strengthLabel.runAction(SKAction.sequence([firstRunSequence, SKAction.repeatActionForever(runSequence)]), withKey: "runStrengthLabel")
            }
        }
        didSet {
            print(strength)
            size = getSize(strength)
            strengthLabel.fontSize = CGFloat(max(10,strength/2))
            /*if (oldValue == maxCap) {
                print("Here \(oldValue)")
                self.removeActionForKey("runStrengthLabel")
                self.strengthLabel.removeActionForKey("runStrengthLabel")
            }*/
            /* re-executes actions if the strength went down from the maxCap */
           /* else if (oldValue == maxCap) {
                let actionwait = SKAction.waitForDuration(Double(rechargeTime))
                let actionrun = SKAction.runBlock({
                    self.strengthLabel.text = String(self.strength)
                    self.strength++
                })
                strengthLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionrun, actionwait])), withKey: "runStrengthLabel")
            }*/
        }
    }
    var rechargeTime: Double = 0.0 // units per second

    var team: String
    /* assigns the appropriate values to each team */
    func getTeamValues(team: String) {
        self.texture = SKTexture(imageNamed: "phage")
        switch team {
        case "Blue":
            self.strength = 90
            self.rechargeTime = 1
            self.color = UIColor.blueColor()
            self.colorBlendFactor = 1.0
        case "Red":
            self.strength = 50
            self.rechargeTime = 1
            self.color = UIColor.redColor()
            self.colorBlendFactor = 1.0
        default:
            self.strength = (1 + Int(arc4random_uniform(4))) * 10
            //self.strength = 0
            self.rechargeTime = 0
            self.color = UIColor.grayColor()
            self.colorBlendFactor = 1.0
        }
        self.size = getSize(self.strength)
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
    /* initializes the strength label for the phage */
    func initializeLabel() {
        strengthLabel.fontSize = CGFloat(max(10, strength/2))
        strengthLabel.fontColor = UIColor.blackColor()
        strengthLabel.text = String(strength)
        strengthLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        strengthLabel.zPosition = 1
        strengthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        strengthLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        guard (rechargeTime != 0) else {return}
        let actionwait = SKAction.waitForDuration(Double(1/rechargeTime))
        //let actionStrengthLabelUpdate = SKAction.runBlock({self.strengthLabel.text = String(self.strength)})
        // increment timer
        let actionrun = SKAction.runBlock({
            //self.strength++
            self.strengthLabel.text = String(++self.strength)
        })
        let firstRunSequence = SKAction.sequence([SKAction.runBlock({self.strengthLabel.text = String(self.strength)}), actionwait])
        let runSequence = SKAction.sequence([actionrun, actionwait])
        strengthLabel.runAction(SKAction.sequence([firstRunSequence, SKAction.repeatActionForever(runSequence)]), withKey: "runStrengthLabel")
        // repeats sequence forever
        /*strengthLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionrun,actionwait])), withKey: "runStrengthLabel")*/
    }
    
    func stopPhageActions() {
        self.removeAllActions()
    }
    
    /* Initializes the cell */
    init(coordinate: CGPoint, team: String = "None") {
        self.coordinate = coordinate
        self.team = team
        let texture = SKTexture(imageNamed: "phage")
        super.init(texture: texture, color: UIColor.grayColor(), size: CGSize(width: 100, height: 100))
        //self.scene = scene
        self.position = coordinate
        self.zPosition = 0
       /// self.color = getColor(team)
        getTeamValues(team)
        initializeLabel()
        Phage.phageCount++
        self.name = "phage_\(team)_\(Phage.phageCount)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}