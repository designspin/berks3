//
//  TitleScene.swift
//  idiots
//
//  Created by Jason Foster on 27/11/2017.
//  Copyright © 2017 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class TitleScene: SKScene {
    
    weak var gamemanager: GameManager!
    
    deinit {
        print("Deinit TitleScene")
    }
    
    override func didMove(to view: SKView) {
        let atlas = SKTextureAtlas(named: "berks")
        
        backgroundColor = SKColor.black
        
        let uniformBasedShader = SKShader(fileNamed: "title.fsh")
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        cropNode.zPosition = 1
        
        let mask = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        mask.text = "BERKS III"
        mask.fontColor = SKColor.white
        mask.fontSize = 75
        
        cropNode.maskNode = mask
        
        let nodeToMask = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: 150))
        nodeToMask.position = CGPoint.zero
        nodeToMask.shader = uniformBasedShader
        
        cropNode.addChild(nodeToMask)
        
        #if os(iOS)
        let forIos = SKLabelNode(fontNamed: "AvenirNext-Bold")
        forIos.text = "for IOS"
        forIos.color = SKColor.white
        forIos.horizontalAlignmentMode = .right
        forIos.verticalAlignmentMode = .bottom
        forIos.fontSize = 20
        forIos.position = CGPoint(x: size.width / 2 + 170, y: size.height / 2 + 90 )
        forIos.zPosition = 20
        addChild(forIos)
        #endif
        
        let spritesize = vector_float3(
            Float(size.width),
            Float(150.0),
            Float(0.0)
        )
        
        uniformBasedShader.uniforms = [
            SKUniform(name: "iResolution", vectorFloat3: spritesize)
        ]
        
        addChild(cropNode)
        
        let leaderboards = SKSpriteNode()
        leaderboards.color = .blue
        leaderboards.size = CGSize(width: 300, height: 40)
        leaderboards.position = CGPoint(x: size.width / 2, y: size.height / 2 - 10)
        leaderboards.name = "viewScores"
        
        if !GameGlobals.instance.gamecenter {
            leaderboards.alpha = 0
        }
        
        let leaderText = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        leaderText.text = "View Leaderboards"
        leaderText.verticalAlignmentMode = .center
        leaderText.horizontalAlignmentMode = .center
        leaderText.fontSize = 20
        leaderText.name = "viewScoresLabel"
        //leaderText.position = CGPoint(x: leaderboards.size.width / 2, y: leaderboards.size.height / 2)
        leaderboards.addChild(leaderText)
        addChild(leaderboards)
        
        let difficultyText = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        difficultyText.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        difficultyText.text = GameGlobals.instance.currentDifficulty.name
        difficultyText.verticalAlignmentMode = .baseline
        difficultyText.horizontalAlignmentMode = .center
        difficultyText.fontSize = 20
        addChild(difficultyText)
        
        let leftBtn = SKSpriteNode(texture: atlas.textureNamed("arrow_left"))
        leftBtn.size = CGSize(width: 42, height: 42)
        leftBtn.position = CGPoint(x: size.width / 2 - 100, y: size.height / 2 - 70 )
        leftBtn.name = "leftBtn"
        addChild(leftBtn)
        
        let rightBtn = SKSpriteNode(texture: atlas.textureNamed("arrow_right"))
        rightBtn.size = CGSize(width: 42, height: 42)
        rightBtn.position = CGPoint(x: size.width / 2 + 100, y: size.height / 2 - 70)
        rightBtn.name = "rightBtn"
        addChild(rightBtn)
        
        GameGlobals.instance.addListener(name: "difficulty", object: difficultyText)
        
        #if os(OSX)
        let configureKeys = SKSpriteNode()
        configureKeys.color = .blue
        configureKeys.size = CGSize(width: 300, height: 40)
        configureKeys.position = CGPoint(x: size.width / 2, y: size.height / 2 - 125)
        configureKeys.name = "configureKeys"
        
        let configureKeysText = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        configureKeysText.text = "Configure Keys"
        configureKeysText.verticalAlignmentMode = .center
        configureKeysText.horizontalAlignmentMode = .center
        configureKeysText.fontSize = 20
        configureKeysText.name = "configureKeysLabel"
        configureKeys.addChild(configureKeysText)
        addChild(configureKeys)
        #endif
        
        let originalAuthor = SKLabelNode(fontNamed: "AvenirNext-Regular")
        originalAuthor.text = "Original Game by Jon Williams"
        originalAuthor.position = CGPoint(x: size.width / 2, y: size.height / 2 + 70)
        originalAuthor.verticalAlignmentMode = .baseline
        originalAuthor.horizontalAlignmentMode = .center
        originalAuthor.fontSize = 14
        originalAuthor.fontColor = SKColor.yellow
        addChild(originalAuthor)
        
        let rewrite = SKLabelNode(fontNamed: "AvenirNext-Regular")
        rewrite.text = "Re-Written for IOS by Jason Foster"
        rewrite.position = CGPoint(x: size.width / 2, y: size.height / 2 + 45 )
        rewrite.verticalAlignmentMode = .baseline
        rewrite.horizontalAlignmentMode = .center
        rewrite.fontSize = 14
        rewrite.fontColor = SKColor.cyan
        addChild(rewrite)
        
        let musicAuhor = SKLabelNode(fontNamed: "AvenirNext-Regular")
        musicAuhor.text = "Music By Luke Sidell"
        musicAuhor.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        musicAuhor.verticalAlignmentMode = .baseline
        musicAuhor.horizontalAlignmentMode = .center
        musicAuhor.fontSize = 14
        musicAuhor.fontColor = SKColor.yellow
        addChild(musicAuhor)
        
        let title = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        #if os(iOS) || os(tvOS) || os(watchOS)
        title.position = CGPoint(x: size.width / 2  , y: ( size.height / 2 ) - 150 )
        #elseif os(OSX)
        title.position = CGPoint(x: size.width / 2  , y: ( size.height / 2 ) - 165 )
        #endif
        title.color = SKColor.white
        
        #if os(iOS) || os(watchOS)
        title.text = "TOUCH TO START"
        #elseif os(tvOS) || os(OSX)
        title.text = "FIRE TO START"
        #endif
        
        title.fontSize = 20
        title.zPosition = 10
        title.name = "startLabel"
        addChild(title)
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 2)
        let fadeInAction = SKAction.fadeIn(withDuration: 2)
        let sequence = SKAction.sequence([fadeOutAction, fadeInAction])
        
        title.run(SKAction.repeatForever(sequence))
        
        let backgroundSound = SKAudioNode(fileNamed: "berksMusic")
        backgroundSound.isPositional = false
        backgroundSound.run(SKAction.changeVolume(by: 5, duration: 0.1))
        self.addChild(backgroundSound)
        controllerSetup()
    }
    
    override func willMove(from view: SKView) {
        controllerReset()
    }
    
    func controllerSetup() {
        if gamemanager.gamePad is GCExtendedGamepad {
            weak var pad = gamemanager.gamePad as? GCExtendedGamepad
            
            pad?.dpad.left.pressedChangedHandler = {[unowned self] (button, value, pressed) in
                if pressed {
                    self.leftLevelSelect()
                }
            }
            
            pad?.dpad.right.pressedChangedHandler = {[unowned self] (button, value, pressed) in
                if pressed {
                    self.rightLevelSelect()
                }
            }
            
            pad?.buttonA.pressedChangedHandler = {[unowned self] (button, value, pressed) in
                if pressed {
                    self.startGame()
                }
            }
            
            let label = scene?.childNode(withName: "startLabel") as? SKLabelNode
            label?.text = "FIRE TO START"
            
        }
    }
    
    func controllerRemoved() {
        let label = scene?.childNode(withName: "startLabel") as? SKLabelNode
        label?.text = "TOUCH TO START"
    }
    
    func controllerReset() {
        if gamemanager.gamePad is GCExtendedGamepad {
            weak var pad = gamemanager.gamePad as? GCExtendedGamepad
            
            pad?.dpad.left.pressedChangedHandler = nil
            pad?.dpad.right.pressedChangedHandler = nil
            pad?.buttonA.pressedChangedHandler = nil
        }
    }
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let positionInScene = touch.location(in: self)
        
        let touchedNode = self.nodes(at: positionInScene).first
        
        if let name = touchedNode?.name {
            if name == "leftBtn" {
                leftLevelSelect()
            }
            
            if name == "rightBtn" {
                rightLevelSelect()
            }
            
            if name == "viewScores" || name == "viewScoresLabel" {
                gamemanager.showLeaderboard()
            }
        } else {
            startGame()
        }
    }
    #endif
    
    func leftLevelSelect() {
        GameGlobals.instance.currentDifficulty.prev()
        scene?.run(SKAction.playSoundFileNamed("keyPickup", waitForCompletion: false))
    }
    
    func rightLevelSelect() {
        GameGlobals.instance.currentDifficulty.next()
        scene?.run(SKAction.playSoundFileNamed("keyPickup", waitForCompletion: false))
    }
    
    func startGame() {
        guard let statemachine = self.gamemanager.stateMachine else {
            return
        }
        
        if(statemachine.canEnterState(GamePlayState.self)) {
            statemachine.enter(GamePlayState.self)
        }
    }
    
    func enableLeaderboards() {
        if let node = scene?.childNode(withName: "viewScores") {
            node.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        }
        print(GameGlobals.instance.highScore)
    }
}

