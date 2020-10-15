//
//  ExplodeComponent.swift
//  idiots
//
//  Created by Jason Foster on 23/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class ExplodeComponent: GKComponent {
    
    override func didAddToEntity() {
        let entity = self.entity as! PlayerEntity
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            if let explosionEmitter = SKEmitterNode(fileNamed: "explosion") {
                let scene = spriteComponent.node.scene as? GameScene
                
                #if os(iOS) || os(tvOS) || os(watchOS)
                scene?.ctrl.disabled = true
                scene?.fireBtn.disabled = true
                #endif
                
                explosionEmitter.position = spriteComponent.node.position
                explosionEmitter.name = "PlayerExplosion"
                spriteComponent.node.scene?.addChild(explosionEmitter)
                spriteComponent.node.physicsBody = nil
                
                let soundAction = SKAction.playSoundFileNamed("playerExplosion.wav", waitForCompletion: false)
                let waitAction = SKAction.wait(forDuration: 2)
                
                let actionBlock = SKAction.run {
                    if let node = spriteComponent.node.scene?.childNode(withName: "PlayerExplosion") {
                        node.removeFromParent()
                    }
                    entity.removeComponent(ofType: ExplodeComponent.self)
                }
                let sequenceAction = SKAction.sequence([soundAction, waitAction, actionBlock])
                
                spriteComponent.node.scene?.run(sequenceAction)
                spriteComponent.node.alpha = 0
            }
        }
    }
    
    override func willRemoveFromEntity() {
        let entity = self.entity as! PlayerEntity
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            if let explosion = spriteComponent.node.scene?.childNode(withName: "PlayerExplosion") {
                explosion.removeFromParent()
            }
            spriteComponent.node.position = entity.lastSpawnPoint
        }
        
        let GameSceneManager = entity.component(ofType: SpriteComponent.self)?.node.scene as! GameSceneManager
        GameSceneManager.sceneState.enter(SceneLoseLifeState.self)
    }
}
