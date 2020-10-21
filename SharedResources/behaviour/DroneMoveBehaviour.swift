//
//  DroneMoveBehaviour.swift
//  idiots
//
//  Created by Jason Foster on 19/03/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import GameplayKit
import SpriteKit


class DroneMoveBehaviour: GKBehavior {
    
    init(seek: GKAgent, avoid: [GKAgent], drones: [GKAgent2D]) {
        super.init()
        setWeight(1, for: GKGoal(toReachTargetSpeed: 50))
        setWeight(0.9, for: GKGoal(toSeekAgent: seek))
        setWeight(0.8, for: GKGoal(toAvoid: avoid, maxPredictionTime: 1))
        setWeight(0.8, for: GKGoal(toAvoid: drones, maxPredictionTime: 1))
    }
}
