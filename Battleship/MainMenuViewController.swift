//
//  mainMenuViewcontroller.swift
//  Battleship
//
//  Created by Sean Hudson on 1/8/16.
//  Copyright © 2016 Sean Hudson. All rights reserved.
//

import Foundation
import UIKit

class MainMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        let highscore = defaults.valueForKey("highscore") as? Int ?? 0
        let highlevel = defaults.valueForKey("highLevel") as? Int ?? 0
        highscoreLabel.text = "Highscore: \(highscore)"
        levelLabel.text = "Highest Level: \(highlevel)"
    }
    
    @IBOutlet weak var highscoreLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBAction func playButton(sender: UIButton) {
        return
    }
    
    /*deinit {
        print("MainMenuViewController was de-allocated")
    }*/

}