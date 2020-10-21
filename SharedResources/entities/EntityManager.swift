//
//  EntityManager.swift
//  idiots
//
//  Created by Jason Foster on 17/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class EntityManager {
    let scene: SKScene
    
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    var hidden = Set<GKEntity>()
    var playerEntity:GKEntity?
    
    lazy var componentSystems: [GKComponentSystem] = {
        let animSystem = GKComponentSystem(componentClass: AnimComponent.self)
        let controlledSystem = GKComponentSystem(componentClass: ControlledComponent.self)
        let berkMoveSystem = GKComponentSystem(componentClass: BerkMoveComponent.self)
        let droneMoveSystem = GKComponentSystem(componentClass: DroneMoveComponent.self)
        
        return [controlledSystem, berkMoveSystem, droneMoveSystem, animSystem]
    }()
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    deinit {
        print("Deinit Entity Manager")
    }
    
    func add(entity: GKEntity) {
        entities.insert(entity)
        
        if entity.isKind(of: PlayerEntity.self) {
            playerEntity = entity
        }
        
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            scene.addChild(spriteNode)
        }
        
        if let node = entity.component(ofType: NodeComponent.self)?.node {
            scene.addChild(node)
        }
        
        for componentSystem in componentSystems {
            
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    func updateForComponent(entity: GKEntity) {
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    func add(to targetEntity: GKEntity, entity: GKEntity) {
        entities.insert(entity)
        
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            if let targetSpriteNode = targetEntity.component(ofType: SpriteComponent.self)?.node {
                targetSpriteNode.addChild(spriteNode)
            }
        }
        
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    func remove(entity: GKEntity) {
        
        for componentSystem in componentSystems {
            componentSystem.removeComponent(foundIn: entity)
        }
        
        if entity.isKind(of: PlayerEntity.self) {
            playerEntity = nil
        }
        
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeAllActions()
            spriteNode.removeFromParent()
        }
        
        if let node = entity.component(ofType: NodeComponent.self)?.node {
            node.removeAllActions()
            node.removeFromParent()
        }
        
        toRemove.insert(entity)
        entities.remove(entity)
    }
    
    func removeAll() {
        for entity in entities {
            remove(entity: entity)
        }
    }
    
    func update(deltaTime: TimeInterval) {
        
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        for curRemove in toRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: curRemove)
            }
        }
        
        toRemove.removeAll()
    }
    
    func berkEntities() -> [GKAgent2D] {
        for componentSystem in componentSystems {
            if componentSystem.componentClass is BerkMoveComponent.Type {
                let components = componentSystem.components
                
                return components.compactMap{ component in
                    return component as? GKAgent2D
                }
            }
        }
        return []
    }
    
    func droneEntities() -> [GKAgent2D] {
        for componentSystem in componentSystems {
            if componentSystem.componentClass is DroneMoveComponent.Type {
                let components = componentSystem.components
                
                return components.compactMap{ component in
                    return component as? GKAgent2D
                }
            }
        }
        return []
    }
    
    /*func droneEntities() -> [WeakRef<GKAgent2D>] {
        for componentSystem in componentSystems {
            if componentSystem.componentClass is DroneMoveComponent.Type {
                let components = componentSystem.components
                
                return components.flatMap{ component in
                    return WeakRef(component as? GKAgent2D)
                }
            }
        }
        return []
    }*/
    
    func hideEntitiesOutsideRect(rect: CGRect) {
        for entity in hidden {
            if let nodeComponent = entity.component(ofType: NodeComponent.self) {
                scene.addChild(nodeComponent.node)
            }
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                scene.addChild(spriteComponent.node)
            }
        }
        
        hidden.removeAll()
        
        for entity in entities {
//            if entity.isKind(of: EdgeTileEntity.self) {
//                if let nodeComponent = entity.component(ofType: NodeComponent.self) {
//                    if(!rect.contains(nodeComponent.node.position)) {
//                        nodeComponent.node.removeFromParent()
//                        hidden.insert(entity)
//                    }
//                }
//            }
            if entity.isKind(of: BrickTileEntity.self) || entity.isKind(of: KeyEntity.self) || entity.isKind(of: LifeEntity.self) {
                if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                    if(!rect.contains(spriteComponent.node.position)) {
                        spriteComponent.node.removeFromParent()
                        hidden.insert(entity)
                    }
                }
            }
        }
    }
}
