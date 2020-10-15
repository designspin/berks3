//
//  JoyButton.swift
//  idiots
//
//  Created by Jason Foster on 03/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit

class FireButtonComponent:SKSpriteNode {
    private var context = UInt8(1)
    
    var image: UIImage? {
        didSet {
            redrawTexture()
        }
    }
    
    var diameter: CGFloat {
        get {
            return max(size.width, size.height)
        }
        set(newsize) {
            size = CGSize(width: newsize, height: newsize)
        }
    }
    
    var radius: CGFloat {
        get {
            return diameter * 0.5
        }
        
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    // MARK: Designated
    init(diameter: CGFloat, color: UIColor? = nil, image: UIImage? = nil) {
        super.init(texture: nil, color: color ?? UIColor.white, size: CGSize(width: diameter, height: diameter))
        self.diameter = diameter
        self.image = image
        redrawTexture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func redrawTexture() {
        
        guard diameter > 0 else {
            print("Diameter should be more than zero")
            texture = nil
            return
        }
        
        let scale = UIScreen.main.scale
        let needSize = CGSize(width: self.diameter, height: self.diameter)
        UIGraphicsBeginImageContextWithOptions(needSize, false, scale)
        let rectPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: needSize))
        rectPath.addClip()
        if let img = image {
            img.draw(in: CGRect(origin: CGPoint.zero, size: needSize), blendMode: .normal, alpha: 1)
        } else {
            color.set()
            rectPath.fill()
        }
        
        let needImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        texture = SKTexture(image: needImage)
    }
}

class FireButton: SKNode {
    var beginHandler: (() -> Void)?
    var stopHandler: (() -> Void)?
    var component: FireButtonComponent!
    
    var disabled: Bool {
        get {
            return !isUserInteractionEnabled
        }
        
        set(isDisabled) {
            isUserInteractionEnabled = !isDisabled
        }
    }
    
    var diameter: CGFloat {
        get {
            return component.diameter
        }
        
        set(newDiameter) {
            component.diameter = newDiameter
        }
    }
    
    var radius: CGFloat {
        get {
            return diameter * 0.5
        }
        
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    init(component: FireButtonComponent) {
        super.init()
        self.component = component
        component.zPosition = 0
        disabled = false
        addChild(component)        
    }
    
    convenience init(diameter: CGFloat, color:UIColor? = nil, image:UIImage? = nil) {
        let btnColor = color ?? nil
        let btnImage = image ?? nil
        let component = FireButtonComponent(diameter: diameter, color: btnColor, image: btnImage)
        self.init(component: component)
    }
    
     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginHandler?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopHandler?()
    }
}
