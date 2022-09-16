//
//  GameScene.swift
//  idiots
//
//  Created by Jason Foster on 14/11/2017.
//  Copyright © 2017 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit
import GameplayKit
import GameController

protocol GameSceneManager: AnyObject {
    var sceneState: GKStateMachine! { get set }
    var player:PlayerEntity! { get set }
    var entityManager:EntityManager! { get set }
    func roomChange(to:Int, from:Int)
    func controllerSetup()
    func didLoseLife()
    func didCompleteScene()
    func didPauseScene()
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneManager {
    
    weak var gamemanager: GameManager!
    
    // Monitor game controller
    var snapshot:Any?
    var previousSnapShot:Any?
    
    var sceneState: GKStateMachine!
    var cam: SKCameraNode!
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    var ctrl: AnalogJoystick!
    var fireBtn: FireButton!
    #endif
    
    #if os(OSX)
    var keyPresses: Dictionary<String, Bool> = ["FIRE": false, "UP": false, "RIGHT": false, "DOWN": false, "LEFT": false]
    var previousKeyPresses: Dictionary<String, Bool> = ["FIRE": false, "UP": false, "RIGHT": false, "DOWN": false, "LEFT": false]
    #endif
    
    var lastProjectile:TimeInterval = 0
    var entityManager: EntityManager!
    var dt:TimeInterval = 0
    var player:PlayerEntity!
    var projectileDataPosition:CGPoint?
    var projectileDataAngle:CGFloat?
    var visibleRect = CGRect(x: 0, y: 1410, width: 640, height: 352)
    var boundary:BoundaryEntity!
    private var lastUpdateTime : TimeInterval = 0
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    var fingers = [UITouch?](repeating: nil, count: 2)
    #endif
    
    #if os(iOS) || os(tvOS) || os(watchOS)
        typealias Color = UIColor
    #elseif os(OSX)
        typealias Color = NSColor
    #endif

    // MARK: Init
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Setup StateMachine
        
        sceneState = GKStateMachine(states: [
            ScenePlayingState(withScene: self),
            SceneChangeRoomState(withScene: self),
            SceneLoseLifeState(withScene: self),
            SceneCompletedState(withScene: self),
            ScenePausedState(withScene: self)
        ])
        
        // Set physics props and delegate
        
        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.contactDelegate = self
        
        // MARK: Setup Collider types
        
        ColliderType.definedCollisions[.Player] = [
            .Obstacle,
            .Enemy,
            .Collectable
        ]
        
        ColliderType.definedCollisions[.Lazer] = [
            .Obstacle,
            .Enemy,
            .Boundary
        ]
        
        ColliderType.definedCollisions[.Enemy] = [
            .Obstacle,
            .Enemy,
            .Boundary,
            .Lazer,
            .Player
        ]
        
        ColliderType.definedCollisions[.Obstacle] = [
            .Enemy,
            .Lazer
        ]
        
        ColliderType.definedCollisions[.Collectable] = [
            .Player
        ]
        
        
        // MARK: Setup Collider notifications
        
        ColliderType.requestedContactNotifications[.Player] = [
            .Obstacle,
            .Collectable,
            .Enemy
        ]
        
        ColliderType.requestedContactNotifications[.Collectable] = [
            .Player
        ]
        
        ColliderType.requestedContactNotifications[.Lazer] = [
            .Obstacle,
            .Collectable,
            .Enemy,
            .Boundary
        ]
        
        ColliderType.requestedContactNotifications[.Obstacle] = [
            .Lazer
        ]
        
        ColliderType.requestedContactNotifications[.Enemy] = [
            .Obstacle,
            .Collectable,
            .Enemy,
            .Boundary,
            .Lazer,
            .Player
        ]
        
        // MARK: Setup Entity Manager
        
        entityManager = EntityManager(scene: self)
        
        // Create boundary
        boundary = BoundaryEntity(rect: visibleRect)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didReceiveKey(_:)), name: Notification.Name("didReceiveKey"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("Deinit game scene")
    }
    
    // MARK: Did move to view
    
