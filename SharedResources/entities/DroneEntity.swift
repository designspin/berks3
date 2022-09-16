//
//  DroneEntity.swift
//  idiots
//
//  Created by Jason Foster on 19/03/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

protocol DroneEntityProtocol: AnyObject {
    var entityMg: EntityManager {get set}
    var droneState: GKStateMachine! {get set}
    
    func seek()
    
    func stunned()
}

class DroneEntity: GKEntity, DroneEntityProtocol, ContactNotifiableType {
    var anims: [String: Array<String>]!
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    var color: UIColor!
    #elseif os(OSX)
    var color: NSColor!
    #endif
    
    var droneState: GKStateMachine!
    unowned var entityMg: EntityManager
    
    static let droneStunned:SKAction = {
        if GameGlobals.instance.playSound {
            return SKAction.playSoundFileNamed("droneHit", waitForCompletion: false)
        } else {
            return SKAction()
        }
    }()
    
    init(location: CGPoint, entityManager: EntityManager) {
        entityMg = entityManager
        super.init()
        
        droneState = GKStateMachine(states: [
            DroneStunnedState(withEntity: self),
            DroneSeekingState(withEntity: self),
        ])
        
        // 1:["drones":[1,2,3,4,5],"drone_type":["drone_a_1","drone_a_2"]],
        
        let atlas = SKTextureAtlas(named: "berks")
        let roomData  = GameGlobals.instance.mapData[GameGlobals.instance.room]
        let stunned = roomData!["drone_type"] as! Array<String>
        let normal = [stunned.first!]
        
        anims = ["stunned": stunned, "normal": normal]
        color = EntityColor.randomUiColor().ui
        
        //Sprite
        let spriteComponent = SpriteComponent(texture: atlas.textureNamed(anims["normal"]![0]))
        spriteComponent.node.color = color
        spriteComponent.node.colorBlendFactor = 1
        spriteComponent.node.position = location
        addComponent(spriteComponent)
        
        //Physics
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: -16, y:0), CGPoint(x: 0, y:16), CGPoint(x: 16, y: 0), CGPoint(x: 0, y: -16)])
        path.closeSubpath()
        let phbody = SKPhysicsBody(polygonFrom: path)
        let physicComponent = PhysicsComponent(physicsBody: phbody, colliderType: .Enemy)
        physicComponent.physicsBody.allowsRotation = false
        addComponent(physicComponent)
        spriteComponent.node.physicsBody = physicComponent.physicsBody
        
        //Anim
        let animComponent = AnimComponent(atlas: atlas, anims: anims, defaultAnim: "normal")
        addComponent(animComponent)
        
        droneState.enter(DroneStunnedState.self)
        
    }
    
    func stunned() {
        
        if let _ = component(ofType: DroneMoveComponent.self) {
            removeComponent(ofType: DroneMoveComponent.self)
        }
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            spriteComponent.node.physicsBody?.isDynamic = false
        }
        
        let animAction = component(ofType: AnimComponent.self)?.getRunAnimation(name: "stunned", timePerFrame: 0.1)
        let repeatAction = SKAction.repeat((animAction ?? nil)!, count: 30)
        let moveAction = SKAction.run{[unowned self] in
            self.droneState.enter(DroneSeekingState.self)
        }
        let sequence = SKAction.sequence([repeatAction, moveAction])
        let finalsequence = SKAction.sequence([DroneEntity.droneStunned,sequence])
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            spriteComponent.node.run(finalsequence)
        }
    }
    
    func seek() {
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            spriteComponent.node.physicsBody?.isDynamic = true
        }
        let moveComponent = DroneMoveComponent(entityManager: self.entityMg)
        self.addComponent(moveComponent)
        entityMg.updateForComponent(entity: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if entity.isKind(of: LazerEntity.self) {
            if !(self.droneState.currentState is DroneStunnedState) {
                GameGlobals.instance.score += 10
                self.droneState.enter(DroneStunnedState.self)
            }
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
}
