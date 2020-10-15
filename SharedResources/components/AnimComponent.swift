//
//  AnimComponent.swift
//  idiots
//
//  Created by Jason Foster on 19/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class AnimComponent: GKComponent {
    var animations = [String: [SKTexture]]()
    
    init(atlas: SKTextureAtlas, anims: Dictionary<String, Array<String>>, defaultAnim: String) {
        for (animName, animFrames) in anims {
            
            var texturelist = animations[animName] ?? []
            
            for animFrame in animFrames {
                
                texturelist.append(atlas.textureNamed(animFrame))
            }
            
            animations[animName] = texturelist
        }
        super.init()
    }
    
    func runAnimation(name:String, timePerFrame:TimeInterval) {
        if let entity = self.entity {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                let node = spriteComponent.node
                
                let animation = SKAction.animate(with: animations[name]!, timePerFrame: timePerFrame)
                node.run(animation)
            }
        }
    }
    
    func getRunAnimation(name:String, timePerFrame:TimeInterval) -> SKAction {
        return SKAction.animate(with: animations[name]!, timePerFrame: timePerFrame)
    }
    
    func repeatRunAnimation(name:String, timePerFrame:TimeInterval) {
        if let entity = self.entity {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                let node = spriteComponent.node
                
                let animation = SKAction.animate(with: animations[name]!, timePerFrame: timePerFrame)
                let loop = SKAction.repeatForever(animation)
                node.run(loop)
            }
        }
    }
    
    func repeatRunAnimationReverse(name:String, timePerFrame:TimeInterval) {
        if let entity = self.entity {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                let node = spriteComponent.node
                
                let animation = SKAction.animate(with: animations[name]!.reversed(), timePerFrame: timePerFrame)
                let loop = SKAction.repeatForever(animation)
                node.run(loop)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
