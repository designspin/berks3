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
        
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.verticalAlignmentMode = .center
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.fontSize = 75
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(gameOverLabel)
        
        let waitAction = SKAction.wait(forDuration: 3)
        let blockAction = SKAction.run {[unowned self] in
            self.gamemanager.submitScore()
            GameGlobals.instance.reset()
            gameOverLabel.removeFromParent()
            self.gamemanager.stateMachine.enter(GameTitleState.self)
        }
        let actionSequence = SKAction.sequence([waitAction,blockAction])
        gameOverLabel.run(actionSequence)
    }
}
