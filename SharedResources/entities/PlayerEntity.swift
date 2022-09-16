//
//  PlayerEntity.swift
//  idiots
//
//  Created by Jason Foster on 17/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

protocol PlayerEntityManager: AnyObject {
    var playerState: GKStateMachine! { get set }
    
    func didEnterInvincibleState()
    func toggleArmedState()
}
class PlayerEntity: GKEntity, ContactNotifiableType, PlayerEntityManager {
    
    static let anims = ["idle": ["tank0"], "closed": ["tank5"], "opening": ["tank5", "tank4", "tank3", "tank2", "tank1", "tank0"], "closing": ["tank0","tank1","tank2","tank3","tank4","tank5"]]
    
    static let atlas = SKTextureAtlas(named: "berks")
    
    static let bumpSound:SKAction = {
        if GameGlobals.instance.playSound {
            return SKAction.playSoundFileNamed("bump.wav", waitForCompletion: true)
        } else {
            return SKAction()
        }
    }()
    
    var playerState: GKStateMachine!
    var isInvincible = false
    var isArmed = false
    var isClosed = false
    var isMoving = false
    var smallCollisionRect:CGSize!
    var largeCollisionRect:CGSize!
    var smallPhysicsComponent:PhysicsComponent!
    var largePhysicsComponent:PhysicsComponent!
    var lastSpawnPoint:CGPoint!
    
    #if os(iOS) || os(tvOS) || os(watchOS)
     typealias Color = UIColor
    #elseif os(OSX)
     typealias Color = NSColor
    #endif
    
