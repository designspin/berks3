//
//  GameTitleState.swift
//  idiots
//
//  Created by Jason Foster on 24/11/2017.
//  Copyright © 2017 Jason Foster. All rights reserved.
//

import SpriteKit
import GameKit

class GameTitleState: GKState {
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
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
            case is GamePlayState.Type:
                return true
            default:
                return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        controller?.didEnterTitleScene()
    }
}
