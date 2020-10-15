//
//  DroneStates.swift
//  idiots
//
//  Created by Jason Foster on 19/03/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class DroneStunnedState: GKState {
    weak var drone: DroneEntityProtocol!
    
    init(withEntity: GKEntity) {
        drone = withEntity as? DroneEntityProtocol
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is DroneSeekingState.Type:
            return true
        case is DroneStunnedState.Type:
            return false
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        drone.stunned()
    }
}

class DroneSeekingState: GKState {
    weak var drone: DroneEntityProtocol!
    
    init(withEntity: GKEntity) {
        drone = withEntity as? DroneEntityProtocol
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is DroneSeekingState.Type:
            return false
        case is DroneStunnedState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        drone.seek()
    }
}
