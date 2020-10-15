//
//  LazerEntity.swift
//  idiots
//
//  Created by Jason Foster on 05/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//
import SpriteKit
import GameKit

class LazerEntity: GKEntity, ContactNotifiableType {
    
    static let laserTexture = SKTextureAtlas(named: "berks").textureNamed("lazer")
    
    static let laserSound:SKAction = {
        if GameGlobals.instance.playSound {
            return SKAction.playSoundFileNamed("lazer.wav", waitForCompletion: false)
        } else {
            return SKAction()
        }
    }()
    
    init(location: CGPoint, angle: CGFloat) {
        super.init()
        let x = -sin(angle) * 500
        let y = cos(angle) * 500
        let vel = CGVector(dx: x, dy: y)
        let action = SKAction.move(by: vel, duration: TimeInterval(1))
        let loop = SKAction.repeatForever(action)
        
        let sequence = SKAction.sequence([LazerEntity.laserSound, loop])
        let spriteComponent = SpriteComponent(texture: LazerEntity.laserTexture)
        
        addComponent(spriteComponent)
        
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 21), center: spriteComponent.node.position), colliderType: .Lazer)
        addComponent(physicsComponent)
        
        spriteComponent.node.position = location
        spriteComponent.node.zRotation = angle
        spriteComponent.node.run(sequence)
        spriteComponent.node.physicsBody = physicsComponent.physicsBody
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        
        /*if entity.isKind(of: EdgeTileEntity.self) {
            if let spriteComponent = component(ofType: SpriteComponent.self) {
                if let emitter = SKEmitterNode(fileNamed: "lazerSpark") {
                    weak var scene = spriteComponent.node.scene as? GameScene
                    
                    emitter.position = spriteComponent.node.position
                    emitter.name = "LazerSpark"
                    scene?.addChild(emitter)
                    
                    let waitAction = SKAction.wait(forDuration: 0.3)
                    let removeAction = SKAction.run {
                        emitter.removeFromParent()
                    }
                    let sequenceActions = SKAction.sequence([waitAction,removeAction])
                    
                    emitter.run(sequenceActions)
                }
            }
        }*/
        
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            weak var accessEntityManager  = spriteComponent.node.scene as? GameScene
            
            accessEntityManager?.entityManager.remove(entity: self)
        }
        
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
