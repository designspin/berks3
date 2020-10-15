//
//  PlayerIdleState.swift
//  idiots
//
//  Created by Jason Foster on 03/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import Swift
import GameKit

class PlayerIdleState: GKState {
    weak var player:PlayerEntityManager!
    
    init(withEntity: GKEntity) {
        player = withEntity as? PlayerEntityManager
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is PlayerArmedState.Type:
            return true
        case is PlayerMovingState.Type:
            return true
        case is PlayerInvincibleState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        player.toggleArmedState()
    }
}
