//
//  texture.swift
//  idiots
//
//  Created by Jason Foster on 23/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import Foundation
import CoreImage

struct EFUIntPixel {
    var red: UInt8 = 0
    var green: UInt8 = 0
    var blue: UInt8 = 0
    var alpha: UInt8 = 0
}

extension CIImage {
    
    func replace(colorOld: EFUIntPixel, colorNew: EFUIntPixel) -> CIImage? {
        let cubeSize = 64
        let cubeData = { () -> [Float] in
            let selectColor = (Float(colorOld.red) / 255.0, Float(colorOld.green) / 255.0, Float(colorOld.blue) / 255.0, Float(colorOld.alpha) / 255.0)
            let raplaceColor = (Float(colorNew.red) / 255.0, Float(colorNew.green) / 255.0, Float(colorNew.blue) / 255.0, Float(colorNew.alpha) / 255.0)
            
            var data = [Float](repeating: 0, count: cubeSize * cubeSize * cubeSize * 4)
            var tempRGB: [Float] = [0, 0, 0]
            var newRGB: (r : Float, g : Float, b : Float, a: Float)
            var offset = 0
            for z in 0 ..< cubeSize {
                tempRGB[2] = Float(z) / Float(cubeSize) // blue value
                for y in 0 ..< cubeSize {
                    tempRGB[1] = Float(y) / Float(cubeSize) // green value
                    for x in 0 ..< cubeSize {
                        tempRGB[0] = Float(x) / Float(cubeSize) // red value
                        // Select colorOld
                        if tempRGB[0] == selectColor.0 && tempRGB[1] == selectColor.1 && tempRGB[2] == selectColor.2 {
                            newRGB = (raplaceColor.0, raplaceColor.1, raplaceColor.2, raplaceColor.3)
                        } else {
                            newRGB = (tempRGB[0], tempRGB[1], tempRGB[2], 1)
                        }
                        data[offset] = newRGB.r
                        data[offset + 1] = newRGB.g
                        data[offset + 2] = newRGB.b
                        data[offset + 3] = 1.0
                        offset += 4
                    }
                }
            }
            return data
        }()
        
        let data = cubeData.withUnsafeBufferPointer { Data(buffer: $0) } as NSData
        let colorCube = CIFilter(name: "CIColorCube")!
        colorCube.setValue(cubeSize, forKey: "inputCubeDimension")
        colorCube.setValue(data, forKey: "inputCubeData")
        colorCube.setValue(self, forKey: kCIInputImageKey)
        return colorCube.outputImage
    }
}
