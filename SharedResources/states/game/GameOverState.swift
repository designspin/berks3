//
//  GameOverState.swift
//  idiots
//
//  Created by Jason Foster on 25/04/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class GameOverState: GKState {
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
        controller?.didEnterGameOverScene()
    }
}
