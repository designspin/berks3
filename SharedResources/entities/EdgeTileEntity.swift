//
//  EdgeTileEntity.swift
//  idiots
//
//  Created by Jason Foster on 30/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

class EdgeTileEntity: GKEntity {
    
    var location:CGPoint!
    var path:CGMutablePath!
    
    init(location: CGPoint, path: CGMutablePath) {
        self.location = location
        self.path = path
        super.init()
        
        reset()
    }
    
    func reset() {
        let nodeComponent = NodeComponent(position: location)
        addComponent(nodeComponent)
        
        let body = SKPhysicsBody(edgeLoopFrom: path)
        let physicsComponent = PhysicsComponent(physicsBody: body, colliderType: .Obstacle)
        physicsComponent.physicsBody.isDynamic = false
        addComponent(physicsComponent)
        
        nodeComponent.node.physicsBody = physicsComponent.physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
