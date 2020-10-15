//
//  PrizeEntity.swift
//  Berks 3
//
//  Created by Jason Foster on 03/05/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class PrizeEntity:GKEntity, ContactNotifiableType {
    
    static let anims = ["normal":["prize0","prize1","prize2","prize3"], "collected":["prize4"]];
    static let atlas = SKTextureAtlas(named: "berks");
    static let spriteTexture = DoorEntity.atlas.textureNamed("prize0");
    
    override init() {
        super.init()
        reset()
    }
    
    func reset() {
        let spriteComponent = SpriteComponent(texture: PrizeEntity.spriteTexture)
        addComponent(spriteComponent)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 32))
        let physicsComponent = PhysicsComponent(physicsBody: body, colliderType: .Collectable)
        addComponent(physicsComponent)
        
        let animComponent = AnimComponent(atlas: PrizeEntity.atlas, anims: PrizeEntity.anims, defaultAnim: "normal")
        addComponent(animComponent)
        
        spriteComponent.node.position = CGPoint(x: 2496, y: 1008)
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
        spriteComponent.node.physicsBody?.isDynamic = false
        animComponent.repeatRunAnimation(name: "normal", timePerFrame: 0.1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if entity.isKind(of: PlayerEntity.self) {
            if let spriteComponent = component(ofType: SpriteComponent.self) {
                weak var scene = spriteComponent.node.scene as? GameScene
                
                if let animComponent = component(ofType: AnimComponent.self) {
                    animComponent.repeatRunAnimation(name: "collected", timePerFrame: 0.1)
                }
                
                self.removeComponent(ofType: PhysicsComponent.self)
                spriteComponent.node.physicsBody = nil
                
                scene?.sceneState.enter(SceneCompletedState.self)
            }
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
}
