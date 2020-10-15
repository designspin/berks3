//
//  GamePlayState.swift
//  idiots
//
//  Created by Jason Foster on 24/11/2017.
//  Copyright © 2017 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class GamePlayState: GKState {
    weak var controller: GameManager?
    
    #if os(iOS) || os(tvOS) || os(watchOS)
        init(withController: UIViewController) {
            controller = withController as? GameManager
        }
    #elseif os(OSX)
        init(withController: NSViewController) {
            controller = withController as? GameManager
        }
    #endif

    override func didEnter(from previousState: GKState?) {
        controller?.didEnterPlayScene()
    }
}
