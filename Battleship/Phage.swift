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
    lazy var strengthLabel = SKLabelNode(fontNamed: "Arial")
    var coordinate: CGPoint
    var strength: Int = 0 {
        didSet {
            size = getSize(strength)
            strengthLabel.fontSize = CGFloat(strength/2)
        }
    }
    var rechargeTime: Int = 0
    var team: String
    
    /* assigns the appropriate values to each team */
    func getTeamValues(team: String) {
        switch team {
        case "Blue":
            self.strength = 100
            self.rechargeTime = 1
            self.texture = SKTexture(imageNamed: "phageBlue")
        case "Red":
            self.strength = 100
            self.rechargeTime = 1
            self.texture = SKTexture(imageNamed: "phageRed")
        default:
            self.strength = 0
            self.rechargeTime = 0
            self.texture = SKTexture(imageNamed: "phageGray")
        }
        self.size = getSize(self.strength)
    }
    
    /* Calculates the strength of the cell */
    private func getSize(strength: Int) -> CGSize {
        return CGSize(width: strength, height: strength)
    }
    
    func transferStrength(phage: Phage) -> Bool {
        if (self.strength == 0) {
            return false;
        }
        let transfered = Int(self.strength / 2)
        self.strength = Int(self.strength / 2)
        phage.strength += transfered
        return true
    }
    
    /* Initializes the cell */
    init(coordinate: CGPoint, team: String = "None") {
        self.coordinate = coordinate
        self.team = team
        let texture = SKTexture(imageNamed: "phageGray")
        super.init(texture: texture, color: UIColor.grayColor(), size: CGSize(width: 100, height: 100))
        self.position = coordinate
        self.zPosition = 0
       /// self.color = getColor(team)
        getTeamValues(team)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}