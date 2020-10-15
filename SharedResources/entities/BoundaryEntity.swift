//
//  BoundaryEntity.swift
//  idiots
//
//  Created by Jason Foster on 16/03/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class BoundaryEntity: GKEntity {
    var rect:CGRect!
    
    init(rect: CGRect) {
        self.rect = rect
        super.init()
        reset()
    }
    
    func reset() {
        let nodeComponent = NodeComponent(position: CGPoint(x: rect.minX,y: rect.minY))
        addComponent(nodeComponent)
        
        let physicsBody = SKPhysicsBody.init(edgeLoopFrom: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Boundary)
        addComponent(physicsComponent)
        
        nodeComponent.node.physicsBody = physicsComponent.physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
