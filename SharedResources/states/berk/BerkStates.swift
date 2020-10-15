//
//  BerkUpState.swift
//  idiots
//
//  Created by Jason Foster on 16/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

//MARK: Moving UP

class BerkMovingUp: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        
        unowned let entity = berk as! BerkEntity;
        let node = entity.component(ofType: SpriteComponent.self)!.node
        let pos = node.position
        //berk.availableDirections = [.right,.down,.left]
        //berk.currentDirection = .up
        entity.constrain = SKConstraint.positionX(SKRange(constantValue: pos.x))
    }
}

//MARK: Moving Down State

class BerkMovingDown: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        
        unowned let entity = berk as! BerkEntity;
        let node = entity.component(ofType: SpriteComponent.self)!.node
        let pos = node.position
        //berk.availableDirections = [.right,.left,.up]
        //berk.currentDirection = .down
        entity.constrain = SKConstraint.positionX(SKRange(constantValue: pos.x))
    }
}

//MARK: Moving Right State

class BerkMovingRight: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        
        unowned let entity = berk as! BerkEntity;
        let node = entity.component(ofType: SpriteComponent.self)!.node
        let pos = node.position
        //berk.availableDirections = [.left,.down,.up]
        //berk.currentDirection = .right
        entity.constrain = SKConstraint.positionY(SKRange(constantValue: pos.y))
    }
}

//MARK: Moving Left State

class BerkMovingLeft: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        
        unowned let entity = berk as! BerkEntity
        let node = entity.component(ofType: SpriteComponent.self)!.node
        let pos = node.position
        //berk.availableDirections = [.right,.down,.up]
        //berk.currentDirection = .left
        entity.constrain = SKConstraint.positionY(SKRange(constantValue: pos.y))
    }
}

//MARK: Changing Direction

/*class BerkChangingDirection: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Entering BerkChangingDirection State")
        berk.changeDirection()
    }
}*/

//MARK: Destroyed State

class BerkDestroyed: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        unowned let entity = berk as! BerkEntity
        
        if let state = previousState {
            if(!state.isKind(of: BerkDestroyed.self)) {
                entity.die()
            }
        }
    }
}

//MARK: Colliding

/*class BerkCollidingState: GKState {
    weak var berk: BerkEntityManager!
    
    init(withEntity: GKEntity) {
        berk = withEntity as? BerkEntityManager
    }
    
    override func didEnter(from previousState: GKState?) {
        let berkEntity = berk as! BerkEntity
        print("Entering BerkCollidingState")
        if(previousState?.isKind(of: BerkCollidingState.self))! {
            print("Entering from same state")
           // berkEntity.move(direction: (berkEntity.currentDirection?.oppositeVector)!)
            berkEntity.currentDirection = berkEntity.currentDirection?.opposite
        } else {
            //berkEntity.move(direction: (berkEntity.currentDirection?.oppositeVector)!)
            //berkEntity.currentDirection = berkEntity.currentDirection?.opposite
            berkEntity.berkState.enter(BerkChangingDirection.self)
        }
        
        
    }
}*/
