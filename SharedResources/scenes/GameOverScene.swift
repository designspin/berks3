//
//  GameOverScene.swift
//  idiots
//
//  Created by Jason Foster on 25/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class GameOverScene: SKScene {
    weak var gamemanager: GameManager!

    deinit {
        print("Deinit GameOverScene")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black

        // Load the rainbow shader from title screen
        let shader = SKShader(fileNamed: "title.fsh")
        let spriteSize = vector_float3(Float(size.width), Float(150.0), Float(0.0))
        shader.uniforms = [SKUniform(name: "iResolution", vectorFloat3: spriteSize)]

        // Create crop node to mask shader with text
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: frame.midX, y: frame.midY)
        cropNode.zPosition = 1

        // Text mask
        let mask = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        mask.text = "GAME OVER"
        mask.fontColor = SKColor.white
        mask.fontSize = 75
        cropNode.maskNode = mask

        // Shader-filled sprite behind the text (tall enough for font)
        let shaderSprite = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: 150))
        shaderSprite.shader = shader
        cropNode.addChild(shaderSprite)

        // Start scaled down and invisible
        cropNode.setScale(0.3)
        cropNode.alpha = 0

        addChild(cropNode)

        // Animate: fade in + scale up + slight overshoot
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.4)
        scaleUp.timingMode = .easeOut
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.15)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)

        let appear = SKAction.group([
            SKAction.sequence([scaleUp, scaleBack]),
            fadeIn
        ])

        // Subtle pulse while waiting
        let pulseUp = SKAction.scale(to: 1.03, duration: 0.8)
        pulseUp.timingMode = .easeInEaseOut
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.8)
        pulseDown.timingMode = .easeInEaseOut
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown]))

        // Run appear animation, then pulse
        cropNode.run(SKAction.sequence([appear, pulse]))

        // After delay, transition to title
        let waitAction = SKAction.wait(forDuration: 3)
        let blockAction = SKAction.run { [unowned self] in
            self.gamemanager.submitScore()
            GameGlobals.instance.reset()
            self.gamemanager.stateMachine.enter(GameTitleState.self)
        }
        run(SKAction.sequence([waitAction, blockAction]))
    }
}
