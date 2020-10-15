//
//  ScenePausedState.swift
//  Berks 3
//
//  Created by Jason Foster on 08/05/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class ScenePausedState: GKState {
    weak var scene:GameSceneManager!
    
    init(withScene: SKScene) {
        scene = withScene as? GameSceneManager
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Entering paused state")
        scene.didPauseScene()
    }
}
