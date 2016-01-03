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
    var rechargeTime: Int
    var team: String
    
    
    /* Gets the color for the cell  */
    private func getColor(color: String) -> UIColor {
        switch color {
        case "Blue":
             return UIColor.blueColor()
        case "Red":
            return UIColor.redColor()
        default:
            return UIColor.grayColor()
        }
    }
    
    /* Calculates the strength of the cell */
    private func getStrength(size: CGSize) -> Int {
        let radius = Int(size.width / 2)
        return radius * 10
    }
    
    /* Initializes the cell */
    init(coordinate: CGPoint, size: CGSize, rechargeTime: Int, team: String = "None") {
        self.coordinate = coordinate
        self.rechargeTime = rechargeTime
        self.team = team
        let texture = SKTexture(imageNamed: "phageGray")
        super.init(texture: texture, color: UIColor.grayColor(), size: CGSize(width: 100, height: 100))
        self.position = coordinate
        self.strength = getStrength(size)
        self.color = getColor(team)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}