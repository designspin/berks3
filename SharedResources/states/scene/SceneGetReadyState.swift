//
//  SceneGetReadyState.swift
//  Berks 3
//
//  Created by Jason Foster on 06/07/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class SceneGetReadyState: GKState {
    weak var scene:GameSceneManager!
    
    init(withScene: SKScene) {
        scene = withScene as? GameSceneManager
    }
}
