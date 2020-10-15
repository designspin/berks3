//
//  BrickTileEntity.swift
//  idiots
//
//  Created by Jason Foster on 06/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameplayKit

enum EntityColor: UInt32 {
    case red
    case darkred
    case green
    case darkgreen
    case yellow
    case darkyellow
    case blue
    case darkblue
    case purple
    case darkpurple
    case cyan
    case darkcyan
    case grey
    case darkgrey
    
    #if os(iOS) || os(tvOS) || os(watchOS)
        typealias Color = UIColor
    #elseif os(OSX)
        typealias Color = NSColor
    #endif
    
    private static let _count: EntityColor.RawValue = {
        var maxValue: UInt32 = 0
        while let _ = EntityColor(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func randomColor() -> EntityColor {
        let rand = arc4random_uniform(_count)
        return EntityColor(rawValue: rand)!
    }
    
    static func randomUiColor() -> (ui: Color, vec: vector_float4) {
        switch EntityColor.randomColor() {
        case .red:
            return ( Color.init(red: 178.0/255.0, green: 112.0/255.0, blue: 105.0/255.0, alpha: 1), vector4(178.0/255.0, 112.0/255.0, 105.0/255.0, 1))
            //return UIColor.init(red: 178.0/255.0, green: 112.0/255.0, blue: 105.0/255.0, alpha: 1)
        case .darkred:
            return ( Color.init(red: 141.0/255.0, green: 69.0/255.0, blue: 60.0/255.0, alpha: 1), vector4(141.0/255.0, 69.0/255.0, 60.0/255.0, 1))
            //return UIColor.init(red: 141.0/255.0, green: 69.0/255.0, blue: 60.0/255.0, alpha: 1)
        case .green:
            return (Color.init(red: 99.0/255.0, green: 161.0/255.0, blue: 62.0/255.0, alpha: 1), vector4(99.0/255.0, 161.0/255.0, 62.0/255.0, 1))
            //return UIColor.init(red: 99.0/255.0, green: 161.0/255.0, blue: 62.0/255.0, alpha: 1)
        case .darkgreen:
            return (Color.init(red: 55.0/255.0, green: 123.0/255.0, blue: 18.0/255.0, alpha: 1), vector4(55.0/255.0, 123.0/255.0, 18.0/255.0, 1))
            //return UIColor.init(red: 55.0/255.0, green: 123.0/255.0, blue: 18.0/255.0, alpha: 1)
        case .yellow:
            return (Color.init(red: 136.0/255.0, green: 147.0/255.0, blue: 39.0/255.0, alpha: 1), vector4(136.0/255.0, 147.0/255.0, 39.0/255.0,1))
            //return UIColor.init(red: 136.0/255.0, green: 147.0/255.0, blue: 39.0/255.0, alpha: 1)
        case .darkyellow:
            return (Color.init(red: 96.0/255.0, green: 107.0/255.0, blue: 17.0/255.0, alpha: 1), vector4(96.0/255.0, 107.0/255.0, 17.0/255.0, 1))
            //return UIColor.init(red: 96.0/255.0, green: 107.0/255.0, blue: 17.0/255.0, alpha: 1)
        case .blue:
            return (Color.init(red: 128.0/255.0, green: 119.0/255.0, blue: 214.0/255.0, alpha: 1), vector4(128.0/255.0, 119.0/255.0, 214.0/255.0, 1))
            //return UIColor.init(red: 128.0/255.0, green: 119.0/255.0, blue: 214.0/255.0, alpha: 1)
        case .darkblue:
            return (Color.init(red: 87.0/255.0, green: 77.0/255.0, blue: 179.0/255.0, alpha: 1), vector4(87.0/255.0, 77.0/255.0, 179.0/255.0, 1))
            //return UIColor.init(red: 87.0/255.0, green: 77.0/255.0, blue: 179.0/255.0, alpha: 1)
        case .purple:
            return (Color.init(red: 163.0/255.0, green: 103.0/255.0, blue: 196.0/255.0, alpha: 1), vector4(163.0/255.0, 103.0/255.0, 196.0/255.0, 1))
            //return UIColor.init(red: 163.0/255.0, green: 103.0/255.0, blue: 196.0/255.0, alpha: 1)
        case .darkpurple:
            return (Color.init(red: 125.0/255.0, green: 60.0/255.0, blue: 160.0/255.0, alpha: 1), vector4(125.0/255.0, 60.0/255.0, 160.0/255.0, 1))
            //return UIColor.init(red: 125.0/255.0, green: 60.0/255.0, blue: 160.0/255.0, alpha: 1)
        case .cyan:
            return (Color.init(red: 83.0/255.0, green: 151.0/255.0, blue: 159.0/255.0, alpha: 1), vector4(83.0/255.0, 151.0/255.0, 159.0/255.0, 1))
            //return UIColor.init(red: 83.0/255.0, green: 151.0/255.0, blue: 159.0/255.0, alpha: 1)
        case .darkcyan:
            return (Color.init(red: 35.0/255.0, green: 112.0/255.0, blue: 120.0/255.0, alpha: 1), vector4(35.0/255.0, 112.0/255.0, 120.0/255.0, 1))
            //return UIColor.init(red: 35.0/255.0, green: 112.0/255.0, blue: 120.0/255.0, alpha: 1)
        case .grey:
            return (Color.init(red: 132.0/255.0, green: 132.0/255.0, blue: 132.0/255.0, alpha: 1), vector4(132.0/255.0, 132.0/255.0, 132.0/255.0, 1))
           // return UIColor.init(red: 132.0/255.0, green: 132.0/255.0, blue: 132.0/255.0, alpha: 1)
        case .darkgrey:
            return ( Color.init(red: 91.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1), vector4(91.0/255.0, 91.0/255.0, 91.0/255.0, 1))
            //return UIColor.init(red: 91.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1)
        }
    }
}

class BrickTileEntity: GKEntity, ContactNotifiableType {
   
    var brickRectangle:CGRect!
    var brickStength:Int = 0
    let textureList: Array<SKTexture>!
    var color: vector_float4!
    var location:CGPoint!
    var size:CGSize!
    
    static var shader:SKShader = {
        let shader = SKShader(fileNamed: "berk.fsh")
        shader.attributes = [
            SKAttribute(name: "u_color", type: .vectorFloat4)
        ]
        return shader
    }()
    
    static var playSound = SKAction.playSoundFileNamed("brickDestroy", waitForCompletion: false)
    static var playDestroy = SKAction.playSoundFileNamed("brickDestroyFinal", waitForCompletion: true)
    
    init(location: CGPoint, size: CGSize, center: CGPoint) {
        let atlas = SKTextureAtlas(named: "berks")
        brickRectangle = CGRect(x: location.x, y: location.y, width: size.width, height: size.height)
        
        textureList = [atlas.textureNamed("brick_1"),
                       atlas.textureNamed("brick_2"),
                       atlas.textureNamed("brick_3"),
                       atlas.textureNamed("brick_4")];
        
        self.location = location
        self.size = size
    
        super.init()
        
        reset()
    }
    
    func reset() {
        brickStength = 0
        
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            spriteComponent.node.texture = textureList[0]
        } else {
            let spriteComponent = SpriteComponent(texture: textureList[0])
            spriteComponent.node.position = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
            spriteComponent.node.scale(to: CGSize(width: spriteComponent.node.size.width * 0.98, height: spriteComponent.node.size.height * 0.98))
            color = EntityColor.randomUiColor().vec
            spriteComponent.node.shader = BrickTileEntity.shader
            spriteComponent.node.setValue(SKAttributeValue(vectorFloat4: color),
                                          forAttribute: "u_color")
            addComponent(spriteComponent)
            
            let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: size), colliderType: .Obstacle)
            
            physicsComponent.physicsBody.isDynamic = false
            spriteComponent.node.physicsBody = physicsComponent.physicsBody
            addComponent(physicsComponent)
        }
    }
    
    func hitByLazer() {
        brickStength = brickStength + 1
        
        if let spriteComponent = component(ofType: SpriteComponent.self) {
            if(brickStength  > 2) {
                
                let actionOne = SKAction.run {[unowned self] in
                    self.removeComponent(ofType: PhysicsComponent.self)
                    spriteComponent.node.alpha = 0
                }
                
                let actionBlock = SKAction.run {[unowned self] in
                    weak var accessEntityManager  = spriteComponent.node.scene as? GameScene
                    
                    accessEntityManager?.entityManager.remove(entity: self)
                    self.removeComponent(ofType: SpriteComponent.self)
                    GameGlobals.instance.score += 10
                }
                
                let actionSequence = SKAction.sequence([actionOne,BrickTileEntity.playDestroy,actionBlock])
                spriteComponent.node.run(actionSequence)
                
            } else {
                spriteComponent.node.run(BrickTileEntity.playSound)
                spriteComponent.node.texture = textureList[brickStength]
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint) {
        if(entity.isKind(of: LazerEntity.self)) {
            hitByLazer()
        }
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint) {
        
    }
}

