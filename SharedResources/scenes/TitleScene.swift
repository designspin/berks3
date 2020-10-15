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
        leaderboards.size = CGSize(width: 300, height: 50)
        leaderboards.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
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
        difficultyText.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        difficultyText.text = GameGlobals.instance.currentDifficulty.name
        difficultyText.verticalAlignmentMode = .baseline
        difficultyText.horizontalAlignmentMode = .center
        difficultyText.fontSize = 20
        addChild(difficultyText)
        
        let leftBtn = SKSpriteNode(texture: atlas.textureNamed("arrow_left"))
        leftBtn.size = CGSize(width: 42, height: 42)
        leftBtn.position = CGPoint(x: size.width / 2 - 100, y: size.height / 2 - 90 )
        leftBtn.name = "leftBtn"
        addChild(leftBtn)
        
        let rightBtn = SKSpriteNode(texture: atlas.textureNamed("arrow_right"))
        rightBtn.size = CGSize(width: 42, height: 42)
        rightBtn.position = CGPoint(x: size.width / 2 + 100, y: size.height / 2 - 90)
        rightBtn.name = "rightBtn"
        addChild(rightBtn)
        
        GameGlobals.instance.addListener(name: "difficulty", object: difficultyText)
        
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
        title.position = CGPoint(x: size.width / 2  , y: ( size.height / 2 ) - 150 )
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
