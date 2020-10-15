//
//  BerkBehaviour.swift
//  idiots
//
//  Created by Jason Foster on 12/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import GameplayKit
import SpriteKit

class BerkBehaviour: GKBehavior {
    
    init(avoid: [GKAgent]) {
        
        super.init()
        setWeight(1000, for: GKGoal(toAvoid: avoid, maxPredictionTime: 10))
    }
}
