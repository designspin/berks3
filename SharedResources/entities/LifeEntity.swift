//
//  LifeEntity.swift
//  idiots
//
//  Created by Jason Foster on 20/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class LifeEntity: GKEntity, ContactNotifiableType {
    static let lifeTexture = SKTextureAtlas(named: "berks").textureNamed("idiots-life")
    
    static let lifePickupSound:SKAction = {
        if GameGlobals.instance.playSound {
            return SKAction.playSoundFileNamed("extraLive", waitForCompletion: true)
        } else {
            return SKAction()
        }
    }()
    
    var collected:Bool = false
    var location:CGPoint!
    
    init(location: CGPoint) {
        
        self.location = location
        
        super.init()
        let _ = LifeEntity.lifePickupSound
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        collected = false
        
        let spriteComponent = SpriteComponent(texture: LifeEntity.lifeTexture)
        addComponent(spriteComponent)
        
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 32), center: spriteComponent.node.position), colliderType: .Collectable)
        addComponent(physicsComponent)
        
        spriteComponent.node.position = location
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if entity.isKind(of: PlayerEntity.self) && !collected {
            if let spriteComponent = component(ofType: SpriteComponent.self) {
                self.collected = true
                weak var accessEntityManager = spriteComponent.node.scene as? GameScene
                removeComponent(ofType: PhysicsComponent.self)
                let fade = SKAction.fadeOut(withDuration: 0.5)
                
                let group = SKAction.group([LifeEntity.lifePickupSound,fade])
                
                let action = SKAction.run {[unowned self] in
                    accessEntityManager?.entityManager.remove(entity: self)
                    self.removeComponent(ofType: SpriteComponent.self)
                }
                let sequence = SKAction.sequence([group, action])
                spriteComponent.node.run(sequence)
                
                if GameGlobals.instance.lives < 9 {
                    GameGlobals.instance.lives += 1
                }
            }
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
}
