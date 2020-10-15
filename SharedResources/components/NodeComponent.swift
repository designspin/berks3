//
//  NodeComponent.swift
//  idiots
//
//  Created by Jason Foster on 29/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

class NodeComponent: GKComponent {
    let node:SKNode
    
    override init() {
        node = SKNode()
        super.init()
    }
    
    init(position: CGPoint) {
        node = SKNode()
        node.position = position
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
