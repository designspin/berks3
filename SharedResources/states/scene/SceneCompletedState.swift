//
//  SceneCompletedState.swift
//  Berks 3
//
//  Created by Jason Foster on 04/05/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class SceneCompletedState: GKState {
    weak var scene:GameSceneManager!
    
    init(withScene: SKScene) {
        scene = withScene as? GameSceneManager
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.didCompleteScene()
    }
}
