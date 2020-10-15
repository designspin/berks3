//
//  BerkEntity.swift
//  idiots
//
//  Created by Jason Foster on 14/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

enum EntityDirection: UInt32 {
    case up
    case down
    case left
    case right
    
    var vector: CGVector {
        switch self {
        case .up:
            return CGVector(dx: 0, dy: 1)
        case .down:
            return CGVector(dx: 0, dy: -1)
        case .left:
            return CGVector(dx: -1, dy: 0)
        case .right:
            return CGVector(dx: 1, dy: 0)
        }
    }
    
    var oppositeVector: CGVector {
        switch self {
        case .up:
            return CGVector(dx: 0, dy: -1)
        case .down:
            return CGVector(dx: 0, dy: 1)
        case .left:
            return CGVector(dx: 1, dy: 0)
        case .right:
            return CGVector(dx: -1, dy: 0)
        }
    }
    
    var opposite: EntityDirection {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        }
    }
    
    private static let _count: EntityDirection.RawValue = {
        var maxValue: UInt32 = 0
        while let _ = EntityDirection(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func randomDirection() -> EntityDirection {
        let rand = arc4random_uniform(_count)
        return EntityDirection(rawValue: rand)!
    }
}

protocol BerkEntityManager: class {
    var berkState: GKStateMachine! { get set }
    var constrain: SKConstraint? { get set }
}

class BerkEntity: GKEntity, BerkEntityManager, ContactNotifiableType {
    var anims: [String: Array<String>]!
    var normals: [String: Array<String>]!
    var berkState: GKStateMachine!
    var constrain: SKConstraint?
    var color: vector_float4!
    weak var entityManager:EntityManager!
    
    static var shader:SKShader = {
        let shader = SKShader(fileNamed: "berk.fsh")
        shader.attributes = [
            SKAttribute(name: "u_color", type: .vectorFloat4)
        ]
        return shader
    }()
    
    static let berkHit:SKAction = {
        if GameGlobals.instance.playSound {
            return SKAction.playSoundFileNamed("berkHit.wav", waitForCompletion: false)
        } else {
            return SKAction()
        }
    }()
    
    init(location: CGPoint, entityManager: EntityManager) {
        super.init()
        self.entityManager = entityManager
        let atlas = SKTextureAtlas(named: "berks")
        
        berkState = GKStateMachine(states: [
               BerkMovingUp(withEntity: self),
               BerkMovingDown(withEntity: self),
               BerkMovingLeft(withEntity: self),
               BerkMovingRight(withEntity: self),
               BerkDestroyed(withEntity: self),
               //BerkCollidingState(withEntity: self),
               //BerkChangingDirection(withEntity: self)
        ])
        
    
        anims = ["horizontal": ["berk_h_1", "berk_h_2", "berk_h_1", "berk_h_3"], "vertical": ["berk_v_1", "berk_v_2", "berk_v_1", "berk_v_3"]]
        
        let spriteComponent = SpriteComponent(texture: atlas.textureNamed(anims["horizontal"]![2]))
        spriteComponent.node.position = location
        
        
        color = EntityColor.randomUiColor().vec
        spriteComponent.node.shader = BerkEntity.shader
        spriteComponent.node.setValue(SKAttributeValue(vectorFloat4: color),
                        forAttribute: "u_color")
        addComponent(spriteComponent)
        
        let ph = SKPhysicsBody(circleOfRadius: spriteComponent.node.size.width / 2)
        let physicsComponent = PhysicsComponent(physicsBody: ph, colliderType: .Enemy)
        addComponent(physicsComponent)
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
        spriteComponent.node.physicsBody?.restitution = 0
        spriteComponent.node.physicsBody?.mass = 0
        spriteComponent.node.physicsBody?.friction = 0
        spriteComponent.node.physicsBody?.allowsRotation = false
        spriteComponent.node.physicsBody?.affectedByGravity = false
        
        let animComponent = AnimComponent(atlas: atlas, anims: anims, defaultAnim: "horizontal")
        addComponent(animComponent)
        
        let berkMove = BerkMoveComponent(entityManager: entityManager)
        addComponent(berkMove)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func die() {
        removeComponent(ofType: BerkMoveComponent.self)
        removeComponent(ofType: AnimComponent.self)
        
        
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            weak var accessEntityManager  = spriteComponent.node.scene as? GameScene
            
            spriteComponent.node.removeAllActions()
            
            
            let action = SKAction.run{
                spriteComponent.node.setValue(SKAttributeValue(vectorFloat4: vector4(1.0, 1.0, 1.0, 1.0)),
                                              forAttribute: "u_color")
            }
            
            let actionb = SKAction.run{[unowned self] in
                spriteComponent.node.setValue(SKAttributeValue(vectorFloat4: self.color),
                                              forAttribute: "u_color")
            }
            
            let waitAction = SKAction.wait(forDuration: 0.05)
            
            let removeAction = SKAction.run{[unowned self] in
                accessEntityManager?.entityManager.remove(entity: self)
                GameGlobals.instance.score += 500
            }
            
            let sequence = SKAction.sequence([action, waitAction, actionb, waitAction])
            let repeatAction = SKAction.repeat(sequence, count: 10)
            
            let finalSequence = SKAction.sequence([BerkEntity.berkHit, repeatAction, removeAction])
            
            
            spriteComponent.node.run(finalSequence)
        }
        
        
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if entity.isKind(of: LazerEntity.self) {
            self.berkState.enter(BerkDestroyed.self)
        } else {
            if let berkMoveComponent = component(ofType: BerkMoveComponent.self) {
                berkMoveComponent.newDirection(contactPoint: contactPoint)
            }
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        if let berkMoveComponent = component(ofType: BerkMoveComponent.self) {
            berkMoveComponent.collisionEnd(collidedEntity: entity, contactPoint: contactPoint)
        }
    }
}
