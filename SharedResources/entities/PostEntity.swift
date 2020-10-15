//
//  PostEntity.swift
//  idiots
//
//  Created by Jason Foster on 02/05/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class PostEntity: GKEntity, ContactNotifiableType {
    
    static var spriteTexture = SKTextureAtlas(named: "berks").textureNamed("idiots-gate")
    
    var location:CGPoint!
    
    init(location:CGPoint) {
        self.location = location
        super.init()
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        let spriteComponent = SpriteComponent(texture: PostEntity.spriteTexture)
        addComponent(spriteComponent)
        
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 32), center: spriteComponent.node.position) , colliderType: .Obstacle)
        addComponent(physicsComponent)
        
        spriteComponent.node.position = location
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
        spriteComponent.node.physicsBody?.isDynamic = false
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
    }
}
