//
//  DashboardSprite.swift
//  idiots
//
//  Created by Jason Foster on 11/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit

class DashboardSprite: SKSpriteNode {
    
    var score:SKLabelNode!
    var lives:SKLabelNode!
    var room:SKLabelNode!
    var keys:SKLabelNode!
    
    #if os(iOS) || os(tvOS) || os(watchOS)
     typealias Color = UIColor
    #elseif os(OSX)
     typealias Color = NSColor
    #endif
    
    init(_ rect:CGRect) {
        super.init(texture: nil, color: Color.blue, size: rect.size)
        
        self.anchorPoint = CGPoint.zero
        self.position = CGPoint(x: rect.minX, y: rect.minY)
        self.zPosition = 999
        
        score = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        score.text = "SC:\(GameGlobals.instance.score)"
        
        if rect.height < 32 {
            score.fontSize = 12
        } else {
            score.fontSize = 18
        }
        score.horizontalAlignmentMode = .center
        score.verticalAlignmentMode = .center
        score.color = Color.white
        score.position = CGPoint(x: self.frame.width / 8, y: self.frame.height / 2)
        GameGlobals.instance.addListener(name: "score", object: score)
        
        lives = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        lives.text = "LIVES:\(GameGlobals.instance.lives)"
        
        if rect.height < 32 {
            lives.fontSize = 12
        } else {
            lives.fontSize = 18
        }
        lives.horizontalAlignmentMode = .center
        lives.verticalAlignmentMode = .center
        lives.color = Color.white
        lives.position = CGPoint(x: (self.frame.width / 5) * 2, y: self.frame.height / 2)
        GameGlobals.instance.addListener(name: "lives", object: lives)
        
        room = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        room.text = "ROOM:\(GameGlobals.instance.room)"
        
        if rect.height < 32 {
            room.fontSize = 12
        } else {
            room.fontSize = 18
        }
        
        room.horizontalAlignmentMode = .center
        room.verticalAlignmentMode = .center
        room.color = Color.white
        room.position = CGPoint(x: (self.frame.width / 5) * 3, y: self.frame.height / 2)
        GameGlobals.instance.addListener(name: "room", object: room)
        
        keys = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
        keys.text = "KEYS:\(GameGlobals.instance.keys)"
        
        if rect.height < 32 {
            keys.fontSize = 12
        } else {
            keys.fontSize = 18
        }
        
        keys.horizontalAlignmentMode = .center
        keys.verticalAlignmentMode = .center
        keys.color = Color.white
        keys.position = CGPoint(x: (self.frame.width / 5) * 4, y: self.frame.height / 2)
        GameGlobals.instance.addListener(name: "keys", object: keys)
        
        self.addChild(score)
        self.addChild(lives)
        self.addChild(room)
        self.addChild(keys)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