#if os(OSX)
extension TitleScene: NSTextFieldDelegate {
    
    override func mouseDown(with event: NSEvent) {
        let positionInScene = event.location(in: self)
        let node = self.nodes(at: positionInScene).first
        
        if let name = node?.name {
            if name == "leftBtn" {
                leftLevelSelect()
            }
            
            if name == "rightBtn" {
                rightLevelSelect()
            }
            
            if name == "viewScores" || name == "viewScoresLabel" {
                gamemanager.showLeaderboard()
            }
            
            if name == "configureKeys" || name == "configureKeysLabel" {
                showKeyboardConfig()
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        let temp: String = event.characters!
        
        for letter in temp {
            switch letter {
            case GameGlobals.instance.keyBindings["LEFT"]:
                leftLevelSelect()
            case GameGlobals.instance.keyBindings["RIGHT"]:
                rightLevelSelect()
            case GameGlobals.instance.keyBindings["FIRE"]:
                startGame()
            default:
                return
            }
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let sender = obj.object as? NSTextField else {
            return
        }
        
        guard let value = sender.stringValue.last else {
            return
        }
        
        let currentkeys = Array(GameGlobals.instance.keyBindings.values)
        
        if !currentkeys.contains(value) {
            
            sender.stringValue = String(value)
            
            switch sender.tag {
            case 0: // FIRE
                GameGlobals.instance.keyBindings["FIRE"] = value
                break
            case 1: // DOWN
                GameGlobals.instance.keyBindings["DOWN"] = value
                break
            case 2: // UP
                GameGlobals.instance.keyBindings["UP"] = value
                break
            case 3: // RIGHT
                GameGlobals.instance.keyBindings["RIGHT"] = value
                break
            case 4: // LEFT
                GameGlobals.instance.keyBindings["LEFT"] = value
                break
            default:
                return
            }
            
            UserDefaults.standard.set(GameGlobals.instance.keyBindings, forKey: "PlayerKeys")
            
            sender.window?.makeFirstResponder(sender.nextKeyView)
        }
    }
        
    func showKeyboardConfig() {
        let alert = NSAlert()
        alert.messageText = "Define Keys"
        alert.informativeText = "Re-define your controls."
        
        let vstack = NSStackView(frame: NSRect(x: 0, y: 0, width: 200, height: 150))
        
        //Left
        let labelForLeft = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 24))
        labelForLeft.stringValue = "LEFT"
        labelForLeft.alignment = .center
        labelForLeft.isSelectable = false
        labelForLeft.isEditable = false
        
        let keyForLeft = NSTextField(frame: NSRect(x: 100, y: 0, width: 100, height: 24))
        keyForLeft.stringValue = String(GameGlobals.instance.keyBindings["LEFT"]!)
        keyForLeft.alignment = .center
        keyForLeft.tag = 4
        keyForLeft.delegate = self
        
        let leftStack = NSStackView()
        
        leftStack.orientation = .horizontal
        leftStack.distribution = .fillEqually
        
        leftStack.addSubview(labelForLeft)
        leftStack.addSubview(keyForLeft)
        
        vstack.addSubview(leftStack)
        
        //Right
        let labelForRight = NSTextField(frame: NSRect(x: 0, y: 28, width: 100, height: 24))
        labelForRight.stringValue = "RIGHT"
        labelForRight.alignment = .center
        labelForRight.isSelectable = false
        labelForRight.isEditable = false
        
        let keyForRight = NSTextField(frame: NSRect(x: 100, y: 28, width: 100, height: 24))
        keyForRight.stringValue = String(GameGlobals.instance.keyBindings["RIGHT"]!)
        keyForRight.alignment = .center
        keyForRight.tag = 3
        keyForRight.delegate = self
        
        let rightStack = NSStackView()
        
        rightStack.orientation = .horizontal
        rightStack.distribution = .fillEqually
        
        rightStack.addSubview(labelForRight)
        rightStack.addSubview(keyForRight)
        
        vstack.addSubview(rightStack)
        
        //UP
        let labelForUp = NSTextField(frame: NSRect(x: 0, y: 56, width: 100, height: 24))
        labelForUp.stringValue = "UP"
        labelForUp.alignment = .center
        labelForUp.isSelectable = false
        labelForUp.isEditable = false
        
        let keyForUp = NSTextField(frame: NSRect(x: 100, y: 56, width: 100, height: 24))
        keyForUp.stringValue = String(GameGlobals.instance.keyBindings["UP"]!)
        keyForUp.alignment = .center
        keyForUp.tag = 2
        keyForUp.delegate = self
        
        let upStack = NSStackView()
        
        upStack.orientation = .horizontal
        upStack.distribution = .fillEqually
        
        upStack.addSubview(labelForUp)
        upStack.addSubview(keyForUp)
        
        vstack.addSubview(upStack)
        
        //DOWN
        let labelForDown = NSTextField(frame: NSRect(x: 0, y: 84, width: 100, height: 24))
        labelForDown.stringValue = "DOWN"
        labelForDown.alignment = .center
        labelForDown.isSelectable = false
        labelForDown.isEditable = false
        
        let keyForDown = NSTextField(frame: NSRect(x: 100, y: 84, width: 100, height: 24))
        keyForDown.stringValue = String(GameGlobals.instance.keyBindings["DOWN"]!)
        keyForDown.alignment = .center
        keyForDown.tag = 1
        keyForDown.delegate = self
        
        let downStack = NSStackView()
        
        downStack.orientation = .horizontal
        downStack.distribution = .fillEqually
        
        downStack.addSubview(labelForDown)
        downStack.addSubview(keyForDown)
        
        vstack.addSubview(downStack)
        
        //FIRE
        let labelForFire = NSTextField(frame: NSRect(x: 0, y: 112, width: 100, height: 24))
        labelForFire.stringValue = "FIRE"
        labelForFire.alignment = .center
        labelForFire.isEditable = false
        
        let keyForFire = NSTextField(frame: NSRect(x: 100, y: 112, width: 100, height: 24))
        keyForFire.stringValue = String(GameGlobals.instance.keyBindings["FIRE"]!)
        keyForFire.alignment = .center
        keyForFire.tag = 0
        keyForFire.delegate = self
        
        let fireStack = NSStackView()
        
        fireStack.orientation = .horizontal
        fireStack.distribution = .fillEqually
        
        fireStack.addSubview(labelForFire)
        fireStack.addSubview(keyForFire)
        
        vstack.addSubview(fireStack)
        
        alert.accessoryView = vstack
        
        keyForFire.nextKeyView = keyForDown
        keyForDown.nextKeyView = keyForUp
        keyForUp.nextKeyView = keyForRight
        keyForRight.nextKeyView = keyForLeft
        keyForLeft.nextKeyView = keyForFire
        
        alert.window.initialFirstResponder = keyForFire
        
        alert.beginSheetModal(for: (self.view?.window)!) { (response) in
            
        }
    
    }
}
#endif
