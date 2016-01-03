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
    
    var coordinate: CGPoint
    var strength: Int = 0
    var rechargeTime: Int = 0
    var team: String
    
    /* Gets the color for the cell  */
   /* private func getColor(color: String) -> UIColor {
        switch color {
        case "Blue":
             return UIColor.blueColor()
        case "Red":
            return UIColor.redColor()
        default:
            return UIColor.grayColor()
        }
    }*/
    
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
        return CGSize(width: strength/20, height: strength/20)
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