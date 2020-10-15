//
//  DoorEntity.swift
//  idiots
//
//  Created by Jason Foster on 02/05/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class DoorEntity: GKEntity, ContactNotifiableType {
    
    static let anims = ["normal":["rope0","rope1","rope2","rope3"]];
    static let atlas = SKTextureAtlas(named: "berks");
    static let spriteTexture = DoorEntity.atlas.textureNamed("rope0");
    
    var location:CGPoint!
    var removed:Bool = false
    
    init(location: CGPoint) {
        self.location = location
        super.init()
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        removed = false
        
        let spriteComponent = SpriteComponent(texture: DoorEntity.spriteTexture)
        addComponent(spriteComponent)
        
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 6), center: CGPoint(x: spriteComponent.node.position.x, y: spriteComponent.node.position.y - 6)), colliderType: .Obstacle)
        addComponent(physicsComponent)
        
        
        
        let animComponent = AnimComponent(atlas: DoorEntity.atlas, anims: DoorEntity.anims, defaultAnim: "normal")
        addComponent(animComponent)
        animComponent.repeatRunAnimation(name: "normal", timePerFrame: 0.1)
        
        spriteComponent.node.position = location
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
        spriteComponent.node.physicsBody?.isDynamic = false
    }
    
    func remove() {
        removeComponent(ofType: PhysicsComponent.self)
        
        let fadeAction = SKAction.fadeOut(withDuration: 0.5)
        let blockAction = SKAction.run {[unowned self] in
            if let spriteComponent = self.component(ofType: SpriteComponent.self) {
                weak var mg = spriteComponent.node.scene as? GameScene
                mg?.entityManager.remove(entity: self)
            }
        }
        
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            spriteComponent.node.run(SKAction.sequence([fadeAction, blockAction]))
        }
        
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
}
