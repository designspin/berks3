//
//  PhysicsComponent.swift
//  idiots
//
//  Created by Jason Foster on 29/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
    var physicsBody: SKPhysicsBody
    
    init(physicsBody: SKPhysicsBody, colliderType: ColliderType) {
        self.physicsBody = physicsBody
        self.physicsBody.categoryBitMask = colliderType.categoryMask
        self.physicsBody.collisionBitMask = colliderType.collisionMask
        self.physicsBody.contactTestBitMask = colliderType.contactMask
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willRemoveFromEntity() {
        if let spriteComponent = entity?.component(ofType: SpriteComponent.self) {
            spriteComponent.node.physicsBody = nil
        }
    }
}
