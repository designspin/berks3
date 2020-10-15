//
//  SceneLoseLifeState.swift
//  idiots
//
//  Created by Jason Foster on 24/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class SceneLoseLifeState:GKState {
    
    weak var scene:GameSceneManager!
    
    init(withScene: SKScene) {
        scene = withScene as? GameSceneManager
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.didLoseLife()
    }
}