    override func didMove(to view: SKView) {
        #if os(iOS) || os(tvOS) || os(watchOS)
        fingers = [UITouch?](repeating: nil, count: 2)
        #endif
        
        visibleRect = CGRect(x: 0, y: 1410, width: 640, height: 352)
        // MARK: Resize View Based On Bounds
        var size = self.size;
        
        let newheight = view.bounds.size.height / view.bounds.size.width * size.width
        
        if newheight > size.height {
            size.height = newheight
            self.size = size
        }
        
        // Add edgeTile collision
        for edgeTile in gamemanager.edgeTiles {
            self.entityManager.add(entity: edgeTile)
        }
        
        // Add key tiles
        for key in gamemanager.keyTiles {
            self.entityManager.add(entity: key)
        }
        
        // Add extra life tiles
        for life in gamemanager.lifeTiles {
            self.entityManager.add(entity: life)
        }
        
        // Add bricks
        if GameGlobals.instance.showBricks {
            for brickTile in gamemanager.brickTiles {
                self.entityManager.add(entity: brickTile)
            }
        }
        
        // Add Gate Posts
        for gate in gamemanager.gateTiles {
            self.entityManager.add(entity: gate)
        }
        
        // Add doors
        for (_, doors) in gamemanager.doorTiles {
            for door in doors {
                self.entityManager.add(entity: door)
            }
        }
        
        entityManager.add(entity: gamemanager.prizeEntity)
        
        self.entityManager.hidden.removeAll()
        self.entityManager.hideEntitiesOutsideRect(rect: self.visibleRect)
        
        // reset boundary
        boundary.reset()
        entityManager.add(entity: boundary)
        
        // reset camera
        
        cam = SKCameraNode()
        cam.position = CGPoint(x: 0 + self.frame.size.width / 2, y: 1760 - self.frame.size.height / 2)
        cam.name = "Camera"
        //MARK: Create Dashboard
        
        let calcPosX = -self.frame.size.width / 2
        let calcPosY = -self.frame.size.height / 2
        let calcHeight = self.frame.size.height - 352
        
        let cover = DashboardSprite(CGRect(x: calcPosX, y: calcPosY, width: self.frame.size.width, height: calcHeight))
        cover.name = "Dashboard"
        cam.addChild(cover)
        
        //MARK: Setup Joypad
        #if os(iOS) || os(tvOS) || os(watchOS)
        let base = UIColor.white.withAlphaComponent(0.1);
        let stick = UIColor.white.withAlphaComponent(0.3);
        
        
        ctrl = AnalogJoystick(diameter: 100, colors: (base, stick))
        ctrl.position = CGPoint(x: -self.frame.size.width / 2 + 100, y: -self.frame.size.height / 2 + 100);
        ctrl.zPosition = 1000
        ctrl.name = "Joystick"
        //cam.addChild(ctrl)
        
        fireBtn = FireButton(diameter: 58, color: stick)
        fireBtn.position = CGPoint(x:0 + self.frame.size.width / 2 - 80, y: -self.frame.size.height / 2 + 80 )
        fireBtn.zPosition = 1000
        fireBtn.name = "Fire Button"
        //cam.addChild(fireBtn)
        #endif
        
        self.camera = cam
        self.addChild(cam)
        
        // MARK: Init and Add Player
    
        self.player = PlayerEntity(location: CGPoint(x: cam.position.x, y: cam.position.y + calcHeight / 2))
        
        entityManager.add(entity: player)
        
        // MARK: Joypad control
        #if os(iOS) || os(tvOS) || os(watchOS)
        ctrl.beginHandler = { [unowned self] in
            if self.sceneState.currentState is ScenePlayingState {
                self.controlBeginHandler()
            }
        }
        ctrl.trackingHandler = {[unowned self] data in
            if self.sceneState.currentState is ScenePlayingState {
                self.controlTrackingHandler(data)
            }
        }
        
        ctrl.stopHandler = { [unowned self] in
            if self.sceneState.currentState is ScenePlayingState {
                self.controlEndHandler()
            }
        }
        
        fireBtn.beginHandler = { [unowned self] in
            if self.sceneState.currentState is ScenePlayingState {
                self.fireBtnStartHandler()
            }
        }
        
        fireBtn.stopHandler = {[unowned self] in
            self.fireBtnEndHandler()
        }
        #endif
        
        controllerSetup()
        getReady()
    }
    
