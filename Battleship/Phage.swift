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
        super.init(texture: nil, color: UIColor.grayColor(), size: size)
        self.strength = getStrength(size)
        self.color = getColor(team)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}