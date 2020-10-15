//
//  SceneChangeRoomState.swift
//  idiots
//
//  Created by Jason Foster on 01/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class SceneChangeRoomState: GKState {
    weak var scene:GameSceneManager!
    
    init(withScene: SKScene) {
        scene = withScene as? GameSceneManager
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ScenePlayingState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Changing room")
    }
}
