//
//  GameManager.swift
//  Berks 3
//
//  Created by Jason Foster on 15/10/2020.
//  Copyright © 2020 Jason Foster. All rights reserved.
//

import GameKit

protocol GameManager: AnyObject {
    var stateMachine: GKStateMachine! { get set }
    var currentScene: SKScene? { get set }
    var emptyTiles:[Int:Array<CGRect>] { get set }
    var doorTiles:[Int:Set<DoorEntity>] { get set }
    var edgeTiles:Array<EdgeTileEntity> { get set }
    var brickTiles:Set<BrickTileEntity> { get set }
    var keyTiles:Set<KeyEntity> { get set }
    var lifeTiles:Set<LifeEntity> { get set }
    var gateTiles:Set<PostEntity> { get set }
    var wallMap:SKTileMapNode! { get set }
    var prizeEntity:PrizeEntity! { get set }
    func setupGameScene() -> GameScene
    func didEnterTitleScene()
    func didEnterPlayScene()
    func didEnterGameOverScene()
    
    var gameScene:GameScene! { get set }
    
    var gamePad:Any? { get set }
    
    func submitScore()
    func showLeaderboard()
}
