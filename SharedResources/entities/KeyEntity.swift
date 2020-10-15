//
//  KeyEntity.swift
//  idiots
//
//  Created by Jason Foster on 11/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class KeyEntity: GKEntity, ContactNotifiableType {
    
    static let keyTexture = SKTextureAtlas(named: "berks").textureNamed("idiots-key")
    
    static let keyPickupSound:SKAction = {
        if GameGlobals.instance.playSound {
            return SKAction.playSoundFileNamed("keyPickup", waitForCompletion: true)
        } else {
            return SKAction()
        }
    }()
    
    var collected:Bool = false
    var location:CGPoint!
    
    init(location: CGPoint) {
        
        self.location = location
        super.init()
        
        let _ = KeyEntity.keyPickupSound
        
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("Deinit key entity")
    }
    
    func reset() {
        collected = false
        let spriteComponent = SpriteComponent(texture: KeyEntity.keyTexture)
        addComponent(spriteComponent)
        
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 32), center: spriteComponent.node.position), colliderType: .Collectable)
        addComponent(physicsComponent)
        
        spriteComponent.node.position = location
        spriteComponent.node.color = EntityColor.randomUiColor().ui
        spriteComponent.node.colorBlendFactor = 1
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if entity.isKind(of: PlayerEntity.self) && !collected {
            if let spriteComponent = component(ofType: SpriteComponent.self) {
                self.collected = true
                weak var accessEntityManager = spriteComponent.node.scene as? GameScene
                removeComponent(ofType: PhysicsComponent.self)
                let fade = SKAction.fadeOut(withDuration: 0.5)
                
                let group = SKAction.group([KeyEntity.keyPickupSound,fade])
                
                let action = SKAction.run {[unowned self] in
                    accessEntityManager?.entityManager.remove(entity: self)
                    self.removeComponent(ofType: SpriteComponent.self)
                }
                
                let sequence = SKAction.sequence([group, action])
                spriteComponent.node.run(sequence)
                GameGlobals.instance.keys += 1
            }
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
}
