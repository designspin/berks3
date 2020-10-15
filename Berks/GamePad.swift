//
//  GamePad.swift
//  idiots
//
//  Created by Jason Foster on 13/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit

class GamePad: SKShapeNode {
    
    var stickActive:Bool = false
    var knob:SKShapeNode!
    var x:CGFloat = 0
    var y:CGFloat = 0
    
    override init() {
        super.init();
    }
    
    convenience init(width: CGFloat, attachto: SKCameraNode, atposition: CGPoint) {
        self.init(circleOfRadius: width/2)
        self.fillColor = UIColor.white
        self.position = atposition
        self.alpha = 0.2
        self.isUserInteractionEnabled = true;
        
        knob = SKShapeNode(circleOfRadius: (width/2) / 2)
        knob.fillColor = UIColor.white
        knob.alpha = 0.5
        
        self.addChild(knob)
        attachto.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let max = self.frame.size.width / 2 - knob.frame.size.width / 2
            
            if ( location.x < max
                && location.y < max
                && location.x > -max
                && location.y > -max
                ) {
                self.stickActive = true
            } else {
                self.stickActive = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if(stickActive == true) {
                let v = CGVector(dx: location.x, dy: location.y)
                let ang = atan2(v.dy, v.dx) - 1.57079633
                let min = self.frame.size.width / 2
                let max = self.frame.size.width / 2 - knob.frame.size.width / 2
                let actual:CGFloat = CGFloat(hypotf(Float(location.x - self.position.x), Float(location.y - self.position.y)))
                let norm = (actual - min) / (max - min);
                let distX:CGFloat = sin(ang) * max;
                let distY:CGFloat = -cos(ang) * max;
                
                if ( location.x < max
                    && location.y < max
                    && location.x > -max
                    && location.y > -max
                    ) {
                    knob.position = location
                    print(norm)
                } else {
                    knob.position = CGPoint(x: -distX, y: -distY)
                    print(norm)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(stickActive == true) {
            let move:SKAction = SKAction.move(to: CGPoint.zero, duration: 0.2)
            move.timingMode = .easeOut
            
            knob.run(move)
        }
    }
}
