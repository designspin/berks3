//
//  RetroBorderNode.swift
//  Berks
//
//  Retro CRT-style border effect for letterbox areas
//

import SpriteKit

class RetroBorderNode: SKNode {

    #if os(iOS) || os(tvOS) || os(watchOS)
     typealias Color = UIColor
    #elseif os(OSX)
     typealias Color = NSColor
    #endif

    init(sceneSize: CGSize, roomSize: CGSize) {
        super.init()

        // Room is centered at (0,0) in camera-local coordinates
        let roomHalfW = roomSize.width / 2   // 320
        let roomHalfH = roomSize.height / 2  // 176
        let sceneHalfW = sceneSize.width / 2
        let sceneHalfH = sceneSize.height / 2

        // Determine letterbox orientation
        let hasHorizontalLetterbox = sceneSize.width > roomSize.width + 1   // Side bars
        let hasVerticalLetterbox = sceneSize.height > roomSize.height + 1   // Top/bottom bars

        // Animated retro shader - uses pixel coordinates for consistent pattern
        let shaderSource = """
        void main() {
            // Convert UV to pixel coordinates for consistent pattern density
            vec2 pixelCoord = v_tex_coord * a_sprite_size;

            // Diagonal stripes at fixed pixel density (every ~30 pixels)
            float stripe = sin((pixelCoord.x + pixelCoord.y) * 0.1 - u_time * 0.5) * 0.5 + 0.5;
            stripe = smoothstep(0.3, 0.7, stripe);

            // Base colors - dark blue tones
            vec3 darkColor = vec3(0.01, 0.02, 0.04);
            vec3 lightColor = vec3(0.03, 0.08, 0.14);

            // Mix based on stripe
            vec3 color = mix(darkColor, lightColor, stripe * 0.7);

            // Subtle pulsing
            float pulse = sin(u_time * 1.5) * 0.015 + 0.015;
            color += vec3(0.0, pulse * 0.5, pulse);

            // Scanlines at fixed pixel density (every 3 pixels)
            float scanline = sin(pixelCoord.y * 2.0) * 0.02;
            color += scanline;

            gl_FragColor = vec4(color, 1.0);
        }
        """

        // Helper to create shader with sprite size uniform
        func makeShader(size: CGSize) -> SKShader {
            let shader = SKShader(source: shaderSource)
            shader.uniforms = [
                SKUniform(name: "a_sprite_size", vectorFloat2: vector_float2(Float(size.width), Float(size.height)))
            ]
            return shader
        }

        if hasVerticalLetterbox {
            // Top/bottom letterbox (view is taller than room aspect)
            let barHeight = sceneHalfH - roomHalfH
            let barSize = CGSize(width: sceneSize.width, height: barHeight)

            // Bottom bar
            let bottomBar = SKSpriteNode(color: Color.black, size: barSize)
            bottomBar.shader = makeShader(size: barSize)
            bottomBar.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            bottomBar.position = CGPoint(x: 0, y: -roomHalfH)
            self.addChild(bottomBar)

            // Top bar
            let topBar = SKSpriteNode(color: Color.black, size: barSize)
            topBar.shader = makeShader(size: barSize)
            topBar.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            topBar.position = CGPoint(x: 0, y: roomHalfH)
            self.addChild(topBar)
        }

        if hasHorizontalLetterbox {
            // Left/right letterbox (view is wider than room aspect)
            let barWidth = sceneHalfW - roomHalfW
            let barSize = CGSize(width: barWidth, height: sceneSize.height)

            // Left bar
            let leftBar = SKSpriteNode(color: Color.black, size: barSize)
            leftBar.shader = makeShader(size: barSize)
            leftBar.anchorPoint = CGPoint(x: 1.0, y: 0.5)
            leftBar.position = CGPoint(x: -roomHalfW, y: 0)
            self.addChild(leftBar)

            // Right bar
            let rightBar = SKSpriteNode(color: Color.black, size: barSize)
            rightBar.shader = makeShader(size: barSize)
            rightBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            rightBar.position = CGPoint(x: roomHalfW, y: 0)
            self.addChild(rightBar)
        }

        // Subtle border at room edge
        let borderColor = Color(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0)
        let borderWidth: CGFloat = 2

        let borders = [
            (CGSize(width: roomSize.width, height: borderWidth), CGPoint(x: 0, y: -roomHalfH), CGPoint(x: 0.5, y: 1.0)),
            (CGSize(width: roomSize.width, height: borderWidth), CGPoint(x: 0, y: roomHalfH), CGPoint(x: 0.5, y: 0.0)),
            (CGSize(width: borderWidth, height: roomSize.height + borderWidth * 2), CGPoint(x: -roomHalfW, y: 0), CGPoint(x: 1.0, y: 0.5)),
            (CGSize(width: borderWidth, height: roomSize.height + borderWidth * 2), CGPoint(x: roomHalfW, y: 0), CGPoint(x: 0.0, y: 0.5))
        ]

        for (size, pos, anchor) in borders {
            let border = SKSpriteNode(color: borderColor, size: size)
            border.anchorPoint = anchor
            border.position = pos
            border.zPosition = 1
            self.addChild(border)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
