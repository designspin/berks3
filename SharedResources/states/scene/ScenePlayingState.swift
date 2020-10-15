//
//  PlayingState.swift
//  idiots
//
//  Created by Jason Foster on 01/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class ScenePlayingState: GKState {
    weak var scene:GameSceneManager!
    var previousLocation:Int = 1
    
    init(withScene: SKScene) {
        scene = withScene as? GameSceneManager
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is SceneChangeRoomState.Type:
            return true
        case is SceneLoseLifeState.Type:
            return true
        case is SceneCompletedState.Type:
            return true
        case is ScenePausedState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let location = scene.player.roomFromLocation()
        
        if (previousLocation != location) {
            scene.roomChange(to: location, from: previousLocation)
        }
        
        previousLocation = location
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState is ScenePausedState {
            scene.didPauseScene()
        }
    }
    
    override func willExit(to nextState: GKState) {
        if nextState.isKind(of: SceneLoseLifeState.self) && GameGlobals.instance.lives == 1 {
            self.previousLocation = 1
        }
        
        if nextState.isKind(of: SceneCompletedState.self) {
            self.previousLocation = 1
        }
    }
}
