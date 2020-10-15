//
//  SpriteComponent.swift
//  idiots
//
//  Created by Jason Foster on 17/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class SpriteComponent: GKComponent {
    let node:SKSpriteNode
    
    init(texture: SKTexture) {
        node = SKSpriteNode(texture: texture, color: SKColor.clear, size: texture.size())
        
        super.init()
    }
    
    init(spriteNode: SKSpriteNode) {
        node = spriteNode
        super.init()
    }
    
    override func didAddToEntity() {
    
        node.entity = entity
       
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
