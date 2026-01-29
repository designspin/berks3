//
//  DashboardSprite.swift
//  idiots
//
//  Created by Jason Foster on 11/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit

class DashboardSprite: SKNode {

    var score:SKLabelNode!
    var lives:SKLabelNode!
    var room:SKLabelNode!
    var keys:SKLabelNode!

    #if os(iOS) || os(tvOS) || os(watchOS)
     typealias Color = UIColor
    #elseif os(OSX)
     typealias Color = NSColor
    #endif

    // HUD - placed in letterbox if there's room, otherwise overlaid on game
    init(roomSize: CGSize, letterboxHeight: CGFloat = 0) {
        super.init()

        self.zPosition = 999

        let barHeight: CGFloat = 24
        let fontSize: CGFloat = 12
        let roomBottom = -roomSize.height / 2

        // If letterbox has enough space, put HUD there (no overlay on game)
        let useLetterbox = letterboxHeight >= barHeight

        if useLetterbox {
            // Position in letterbox area below the room - no background needed
            let hudY = roomBottom - letterboxHeight / 2
            setupLabels(roomSize: roomSize, fontSize: fontSize, hudY: hudY)
        } else {
            // Overlay on game with semi-transparent background
            let bgBar = SKSpriteNode(
                color: Color.black.withAlphaComponent(0.5),
                size: CGSize(width: roomSize.width, height: barHeight)
            )
            bgBar.anchorPoint = CGPoint(x: 0.5, y: 0)
            bgBar.position = CGPoint(x: 0, y: roomBottom)
            self.addChild(bgBar)

            let hudY = roomBottom + barHeight / 2
            setupLabels(roomSize: roomSize, fontSize: fontSize, hudY: hudY)
        }
    }

    private func setupLabels(roomSize: CGSize, fontSize: CGFloat, hudY: CGFloat) {

        score = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        score.text = "SC:\(GameGlobals.instance.score)"
        score.fontSize = fontSize
        score.horizontalAlignmentMode = .center
        score.verticalAlignmentMode = .center
        score.fontColor = Color.white
        score.position = CGPoint(x: -roomSize.width / 2 + roomSize.width / 8, y: hudY)
        score.zPosition = 1
        GameGlobals.instance.addListener(name: "score", object: score)
        self.addChild(score)

        lives = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        lives.text = "LIVES:\(GameGlobals.instance.lives)"
        lives.fontSize = fontSize
        lives.horizontalAlignmentMode = .center
        lives.verticalAlignmentMode = .center
        lives.fontColor = Color.white
        lives.position = CGPoint(x: -roomSize.width / 2 + (roomSize.width / 5) * 2, y: hudY)
        lives.zPosition = 1
        GameGlobals.instance.addListener(name: "lives", object: lives)
        self.addChild(lives)

        room = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        room.text = "ROOM:\(GameGlobals.instance.room)"
        room.fontSize = fontSize
        room.horizontalAlignmentMode = .center
        room.verticalAlignmentMode = .center
        room.fontColor = Color.white
        room.position = CGPoint(x: -roomSize.width / 2 + (roomSize.width / 5) * 3, y: hudY)
        room.zPosition = 1
        GameGlobals.instance.addListener(name: "room", object: room)
        self.addChild(room)

        keys = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        keys.text = "KEYS:\(GameGlobals.instance.keys)"
        keys.fontSize = fontSize
        keys.horizontalAlignmentMode = .center
        keys.verticalAlignmentMode = .center
        keys.fontColor = Color.white
        keys.position = CGPoint(x: -roomSize.width / 2 + (roomSize.width / 5) * 4, y: hudY)
        keys.zPosition = 1
        GameGlobals.instance.addListener(name: "keys", object: keys)
        self.addChild(keys)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
