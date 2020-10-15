//
//  DroneMoveComponent.swift
//  idiots
//
//  Created by Jason Foster on 19/03/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

class DroneMoveComponent: GKAgent2D, GKAgentDelegate {
    
    weak var entityManager: EntityManager?
    
    var behaviorOn:Bool = true
    var switchBehavior: TimeInterval!
    var elapsed: Double = 0
    
    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        super.init()
        delegate = self
        self.maxSpeed = 50.0
        self.mass = 0.01
        self.radius = 16
        
        switchBehavior = 0.4 + Double(0.1 * Double(GameGlobals.instance.currentDifficulty.rawValue)) //setInterval()
        
        if let controlledComponent = entityManager.playerEntity?.component(ofType: ControlledComponent.self) {
            
            let droneEntities = entityManager.droneEntities().filter{$0 != self}
            
            behavior = DroneMoveBehaviour(seek: controlledComponent, avoid: entityManager.berkEntities(), drones: droneEntities)
            //behavior?.setWeight(2500, for: FastGoal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInterval() -> Double {
        return Double(arc4random_uniform(4) + 1)
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        
        position = vector_float2(Float(spriteComponent.node.position.x), Float(spriteComponent.node.position.y))
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        
        spriteComponent.node.position = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        elapsed = elapsed + seconds
        
        if elapsed > switchBehavior && behaviorOn {
            self.maxSpeed = Float(arc4random_uniform(10) + 10)
            elapsed = 0
            behaviorOn = !behaviorOn
        } else if elapsed > switchBehavior {
            self.maxSpeed = 50
            behaviorOn = !behaviorOn
            elapsed = 0
        }
    }
}