    override func willMove(from view: SKView) {
        cam.removeAllActions()
        cam.removeAllChildren()
        cam.removeFromParent()
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        if sceneState.currentState?.isKind(of: ScenePlayingState.self) ?? false {
            if let gamePad = gamemanager.gamePad as? GCExtendedGamepad {
               snapshot = gamePad.saveSnapshot()
            }
        }
        
        if let _ = player.component(ofType: ControlledComponent.self) {
            if(self.player.isArmed && currentTime - lastProjectile > 0.1) {
                
                if (self.projectileDataPosition != nil && self.projectileDataAngle != nil) {
                    
                    let lazer = LazerEntity(location: projectileDataPosition!, angle: projectileDataAngle!)
                    self.entityManager.add(entity: lazer)
                }
                lastProjectile = currentTime
            }
        }
        
        lastUpdateTime = currentTime
        sceneState.update(deltaTime: dt)
        entityManager.update(deltaTime: dt)
    }
    
    func controllerSetup() {
        if gamemanager.gamePad is GCExtendedGamepad {
            weak var pad = gamemanager.gamePad as? GCExtendedGamepad
            
            pad?.controller?.controllerPausedHandler = {[unowned self] (GCController) in
                
                if self.sceneState.currentState is ScenePausedState {
                    self.sceneState.enter(ScenePlayingState.self)
                } else {
                    self.sceneState.enter(ScenePausedState.self)
                }
            }
        }
    }
    
    private func updateForExtendedController() -> (current: CGVector?, previous: CGVector?, fire:Bool, previousFire:Bool) {
        let result:(current:CGVector?, previous:CGVector?, fire:Bool, previousFire:Bool)
        
        if let previousShot = previousSnapShot as? GCExtendedGamepad {
            var x:Float = 0
            var y:Float = 0
            
            if previousShot.leftThumbstick.xAxis.value != 0 || previousShot.leftThumbstick.yAxis.value != 0 {
                x = previousShot.leftThumbstick.xAxis.value * 55
                y = previousShot.leftThumbstick.yAxis.value * 55
            } else if previousShot.dpad.xAxis.value != 0 || previousShot.dpad.yAxis.value != 0 {
                x = previousShot.dpad.xAxis.value * 55
                y = previousShot.dpad.yAxis.value * 55
            }
            
            result.previousFire = previousShot.buttonA.isPressed ? true : false
            
            if x == 0 && y == 0 {
                result.previous = nil
            } else {
                result.previous = CGVector(dx: CGFloat(x), dy: CGFloat(y))
            }
        } else {
            result.previous = nil
            result.previousFire = false
        }
        
        if let snapShot = snapshot as? GCExtendedGamepad {
            var x:Float = 0
            var y:Float = 0
            
            if snapShot.leftThumbstick.xAxis.value != 0 || snapShot.leftThumbstick.yAxis.value != 0 {
                x = snapShot.leftThumbstick.xAxis.value * 55
                y = snapShot.leftThumbstick.yAxis.value * 55
            } else if snapShot.dpad.xAxis.value != 0 || snapShot.dpad.yAxis.value != 0 {
                x = snapShot.dpad.xAxis.value * 55
                y = snapShot.dpad.yAxis.value * 55
            }
            
            result.fire = snapShot.buttonA.isPressed ? true : false
            
            if x == 0 && y == 0 {
                result.current = nil
            } else {
                result.current = CGVector(dx: CGFloat(x), dy: CGFloat(y))
            }
        } else {
            result.current = nil
            result.fire = false
        }
        
        return result
    }
    
