//
//  BerkMoveComponent.swift
//  idiots
//
//  Created by Jason Foster on 25/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

class BerkMoveComponent: GKAgent2D, GKAgentDelegate {
    
    var availableDirections:Set<EntityDirection> = [.left, .right, .up, .down]
    var currentDirection = EntityDirection.randomDirection()
    var lastPosition:CGPoint?
    var lastContact:CGPoint?
    
    weak var entityManager: EntityManager?
    
    init(entityManager: EntityManager) {
        super.init()
        delegate = self
        self.radius = 16
        
        let berkEntities = entityManager.berkEntities().filter{ $0 != self}
        behavior = BerkBehaviour(avoid: berkEntities)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddToEntity() {
        let entity = self.entity as! BerkEntity
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            self.lastPosition = spriteComponent.node.position
        }
        
        updateDirection()
        move()
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        position = vector_float2(Float(spriteComponent.node.position.x), Float(spriteComponent.node.position.y))
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        
        spriteComponent.node.position = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
    
    func updateDirection() {
        let entity = self.entity as! BerkEntity
        
        if(currentDirection == .up) {
            entity.berkState.enter(BerkMovingUp.self)
        }
        
        if(currentDirection == .down) {
            entity.berkState.enter(BerkMovingDown.self)
        }
        
        if(currentDirection == .left) {
            entity.berkState.enter(BerkMovingLeft.self)
        }
        
        if(currentDirection == .right) {
            entity.berkState.enter(BerkMovingRight.self)
        }
    }
    
    func newDirection(contactPoint: CGPoint) {
        let entity = self.entity as! BerkEntity
        
        var directionsNotAllowed = [EntityDirection]()
        lastContact = contactPoint
    
        if let entityPos = entity.component(ofType: SpriteComponent.self) {
            
            /*let physicsWorld = entityPos.node.scene?.physicsWorld
            let x = entityPos.node.position.x
            let y = entityPos.node.position.y
            let width = entityPos.node.size.width
            let height = entityPos.node.size.height
            
            let nodesAbove = physicsWorld?.body(in: CGRect(x: x, y: y + height, width: width, height: height))
            print("Nodes above: \(String(describing: nodesAbove))")
            
            let nodesBelow = physicsWorld?.body(in: CGRect(x: x, y: y - height, width: width, height: height))
            print("Nodes below: \(String(describing: nodesBelow))")
            
            let nodesLeft = physicsWorld?.body(in: CGRect(x: x - width, y: y, width: width, height: height))
            print("Nodes left: \(String(describing: nodesLeft))")
            
            let nodesRight = physicsWorld?.body(in: CGRect(x: x + width, y: y, width: width, height: height))
            print("Nodes right: \(String(describing: nodesRight))")
            
            let nodesAboveCount = nodesAbove != nil ? true : false
            let nodesBelowCount = nodesBelow != nil ? true : false
            let nodesLeftCount = nodesLeft != nil ? true : false
            let nodesRightCount = nodesRight != nil ? true : false*/
            
            if(contactPoint.x < entityPos.node.position.x /* || nodesLeftCount */ ) {
                //availableDirections = availableDirections.filter{$0 != .left}
                directionsNotAllowed.append(.left)
            }
            if(contactPoint.x > entityPos.node.position.x /* || nodesRightCount */ ) {
                //availableDirections = availableDirections.filter{$0 != .right}
                directionsNotAllowed.append(.right)
            }
            if(contactPoint.y > entityPos.node.position.y /* || nodesAboveCount */ ) {
                //availableDirections = availableDirections.filter{$0 != .up}
                directionsNotAllowed.append(.up)
            }
            if(contactPoint.y < entityPos.node.position.y /* || nodesBelowCount */ ) {
                //availableDirections = availableDirections.filter{$0 != .down}
                directionsNotAllowed.append(.down)
            }
        }
        
        for dir in directionsNotAllowed {
            availableDirections = availableDirections.filter{$0 != dir}
        }
    
        setDirection()
        updateDirection()
        move()
    }
    
    func setDirection() {
        let rand = Int(arc4random_uniform(UInt32(availableDirections.count)))
        let index = availableDirections.index(availableDirections.startIndex, offsetBy: rand)
        
        if(availableDirections.count > 0) {
            currentDirection = availableDirections[index]
        } else {
            currentDirection = EntityDirection.randomDirection()
        }
    }
    
    func collisionEnd(collidedEntity: GKEntity, contactPoint: CGPoint) {
        availableDirections = [.left, .right, .up, .down]
    }
    
    func move() {
        let entity = self.entity as! BerkEntity
        let dir = currentDirection
        
        if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
            let node = spriteComponent.node
            
            node.removeAllActions()
            
            let moveaction = SKAction.moveBy(x: dir.vector.dx * CGFloat(4 + GameGlobals.instance.currentDifficulty.rawValue), y: dir.vector.dy * CGFloat(4 + GameGlobals.instance.currentDifficulty.rawValue), duration: 0.1)
            let waitaction = SKAction.wait(forDuration: 0.1)
            
            let sequence = SKAction.sequence([moveaction, waitaction])
            
            let seqRepeat = SKAction.repeat(sequence, count: 2)
            
            let checkAction = SKAction.run {[unowned self] in
                if let spriteComponent = self.entity?.component(ofType: SpriteComponent.self) {
                    if let lastPos = self.lastContact {
                        let xDist:CGFloat = (lastPos.x - spriteComponent.node.position.x)
                        let yDist:CGFloat = (lastPos.y - spriteComponent.node.position.y)
                        let distance:CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
                        
                        if distance < 32 {
                            let avail:Set<EntityDirection> = [.left, .right, .up, .down]
                            self.availableDirections = avail.filter{$0 != self.currentDirection}
                            self.newDirection(contactPoint: lastPos)
                        }
                    }
                }
            }
            
            let sequenceCheck = SKAction.sequence([seqRepeat,checkAction])
            
            let groupAction = SKAction.group([sequenceCheck])
            let repeataction = SKAction.repeat(groupAction, count: Int(arc4random_uniform(6) + 20))
            let action = SKAction.run {[unowned self] in
                self.setDirection()
                self.move()
            }
            let finalSequence = SKAction.sequence([repeataction, action])
            node.run(finalSequence)
        }
        
        if let animComponent = entity.component(ofType: AnimComponent.self) {
            switch dir {
            case .up:
                animComponent.repeatRunAnimation(name: "vertical", timePerFrame: 0.1)
            case .down:
                animComponent.repeatRunAnimationReverse(name: "vertical", timePerFrame: 0.1)
            case .left:
                animComponent.repeatRunAnimation(name: "horizontal", timePerFrame: 0.1)
            case .right:
                animComponent.repeatRunAnimationReverse(name: "horizontal", timePerFrame: 0.1)
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
}
