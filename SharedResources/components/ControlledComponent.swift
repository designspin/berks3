//
//  ControlledComponent.swift
//  idiots
//
//  Created by Jason Foster on 19/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class ControlledComponent: GKAgent2D, GKAgentDelegate {
    var vel:CGVector = CGVector(dx: 0, dy: 0)
    
    override init() {
        super.init()
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit Controlled Component")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if let entity = self.entity {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                
                let node = spriteComponent.node
                
                /*node.removeAction(forKey: "control")
                let action = SKAction.move(by: vel, duration: 0.5)
                node.run(action, withKey: "control")*/
                
                node.position = CGPoint(x: node.position.x + vel.dx * CGFloat(seconds), y: node.position.y + vel.dy * CGFloat(seconds))
            }
        }
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        
        position = vector_float2(Float(spriteComponent.node.position.x),Float(spriteComponent.node.position.y))
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        
        position = vector_float2(Float(spriteComponent.node.position.x),Float(spriteComponent.node.position.y))
    }
}