    override func didFinishUpdate() {
        if sceneState.currentState?.isKind(of: ScenePlayingState.self) ?? false {
            var data:(current:CGVector?, previous:CGVector?, fire:Bool , previousFire:Bool) = (current:nil,previous:nil,fire:false,previousFire:false)
            
            if previousSnapShot is GCExtendedGamepad {
                data = updateForExtendedController()
            } else {
                #if os(OSX)
                if keyPresses["FIRE"]! {
                    data.fire = true
                }
                if previousKeyPresses["FIRE"]! {
                    data.previousFire = true
                }
                
                var currentVec = CGVector(dx: 0, dy: 0)
                var previousVec = CGVector(dx: 0, dy: 0)
                
                if keyPresses["UP"]! {
                    currentVec.dy = 0.1 * 55
                }
                
                if keyPresses["DOWN"]! {
                    currentVec.dy = -0.1 * 55
                }
                
                if keyPresses["LEFT"]! {
                    currentVec.dx = -0.1 * 55
                }
                
                if keyPresses["RIGHT"]! {
                    currentVec.dx = 0.1 * 55
                }
                
                if previousKeyPresses["UP"]! {
                    previousVec.dy = 0.1 * 55
                }
                
                if previousKeyPresses["DOWN"]! {
                    previousVec.dy = -0.1 * 55
                }
                
                if previousKeyPresses["LEFT"]! {
                    previousVec.dx = -0.1 * 55
                }
                
                if previousKeyPresses["RIGHT"]! {
                    previousVec.dx = 0.1 * 55
                }
                
                if currentVec.dx == 0 && currentVec.dy == 0 {
                    data.current = nil
                } else {
                    data.current = currentVec
                }
                
                if previousVec.dx == 0 && previousVec.dy == 0 {
                    data.previous = nil
                } else {
                    data.previous = previousVec
                }
                #endif
            }
        
            /*if data.fire  && !data.previousFire {
                self.fireBtnStartHandler()
            }
            
            if !data.fire && data.previousFire {
                self.fireBtnEndHandler()
            }*/
            
            if data.fire {
                if !(self.player.playerState.currentState is PlayerArmedState) {
                    
                    self.fireBtnStartHandler()
                    
                }
            } else if !data.fire && data.previousFire {
                if self.player.playerState.currentState is PlayerArmedState {
                    
                    self.fireBtnEndHandler()
                    
                }
            }
            
            if data.current != nil && data.previous == nil {
                
                self.controlBeginHandler()
                
            }
            
            if data.current != nil && data.previous != nil {
                let vel = CGPoint(x: (data.current?.dx ?? 0), y: (data.current?.dy ?? 0))
                print(vel)
                self.controlTrackingHandler(AnalogJoystickData(velocity: vel, angular: -atan2(vel.x, vel.y)))
                
            }
            
            if data.current == nil && data.previous != nil {
                
                self.controlEndHandler()
                
            }
            
            previousSnapShot = snapshot
        
            #if os(OSX)
            previousKeyPresses = keyPresses
            #endif
        }
    }
    
    // MARK: Notifications
    
