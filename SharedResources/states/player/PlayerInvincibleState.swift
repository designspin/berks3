//
//  PlayerInvincibleState.swift
//  idiots
//
//  Created by Jason Foster on 03/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import Swift
import GameKit

class PlayerInvincibleState: GKState {
    weak var player:PlayerEntityManager!
    
    init(withEntity: GKEntity) {
        player = withEntity as? PlayerEntityManager
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        player.didEnterInvincibleState()
    }
}
