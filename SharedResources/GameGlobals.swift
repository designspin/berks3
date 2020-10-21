//
//  GameGlobals.swift
//  idiots
//
//  Created by Jason Foster on 21/03/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import Foundation
import SpriteKit

class GameGlobals:NSObject {
    
    static var instance:GameGlobals = GameGlobals()
    
    // Convenient configuration flags
    let spawnBerks = true
    let berksToSpawn = 14
    let spawnDrone = true
    let showBricks = true
    let playSound = true
    
    var listeners = [String:AnyObject]()
    
    var gamecenter = false
    
    #if os(OSX)
    var keyBindings: [String: Character] = ["LEFT": "z", "RIGHT": "x", "UP": "f", "DOWN": "c", "FIRE": "g"]
    #endif
    
    enum difficultySetting:Int {
        
        case Duffer
        case Novice
        case Normal
        case Expert
        case Master
        
        var name: String {
            get { return String(describing: self) }
        }
        
        static var _count: difficultySetting.RawValue = {
            var maxValue:Int = 0
            while let _ = difficultySetting(rawValue: maxValue) {
                maxValue += 1
            }
            return maxValue
        }()
        
        mutating func next() {
            switch self {
            case .Duffer:
                self = .Novice
            case .Novice:
                self = .Normal
            case .Normal:
                self = .Expert
            case .Expert:
                self = .Master
            case .Master:
                self = .Duffer
            }
        }
        
        mutating func prev() {
            switch self {
            case .Duffer:
                self = .Master
            case .Novice:
                self = .Duffer
            case .Normal:
                self = .Novice
            case .Expert:
                self = .Normal
            case .Master:
                self = .Expert
            }
        }
        
        func identifier() -> String {
            switch self {
            case .Duffer:
                return "duffer"
            case .Novice:
                return "novice"
            case .Normal:
                return "normal"
            case .Expert:
                return "expert"
            case .Master:
                return "master"
            }
        }
    }
    
    let mapData = [
        1:["drones":[1,2,3,4,5],"drone_type":["drone_a_1","drone_a_2"]],
        2:["drones":[2,3,4,5,6],"drone_type":["drone_a_1","drone_a_2"]],
        3:["drones":[2,3,4,5,6],"drone_type":["drone_a_1","drone_a_2"]],
        4:["drones":[2,3,4,5,6],"drone_type":["drone_a_1","drone_a_2"]],
        5:["drones":[1,2,3,4,5],"drone_type":["drone_a_1","drone_a_2"]],
        6:["drones":[3,3,5,6,7],"drone_type":["drone_a_1","drone_a_2"]],
        7:["drones":[2,3,4,5,6],"drone_type":["drone_b_1","drone_b_2"]],
        8:["drones":[2,3,4,5,6],"drone_type":["drone_b_1","drone_b_2"]],
        9:["drones":[1,2,3,4,5],"drone_type":["drone_b_1","drone_b_2"]],
        10:["drones":[2,3,4,5,6],"drone_type":["drone_b_1","drone_b_2"]],
        11:["drones":[2,3,4,5,6],"drone_type":["drone_b_1","drone_b_2"]],
        12:["drones":[1,2,3,4,5],"drone_type":["drone_b_1","drone_b_2"]],
        13:["drones":[2,3,4,5,6],"drone_type":["drone_c_1","drone_c_2"]],
        14:["drones":[2,3,4,5,6],"drone_type":["drone_c_1","drone_c_2"]],
        15:["drones":[3,3,5,6,7],"drone_type":["drone_d_1","drone_d_2"]],
        16:["drones":[3,3,5,6,7],"drone_type":["drone_e_1","drone_e_2"]],
        17:["drones":[1,2,3,4,5],"drone_type":["drone_c_1","drone_c_2"]],
        18:["drones":[1,2,3,4,5],"drone_type":["drone_c_1","drone_c_2"]],
        19:["drones":[1,3,4,5,6],"drone_type":["drone_f_1","drone_f_2"]],
        20:["drones":[1,2,3,4,5],"drone_type":["drone_f_1","drone_f_2"]],
        21:["drones":[1,2,3,4,5],"drone_type":["drone_f_1","drone_f_2"]],
        22:["drones":[1,2,3,4,5],"drone_type":["drone_f_1","drone_f_2"]],
        23:["drones":[2,3,4,5,6],"drone_type":["drone_f_1","drone_f_2"]],
        24:["drones":[3,4,5,6,7],"drone_type":["drone_f_1","drone_f_2"]],
        25:["drones":[2,3,4,5,6],"drone_type":["drone_g_1","drone_g_2"]],
        26:["drones":[2,3,4,5,6],"drone_type":["drone_g_1","drone_g_2"]],
        27:["drones":[1,2,3,4,5],"drone_type":["drone_g_1","drone_g_2"]],
        28:["drones":[2,3,4,5,6],"drone_type":["drone_g_1","drone_g_2"]],
        29:["drones":[2,3,4,5,6],"drone_type":["drone_g_1","drone_g_2"]],
        30:["drones":[1,1,2,3,4],"drone_type":["drone_g_1","drone_g_2"]]
    ]
    
    var currentDifficulty:difficultySetting = .Normal {
        didSet {
            if listeners["difficulty"] != nil {
                if let difficultylabel = listeners["difficulty"] as? SKLabelNode {
                    difficultylabel.text = "\(currentDifficulty.name)"
                }
            }
        }
    }
    
    var highScore:Int = UserDefaults.standard.integer(forKey: "berksHighScore")
    
    var score:Int = 0 {
        didSet {
            if listeners["score"] != nil {
                if let scorelabel = listeners["score"] as? SKLabelNode {
                    scorelabel.text = "SC:\(score)"
                }
            }
        }
    }
    
    var room:Int = 1 {
        didSet {
            if listeners["room"] != nil {
                if let roomlabel = listeners["room"] as? SKLabelNode {
                    roomlabel.text = "ROOM:\(room)"
                }
            }
        }
    }
    
    var lives:Int = 5 /* 5 */ {
        didSet {
            if listeners["lives"] != nil {
                if let liveslabel = listeners["lives"] as? SKLabelNode {
                    liveslabel.text = "LIVES:\(lives)"
                }
            }
        }
    }
    
    var keys:Int = 0 {
        didSet {
            if listeners["keys"] != nil {
                if let keyslabel = listeners["keys"] as? SKLabelNode {
                    keyslabel.text = "KEYS:\(keys)"
                }
            }
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("didReceiveKey"), object: nil, userInfo: ["keys": keys])
            
        }
    }
    
    func addListener(name: String, object: AnyObject) {
        listeners[name] = object
    }
    
    func reset() {
        lives = 5 /* 5 */
        score = 0
        room = 1
        keys = 0
    }
    
    func softReset() {
        room = 1
        keys = 0
    }
}