    @objc func didReceiveKey(_ notification:Notification) {
        if let data = notification.userInfo as? [String: Int] {
            for (_, keys) in data {
                if keys == 21  /* 21 */ {
                    if let doors = gamemanager.doorTiles[21] {
                        for door in doors {
                            self.run(SKAction.playSoundFileNamed("door", waitForCompletion: false))
                            door.remove()
                        }
                    }
                }
                if keys == 25 /* 25 */ {
                    if let doors = gamemanager.doorTiles[15] {
                        for door in doors {
                            self.run(SKAction.playSoundFileNamed("door", waitForCompletion: false))
                            door.remove()
                        }
                    }
                }
                if keys == 35 /* 35 */ {
                    if let doors = gamemanager.doorTiles[16] {
                        for door in doors {
                            self.run(SKAction.playSoundFileNamed("door", waitForCompletion: false))
                            door.remove()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: SKPhysicsContactDelegate
    
    @objc(didBeginContact:) func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity, contactPoint: CGPoint) in
            ContactNotifiableType.contactWithEntityDidBegin(otherEntity, contactPoint: contactPoint)
        }
    }
    
    @objc(didEndContact:) func didEnd(_ contact: SKPhysicsContact) {
        handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity, contactPoint: CGPoint) in
            ContactNotifiableType.contactWithEntityDidEnd(otherEntity, contactPoint: contactPoint)
        }
    }
    
    // MARK: SKPhysicsContactDelegate convenience
    
    private func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiableType, GKEntity, CGPoint) -> Void) {
        
        // Get the `ColliderType` for each contacted body.
        let colliderTypeA = ColliderType(rawValue: contact.bodyA.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.bodyB.categoryBitMask)
        
        // Determine which `ColliderType` should be notified of the contact.
        let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
        let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
        
        let contactPoint = contact.contactPoint as CGPoint
        
        // Make sure that at least one of the entities wants to handle this contact.
        assert(aWantsCallback || bWantsCallback, "Unhandled physics contact - A = \(colliderTypeA), B = \(colliderTypeB)")
        
        let entityA = contact.bodyA.node?.entity
        let entityB = contact.bodyB.node?.entity
        /*
         If `entityA` is a notifiable type and `colliderTypeA` specifies that it should be notified
         of contact with `colliderTypeB`, call the callback on `entityA`.
         */
        if let notifiableEntity = entityA as? ContactNotifiableType, let otherEntity = entityB, aWantsCallback {
            contactCallback(notifiableEntity, otherEntity, contactPoint)
        }
        
        /*
         If `entityB` is a notifiable type and `colliderTypeB` specifies that it should be notified
         of contact with `colliderTypeA`, call the callback on `entityB`.
         */
        if let notifiableEntity = entityB as? ContactNotifiableType, let otherEntity = entityA, bWantsCallback {
            contactCallback(notifiableEntity, otherEntity, contactPoint)
        }
    }
    
    // MARK: Touch Handlers
    #if os(iOS) || os(tvOS) || os(watchOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if cam.isUserInteractionEnabled {
            for touch in touches {
                let point = touch.location(in: cam)
                for (index,finger)  in fingers.enumerated() {
                    if finger == nil {
                        fingers[index] = touch
                        if index == 0 {
                            
                            ctrl.position = CGPoint(x: point.x, y: point.y)
                            cam.addChild(ctrl)
                            ctrl.touchesBegan(touches, with: event)
                            
                            if self.sceneState.currentState is ScenePausedState {
                                self.sceneState.enter(ScenePlayingState.self)
                            }
                        }
                        if index == 1 {
                            fireBtn.position = CGPoint(x: point.x, y: point.y)
                            cam.addChild(fireBtn)
                            fireBtn.touchesBegan(touches, with: event)
                            
                            if self.sceneState.currentState is ScenePausedState {
                                self.sceneState.enter(ScenePlayingState.self)
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if cam.isUserInteractionEnabled {
            for touch in touches {
                for (index,finger) in fingers.enumerated() {
                    if let finger = finger, finger == touch {
                        if index == 0 && finger == touch {
                            ctrl.touchesMoved([touch], with: event)
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            for (index,finger) in fingers.enumerated() {
                if let finger = finger, finger == touch {
                    fingers[index] = nil
                    if index == 0 {
                        ctrl.restHard()
                        ctrl.removeFromParent()
                    }
                    if index == 1 {
                        fireBtn.touchesEnded(touches, with: event)
                        fireBtn.removeFromParent()
                    }
                    break
                }
            }
        }
    }
    #endif
    
    // MARK: Keyboard Handlers
    #if os(OSX)
    override func keyDown(with event: NSEvent) {
        let temp: String = event.characters!
        
        for letter in temp {
            switch letter {
            case GameGlobals.instance.keyBindings["FIRE"]:
                keyPresses["FIRE"] = true
            case GameGlobals.instance.keyBindings["UP"]:
                keyPresses["UP"] = true
            case GameGlobals.instance.keyBindings["DOWN"]:
                keyPresses["DOWN"] = true
            case GameGlobals.instance.keyBindings["LEFT"]:
                keyPresses["LEFT"] = true
            case GameGlobals.instance.keyBindings["RIGHT"]:
                keyPresses["RIGHT"] = true
            default:
                continue
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        let temp: String = event.characters!
        
        for letter in temp {
            switch letter {
            case GameGlobals.instance.keyBindings["FIRE"]:
                keyPresses["FIRE"] = false
            case GameGlobals.instance.keyBindings["UP"]:
                keyPresses["UP"] = false
            case GameGlobals.instance.keyBindings["DOWN"]:
                keyPresses["DOWN"] = false
            case GameGlobals.instance.keyBindings["LEFT"]:
                keyPresses["LEFT"] = false
            case GameGlobals.instance.keyBindings["RIGHT"]:
                keyPresses["RIGHT"] = false
            default:
                continue
            }
        }
    }
    #endif
    
    // MARK: Controller and Touch Input Methods
    
    func controlBeginHandler() {
        self.player.startMoving()
    }
    
    func controlTrackingHandler(_ data: AnalogJoystickData) {
        let ang = round(data.angular / (.pi/4)) * (.pi/4)
        let x = -sin(ang) * 1
        let y = cos(ang) * 1
        let vel = CGVector(dx: x, dy: y)
        
        if(data.velocity.x < -1 || data.velocity.x > 1
            || data.velocity.y < -1 || data.velocity.y > 1) {
            self.player.velocityUpdate(vel: vel, ang: ang)
        } else {
            self.player.velocityUpdate(vel: CGVector.zero, ang: ang)
        }
        
        if(self.player.isArmed) {
            
            if let spriteComponent = self.player.component(ofType: SpriteComponent.self) {
                
                let x = spriteComponent.node.position.x
                let y = spriteComponent.node.position.y
                let offset = spriteComponent.node.size.width / 2 - 6
                let half = spriteComponent.node.size.width / 2 + 11
                
                self.projectileDataPosition = spriteComponent.node.position
                
                //North West
                if(ang > 0.78 && ang < 0.79) {
                    self.projectileDataPosition = CGPoint(x: x - (half * 0.85), y: y + (half * 0.85))
                }
                //North
                if(ang == 0.0 || ang == -0.0) {
                    self.projectileDataPosition = CGPoint(x: x - offset, y: y + half)
                }
                    
                //North East
                else if(ang < -0.78 && ang > -0.79) {
                    self.projectileDataPosition = CGPoint(x: x + (half * 0.85), y: y + (half * 0.85))
                }
                    
                //East
                else if(ang < -1.57 && ang > -1.58) {
                    self.projectileDataPosition = CGPoint(x: x + half, y: y + offset)
                }
                    
                //South East
                else if(ang < -2.35 && ang > -2.36) {
                    self.projectileDataPosition = CGPoint(x: x + (half * 0.85), y: y - (half * 0.85))
                }
                    
                //South
                else if((ang < -3.14 && ang > -3.15) || (ang > 3.14 && ang < 3.15)) {
                    self.projectileDataPosition = CGPoint(x: x + offset, y: y - half)
                }
                    
                //South West
                else if(ang > 2.35 && ang < 2.36) {
                    self.projectileDataPosition = CGPoint(x: x - (half * 0.85), y: y - (half * 0.85))
                }
                    
                //West
                else if(ang > 1.57 && ang < 1.58) {
                    self.projectileDataPosition = CGPoint(x: x - half, y: y - offset)
                }
                
                self.projectileDataAngle = ang
            }
        }
    }
    
    func controlEndHandler() {
        self.player.stopMoving()
        self.player.velocityUpdate(vel: CGVector.zero, ang: 0)
    }
    
    func fireBtnStartHandler() {
        self.player.playerState.enter(PlayerArmedState.self)
    }
    
    func fireBtnEndHandler() {
        self.player.playerState.enter(PlayerIdleState.self)
        self.projectileDataPosition = nil
        self.projectileDataAngle = nil
    }
    
    // MARK: Spawn Berks and Drones
    
    func spawnBerks() {
        
        var spaces = gamemanager.emptyTiles[player.roomFromLocation()]
        
        // Debug - Draws a cyan circle where an empty spaces for respawns are found
        /*for space in spaces! {
            let shape = SKShapeNode.init(circleOfRadius: 4)
            shape.fillColor = UIColor.cyan
            shape.position = CGPoint(x: space.midX, y: space.midY)
            self.addChild(shape)
        }*/
        
        let spawnpoints = (0..<GameGlobals.instance.berksToSpawn)
            .map{spaces!.count - $0}
            .map{Int(arc4random_uniform(UInt32($0)))}
            .map{spaces!.remove(at: $0)}
        
        if GameGlobals.instance.spawnBerks {
            for point in spawnpoints {
                let berk = BerkEntity(location: CGPoint(x: point.midX, y: point.midY), entityManager: entityManager)
                self.entityManager.add(entity: berk)
            }
        }
        
        let mapData = GameGlobals.instance.mapData[GameGlobals.instance.room]
        let droneQty:Int = mapData!["drones"]![Int(GameGlobals.instance.currentDifficulty.rawValue)] as! Int
        
        let dronepoint = (0..<droneQty)
            .map{spaces!.count - $0}
            .map{Int(arc4random_uniform(UInt32($0)))}
            .map{spaces!.remove(at: $0)}
        
        if GameGlobals.instance.spawnDrone {
            for point in dronepoint {
                let drone = DroneEntity(location: CGPoint(x: point.midX, y: point.midY), entityManager: self.entityManager)
                self.entityManager.add(entity: drone)
            }
        }
    }
    
    // MARK: Camera Shake
    
    func shakeCamera(duration:Float) {
        
        let amplitudeX:Float = 10;
        let amplitudeY:Float = 6;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        cam.run(actionSeq);
    }
    
    // MARK: Scene State Manager Protocol
    
    func roomChange(to: Int, from: Int) {
        var action:SKAction = SKAction()
        GameGlobals.instance.room = to
        let controlledComponent = player.component(ofType: ControlledComponent.self)
        controlledComponent?.vel = CGVector.zero
        player.removeComponent(ofType: ControlledComponent.self)
        
        let addControlAction = SKAction.run {
            if let control = controlledComponent {
                self.player.addComponent(control)
            }
        }
        
        let spawnBerksAction = SKAction.run { [unowned self] in
            self.spawnBerks()
        }
        
        let x = visibleRect.minX
        let y = visibleRect.minY
        let width = visibleRect.width
        let height = visibleRect.height
        
        if((to > from) && (to - from == 1)) {
            visibleRect = CGRect(x: x + 640, y: y, width: width, height: height)
            action = SKAction.moveBy(x: 640, y: 0, duration: 0.5)
        }
        
        if((to > from) && (to - from > 1)) {
            visibleRect = CGRect(x: x, y: y - 352, width: width, height: height)
            
            action = SKAction.moveBy(x: 0, y: -352, duration: 0.5)
        }
        
        if((to < from) && (from - to == 1)) {
            visibleRect = CGRect(x: x - 640, y: y, width: width, height: height)
            action = SKAction.moveBy(x: -640, y: 0, duration: 0.5)
        }
        
        if((to < from) && (from - to > 1)) {
            visibleRect = CGRect(x: x, y: y + 352, width: width, height: height)
            action = SKAction.moveBy(x: 0, y: 352, duration: 0.5)
        }
        
        if let nodeComponent = boundary.component(ofType: NodeComponent.self) {
            nodeComponent.node.position = CGPoint(x: visibleRect.minX, y: visibleRect.minY)
        }
        
        for entity in entityManager.entities {
            if(entity.isKind(of: BerkEntity.self) || entity.isKind(of: DroneEntity.self)) {
                entityManager.remove(entity: entity)
            }
        }
        
        
        
        entityManager.hideEntitiesOutsideRect(rect: visibleRect)
        player.playerState.enter(PlayerInvincibleState.self)
        player.updateRespawnPoint()
        
        cam.run(SKAction.sequence([spawnBerksAction, action, addControlAction]))
    }
    
    // MARK: Did pause scene
    
    func didPauseScene() {
        if let scene = self.scene {
            if scene.isPaused {
                for entity in entityManager.entities {
                    if(entity.isKind(of: DroneEntity.self)) {
                        if let droneMoveComponent = entity.component(ofType: DroneMoveComponent.self) {
                            droneMoveComponent.maxSpeed = 0
                        }
                    }
                }
                
                #if os(iOS) || os(tvOS) || os(watchOS)
                ctrl.disabled = false;
                #endif
                
                let paused = self.cam.childNode(withName: "paused-text")
                paused?.removeFromParent()
                
            } else {
                for entity in entityManager.entities {
                    if(entity.isKind(of: DroneEntity.self)) {
                        if let droneMoveComponent = entity.component(ofType: DroneMoveComponent.self) {
                            droneMoveComponent.maxSpeed = 0
                        }
                    }
                }
                
                #if os(iOS) || os(tvOS) || os(watchOS)
                ctrl.disabled = true;
                #endif
                
                let paused = SKLabelNode(fontNamed: "AvenirNext-Heavy")
                paused.name = "paused-text";
                paused.text = "PAUSED"
                paused.fontColor = SKColor.white
                paused.fontSize = 55
                paused.verticalAlignmentMode = .center
                paused.horizontalAlignmentMode = .center
                paused.zPosition = 100000
                self.cam.addChild(paused)
            }
            scene.isPaused = !scene.isPaused
        }
    }
    
    // MARK: Did complete scene
    
    func didCompleteScene() {
        
        player.removeComponent(ofType: ControlledComponent.self)
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        self.ctrl.disabled = true
        self.fireBtn.disabled = true
        #endif
        
        let sound = SKAction.playSoundFileNamed("prize", waitForCompletion: true)
        let calcPosX = visibleRect.midX
        let calcPosY = visibleRect.midY
        
        for entity in entityManager.entities {
            if(entity.isKind(of: BerkEntity.self) || entity.isKind(of: DroneEntity.self)) {
                entityManager.remove(entity: entity)
            }
        }
        
        let bg = SKSpriteNode.init(color: Color.black, size: CGSize(width: visibleRect.width, height: visibleRect.height + 10))
        bg.alpha = 0.4
        bg.position = CGPoint(x: calcPosX, y: calcPosY)
        bg.zPosition = 999
        
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.position = CGPoint(x: calcPosX, y: calcPosY)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .baseline
        label.fontColor = SKColor.yellow
        label.fontSize = 18
        label.text = "CONGRATULATIONS - COMPLETED \(String(describing: GameGlobals.instance.currentDifficulty).uppercased()) LEVEL"
        label.zPosition = 1000
        
        let achievement = GKAchievement(identifier: "co.uk.berks.\(String(describing: GameGlobals.instance.currentDifficulty).lowercased()).completed")
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement], withCompletionHandler: nil)
        
        if GameGlobals.instance.currentDifficulty != .Master {
            GameGlobals.instance.currentDifficulty.next()
        }
        
        let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 0.3)
        let waitAction = SKAction.wait(forDuration: 3)
        let updateText = SKAction.run {
            label.text = "ADVANCING TO \(String(describing: GameGlobals.instance.currentDifficulty).uppercased())"
        }
        let resetAction = SKAction.run { [unowned self] in
            GameGlobals.instance.softReset()
            
            #if os(iOS) || os(tvOS) || os(watchOS)
            self.ctrl.restHard()
            self.ctrl.removeFromParent()
            #endif
            
            self.entityManager.removeAll()
            self.removeAllChildren()
            self.gamemanager.stateMachine.enter(GamePlayState.self)
        }
        
        self.addChild(bg)
        self.addChild(label)
        
        bg.run(SKAction.sequence([sound, fadeIn, waitAction, updateText, waitAction, resetAction]))
    }
    
    func getReady() {
        sceneState.enter(SceneGetReadyState.self)
        
        let spawnPoint = player.lastSpawnPoint
        
        entityManager.remove(entity: player)
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        self.ctrl.disabled = true
        #endif
        
        let calcPosX = visibleRect.midX
        let calcPosY = visibleRect.midY
        
        let bg = SKSpriteNode.init(color: Color.black, size: CGSize(width: visibleRect.width, height: visibleRect.height + 10))
        bg.alpha = 0.4
        bg.position = CGPoint(x: calcPosX, y: calcPosY)
        bg.zPosition = 999
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.position = CGPoint(x: calcPosX, y: calcPosY)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .baseline
        label.fontColor = SKColor.yellow
        label.text = "GET READY"
        label.zPosition = 1000
        
        let fadeOutAction = SKAction.fadeAlpha(to: 0.1, duration: 0.25)
        let fadeInAction = SKAction.fadeAlpha(to: 1, duration: 0.25)
        let fadeAction = SKAction.sequence([fadeOutAction,fadeInAction])
        let repeatAction = SKAction.repeat(fadeAction, count: 6)
        let blockAction = SKAction.run {[unowned self] in
            label.removeFromParent()
            bg.removeFromParent()
            
            self.resetPlayer(spawnPoint!)
            self.cam.isUserInteractionEnabled = true
            self.spawnBerks()
        }
        let finalAction = SKAction.sequence([repeatAction, blockAction])
        
        self.addChild(label)
        self.addChild(bg)
        label.run(finalAction)
        
    }
    
    // MARK: Did Lose Life State
    
    func didLoseLife() {
        GameGlobals.instance.lives -= 1
        cam.isUserInteractionEnabled = false
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        ctrl.removeFromParent()
        ctrl.disabled = true
        #endif
        
        if GameGlobals.instance.lives > 0 {
            //let spawnPoint = player.lastSpawnPoint
        
            for entity in entityManager.entities {
                if(entity.isKind(of: BerkEntity.self) || entity.isKind(of: DroneEntity.self)) {
                    entityManager.remove(entity: entity)
                }
            }
            
            self.getReady()
            
        } else {
            #if os(iOS) || os(tvOS) || os(watchOS)
            ctrl.restHard()
            ctrl.removeFromParent()
            #endif
            
            entityManager.removeAll()
            self.removeAllChildren()
            self.gamemanager.stateMachine.enter(GameOverState.self)
        }
    }
    
    func resetPlayer(_ spawnPoint: CGPoint) {
        self.player = PlayerEntity(location: spawnPoint)
        entityManager.add(entity: player)
        self.snapshot = nil
        self.previousSnapShot = nil
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        self.ctrl.restHard()
        self.ctrl.disabled = false
        self.fireBtn.disabled = false
        #endif
        
        self.sceneState.enter(ScenePlayingState.self)
    }
}