    init(location: CGPoint) {
        super.init()
        
        lastSpawnPoint = location
        
        playerState = GKStateMachine(states: [
            PlayerInvincibleState(withEntity: self),
            PlayerIdleState(withEntity: self),
            PlayerArmedState(withEntity: self),
            PlayerMovingState(withEntity: self),
        ])
        
        
        let spriteComponent = SpriteComponent(texture: PlayerEntity.atlas.textureNamed("tank0"))
        spriteComponent.node.position = location
        addComponent(spriteComponent)
        
        largeCollisionRect = spriteComponent.node.size
        smallCollisionRect = CGSize(width: largeCollisionRect.width - 13, height: largeCollisionRect.height - 13)
        
        largePhysicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: largeCollisionRect), colliderType: .Player)
        largePhysicsComponent.physicsBody.friction = 1
        largePhysicsComponent.physicsBody.restitution = 1
        largePhysicsComponent.physicsBody.linearDamping = 20
        
        smallPhysicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: smallCollisionRect), colliderType: .Player)
        smallPhysicsComponent.physicsBody.friction = 1
        smallPhysicsComponent.physicsBody.restitution = 1
        smallPhysicsComponent.physicsBody.linearDamping = 20
        
        addComponent(largePhysicsComponent)
        spriteComponent.node.physicsBody = largePhysicsComponent.physicsBody
        spriteComponent.node.physicsBody?.allowsRotation = false
        
        let animComponent = AnimComponent(atlas: PlayerEntity.atlas, anims: PlayerEntity.anims, defaultAnim: "idle")
        addComponent(animComponent)
        
        let controlledComponent = ControlledComponent()
        addComponent(controlledComponent)
        
        playerState.enter(PlayerInvincibleState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit player")
    }
    
    func closeTank() {
        if let animComponent = component(ofType: AnimComponent.self) {
            animComponent.runAnimation(name: "closing", timePerFrame: 0.04) 
        }
        
        removeComponent(ofType: PhysicsComponent.self)
        
        addComponent(smallPhysicsComponent)
        
        let spriteComponent = component(ofType: SpriteComponent.self)
        spriteComponent?.node.physicsBody = smallPhysicsComponent.physicsBody
        spriteComponent?.node.physicsBody?.allowsRotation = false
        
        isClosed = true
    }
    
    func openTank() {
        if let animComponent = component(ofType: AnimComponent.self) {
            animComponent.runAnimation(name: "opening", timePerFrame: 0.04)
        }
        
        removeComponent(ofType: PhysicsComponent.self)
        
        addComponent(largePhysicsComponent)
        
        let spriteComponent = component(ofType: SpriteComponent.self)
        spriteComponent?.node.physicsBody = largePhysicsComponent.physicsBody
        spriteComponent?.node.physicsBody?.allowsRotation = false
        
        isClosed = false
    }
    
    func startMoving() {
        isMoving = true
        
        if(!isArmed) {
            closeTank()
        }
    }
    
    func stopMoving() {
        isMoving = false
    
        if(isClosed) {
            openTank()
        }
    }
    
    func updateRespawnPoint() {
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            self.lastSpawnPoint = spriteComponent.node.position
        }
    }
    
    func roomFromLocation() -> Int {
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            let row:CGFloat = floor( -spriteComponent.node.position.y / 352 ) + 5
            let col:CGFloat = ceil( spriteComponent.node.position.x / 640 )
            return Int(row * 6 + col)
        }
        return 1
    }
    
    func velocityUpdate(vel: CGVector, ang: CGFloat) {
        var velocity: CGVector
        
        if(!isArmed) {
            velocity = CGVector(dx: vel.dx * 120, dy: vel.dy * 120)
        } else {
            velocity = CGVector.zero
        }
        component(ofType: ControlledComponent.self)?.vel = velocity
    }
    
    // MARK: Collision Handling
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if entity.isKind(of: EdgeTileEntity.self) {
            if let controlledComponent = component(ofType: ControlledComponent.self) {
                if let spriteComponent = component(ofType: SpriteComponent.self) {
                    let dir = controlledComponent.vel
                    let vector = CGVector(dx: ((dir.dx / 120) * -1) * 6, dy: ((dir.dy / 120) * -1) * 6)
                    spriteComponent.node.physicsBody?.applyImpulse(vector, at: spriteComponent.node.position)
                    spriteComponent.node.run(PlayerEntity.bumpSound)
                }
            }
            
            if GameGlobals.instance.score > 5 {
                GameGlobals.instance.score -= 5
            } else {
                GameGlobals.instance.score = 0
            }
        }
        
        if entity.isKind(of: DroneEntity.self) || entity.isKind(of: BerkEntity.self) || entity.isKind(of: BrickTileEntity.self) || entity.isKind(of: DoorEntity.self) {
            if !isInvincible {
                if let spriteComponent = component(ofType: SpriteComponent.self) {
                    spriteComponent.node.removeAllActions()
                    weak var scene = spriteComponent.node.scene as? GameScene
                    scene?.shakeCamera(duration: 2)
                }
                removeComponent(ofType: ControlledComponent.self)
                removeComponent(ofType: PhysicsComponent.self)
                addComponent(ExplodeComponent())
            }
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
    
    func toggleInvincibility() {
        isInvincible = !isInvincible
    }
    
    func toggleArmedState() {
        isArmed = !isArmed
        
        if(isArmed && isClosed) {
            openTank()
        }
        
        if(!isArmed && isMoving) {
            closeTank()
        }
    }
    
    func didEnterInvincibleState() {
        if !isInvincible {
            toggleInvincibility()
        }
        
        let spriteComponent = component(ofType: SpriteComponent.self)
        spriteComponent?.node.removeAllActions()
        let a = SKAction.colorize(with: Color.white, colorBlendFactor: 1, duration: 0.2)
        let b = SKAction.colorize(with: Color.black, colorBlendFactor: 0, duration: 0.2)
        let seq = SKAction.sequence([a,b])
        let rep = SKAction.repeat(seq, count: 8)
        let block = SKAction.run{
            [unowned self] in self.toggleInvincibility()
        }
        spriteComponent?.node.run(SKAction.sequence([rep, block]))
        
    }
    
    
}
