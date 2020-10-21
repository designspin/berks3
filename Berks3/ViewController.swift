//
//  ViewController.swift
//  Berks3
//
//  Created by Jason Foster on 15/10/2020.
//  Copyright © 2020 Jason Foster. All rights reserved.
//

import Cocoa
import SpriteKit
import GameKit
import GameplayKit

struct RoomPoints {
    var points: [[(Int,Int)]]
}

//MARK: AnalogJoystickData
public struct AnalogJoystickData: CustomStringConvertible {
    var velocity = CGPoint.zero,
    angular = CGFloat(0)
    
    mutating func reset() {
        velocity = CGPoint.zero
        angular = 0
    }
    
    public var description: String {
        return "AnalogStickData(velocity: \(velocity), angular: \(angular))"
    }
}


class ViewController: NSViewController, GKGameCenterControllerDelegate, GameManager {
    
    var stateMachine: GKStateMachine!
    var currentScene: SKScene?
    var emptyTiles = [Int : Array<CGRect>]()
    var doorTiles = [Int : Set<DoorEntity>]()
    var edgeTiles = Array<EdgeTileEntity>()
    var brickTiles = Set<BrickTileEntity>()
    var keyTiles = Set<KeyEntity>()
    var lifeTiles = Set<LifeEntity>()
    var gateTiles = Set<PostEntity>()
    var prizeEntity:PrizeEntity!
    var gameScene: GameScene!
    var gamePad: Any?
    
    var points:[String: RoomPoints] = [
        "room1":RoomPoints(points: [
            [(0,1760),(640,0),(640,-64),(576,-64),(576,-32),(32,-32),(32,-288),(64,-288),(64, -320),(448,-320),(448, -352),(0,-352),(0,0)],
            [(576,1632),(64,0),(64,-96),(32,-96),(32,-64),(0,-64),(0,0)],
            [(608, 1472),(32,0),(32,-64),(-64,-64),(-64,-32),(0,-32),(0,0)]
        ]),
        "room2":RoomPoints(points: [
            [(640,1760),(640,0),(640,-64),(608,-64),(608,-32),(96,-32),(96,-64),(0,-64),(0,0)],
            [(640,1632),(32,0),(32,-32),(352,-32),(352,-192),(608,-192),(608,-32),(640,-32),(640,-224),(256,-224),(256,-192),(320,-192),(320,-64),(32,-64),(32,-96),(0,-96),(0,0)],
            [(640,1472),(32,0),(32,-32),(64,-32),(64,-64),(0,-64),(0,0)]
        ]),
        "room3":RoomPoints(points: [
            [(1280,1760),(640,0),(640,-128),(608,-128),(608,-32),(384,-32),(384,-96),(352,-96),(352,-32),(320,-32),(320,-160),(288,-160),(288,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(1280,1600),(32,0),(32,-160),(416,-160),(416,-64),(448,-64),(448,-160),(608,-160),(608,-96),(640,-96),(640,-192),(0,-192),(0,0)]
        ]),
        "room4":RoomPoints(points: [
            [(1920,1760),(640,0),(640,-64),(512,-64),(512,-32),(32,-32),(32,-96),(160,-96),(160,-128),(0,-128),(0,0)],
            [(1920,1504),(32,0),(32,-64),(96,-64),(96,-96),(0,-96),(0,0)],
            [(2528,1536),(32,0),(32,-128),(-96,-128),(-96,-96),(0,-96),(0,0)]
        ]),
        "room5":RoomPoints(points: [
            [(2560,1760),(640,0),(640,-352),(544,-352),(544,-320),(608,-320),(608,-32),(64,-32),(64,-64),(0,-64),(0,0)],
            [(2560,1536),(480,0),(480,64),(544,64),(544,32),(512,32),(512,-32),(32,-32),(32,-96),(64,-96),(64,-128),(0,-128),(0,0)]
        ]),
        "room6":RoomPoints(points: [
            [(3200,1760),(640,0),(640,-352),(608,-352),(608,-32),(32,-32),(32,-320),(544,-320),(544,-352),(0,-352),(0,0)]
        ]),
        "room7":RoomPoints(points: [
            [(0,1408),(448,0),(448,-32),(32,-32),(32,-320),(224,-320),(224,-224),(256,-224),(256,-352),(0,-352),(0,0)],
            [(544,1408),(96,0),(96,-96),(64,-96),(64,-32),(0,-32),(0,0)],
            [(576,1248),(64,0),(64,-192),(-224,-192),(-224,-64),(-192,-64),(-192,-160),(32,-160),(32,-32),(0,-32),(0,0)]
        ]),
        "room8":RoomPoints(points: [
            [(640,1408),(64,0),(64,-32),(32,-32),(32,-96),(0,-96),(0,0)],
            [(896,1408),(384,0),(384,-32),(0,-32),(0,0)],
            [(1120,1280),(160,0),(160,-224),(-192,-224),(-192,-192),(128,-192),(128,-32),(0,-32),(0,0)],
            [(640,1248),(32,0),(32,-160),(160,-160),(160,-192),(0,-192),(0,0)]
        ]),
        "room9":RoomPoints(points: [
            [(1280,1408),(640,0),(640,-96),(608,-96),(608,-32),(0,-32),(0,0)],
            [(1280,1280),(32,0),(32,-192),(608,-192),(608,-128),(640,-128),(640,-224),(0,-224),(0,0)],
            [(1568,1248),(64,0),(64,-32),(0,-32),(0,0)],
            [(1760,1248),(160,0),(160,-32),(0,-32),(0,0)]
        ]),
        "room10":RoomPoints(points: [
            [(1920,1408),(96,0),(96,-32),(64,-32),(64,-64),(32,-64),(32,-96),(0,-96),(0,0)],
            [(2432,1408),(128,0),(128,-128),(96,-128),(96,-96),(64,-96),(64,-64),(32,-64),(32,-32),(0,-32),(0,0)],
            [(1920,1248),(128,0),(128,-32),(0,-32),(0,0)],
            [(1920,1152),(32,0),(32,-64),(608,-64),(608,32),(640,32),(640,-96),(0,-96),(0,0)]
        ]),
        "room11":RoomPoints(points: [
            [(2560,1408),(64,0),(64,-64),(32,-64),(32,-128),(0,-128),(0,0)],
            [(2560,1184),(32,0),(32,-128),(0,-128),(0,0)],
            [(2752,1312),(224,0),(224,-224),(256,-224),(256,-256),(192,-256),(192,-32),(32,-32),(32,-256),(-32,-256),(-32,-224),(0,-224),(0,0)],
            [(3104,1408),(96,0),(96,-224),(64,-224),(64,-32),(0,-32),(0,0)],
            [(3168,1120),(32,0),(32,-64),(-32,-64),(-32,-32),(0,-32),(0,0)]
        ]),
        "room12":RoomPoints(points: [
            [(3200,1408),(544,0),(544,-32),(32,-32),(32,-224),(0,-224),(0,0)],
            [(3200,1120),(32,0),(32,-32),(64,-32),(64,-64),(0,-64),(0,0)],
            [(3808,1408),(32,0),(32,-352),(-480,-352),(-480,-320),(0,-320),(0,0)]
        ]),
        "room13":RoomPoints(points: [
            [(0,1056),(256,0),(256,-32),(32,-32),(32,-320),(192,-320),(192,-224),(544,-224),(544,-256),(224,-256),(224,-352),(0,-352),(0,0)],
            [(352,1056),(288,0),(288,-64),(256,-64),(256,-32),(0,-32),(0,0)],
            [(608,928),(32,0),(32,-224),(-160,-224),(-160,-192),(0,-192),(0,0)]
        ]),
        "room14":RoomPoints(points: [
            [(640,1056),(160,0),(160,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(928,1056),(352,0),(352,-352),(160,-352),(160,-288),(192,-288),(192,-320),(320,-320),(320,-32),(0,-32),(0,0)],
            [(640,928),(32,0),(32,-192),(288,-192),(288,-160),(320,-160),(320,-224),(0,-224),(0,0)]
        ]),
        "room15":RoomPoints(points: [
            [(1280,1056),(640,0),(640,-128),(608,-128),(608,-32),(416,-32),(416,-96),(384,-96),(384,-32),(352,-32),(352,-96),(320,-96),(320,-32),(32,-32),(32,-64),(256,-64),(256,-96),(32,-96),(32,-320),(64,-320),(64,-192),(96,-192),(96,-320),(160,-320),(160,-352),(0,-352),(0,0)],
            [(1504,736),(64,0),(64,-32),(0,-32),(0,0)],
            [(1632,736),(64,0),(64,-32),(0,-32),(0,0)],
            [(1760,992),(96,0),(96,-128),(160,-128),(160,-288),(0,-288),(0,-256),(64,-256),(64,-224),(96,-224),(96,-256),(128,-256),(128,-160),(64,-160),(64,-32),(0,-32),(0,0)]
        ]),
        "room16":RoomPoints(points: [
            [(1920,1056),(640,0),(640,-352),(0,-352),(0,-192),(32,-192),(32,-320),(608,-320),(608,-224),(544,-224),(544,-256),(512,-256),(512,-192),(608,-192),(608,-32),(544,-32),(544,-128),(416,-128),(416,-256),(384,-256),(384,-96),(512,-96),(512,-32),(32,-32),(32,-128),(0,-128),(0,0)]
        ]),
        "room17":RoomPoints(points: [
            [(2560,1056),(32,0),(32,-320),(608,-320),(608,-288),(640,-288),(640,-352),(0,-352),(0,0)],
            [(2720,1056),(64,0),(64,-96),(0,-96),(0,0)],
            [(2944,1056),(64,0),(64,-96),(0,-96),(0,0)],
            [(3136,1056),(64,0),(64,-64),(32,-64),(32,-32),(0,-32),(0,0)],
            [(3168,928),(32,0),(32,-96),(0,-96),(0,0)]
        ]),
        "room18":RoomPoints(points: [
            [(3200,1056),(64,0),(64,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(3328,1056),(512,0),(512,-352),(384,-352),(384,-320),(480,-320),(480,-32),(0,-32),(0,0)],
            [(3200,928),(32,0),(32,-96),(0,-96),(0,0)],
            [(3424,832),(192,0),(192,-32),(128,-32),(128,-128),(64,-128),(64,-32),(0,-32),(0,0)],
            [(3200,768),(32,0),(32,-32),(128,-32),(128,-64),(0,-64),(0,0)]
        ]),
        "room19":RoomPoints(points: [
            [(0,704),(224,0),(224,-32),(32,-32),(32,-320),(192,-320),(192,-96),(224,-96),(224,-352),(0,-352),(0,0)],
            [(448,704),(192,0),(192,-352),(64,-352),(64,-320),(96,-320),(96,-288),(128,-288),(128,-256),(160,-256),(160,-32),(0,-32),(0,0)]
        ]),
        "room20":RoomPoints(points: [
            [(640,704),(320,0),(320,-32),(32,-32),(32,-320),(64,-320),(64,-352),(0,-352),(0,0)],
            [(1088,704),(192,0),(192,-192),(160,-192),(160,-160),(128,-160),(128,-128),(96,-128),(96,-96),(64,-96),(64,-64),(32,-64),(32,-32),(0,-32),(0,0)],
            [(960,384),(256,0),(256,32),(288,32),(288,64),(320,64),(320,-32),(0,-32),(0,0)]
        ]),
        "room21":RoomPoints(points: [
            [(1280,704),(160,0),(160,-64),(128,-64),(128,-32),(32,-32),(32,-192),(0,-192),(0,0)],
            [(1504,704),(64,0),(64,-32),(0,-32),(0,0)],
            [(1632,704),(64,0),(64,-32),(0,-32),(0,0)],
            [(1760,704),(160,0),(160,-64),(128,-64),(128,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(1760,545),(160,0),(160,-64),(128,-64),(128,-32),(0,-32),(0,0)],
            [(1280,448),(32,0),(32,-64),(160,-64),(160,-96),(0,-96),(0,0)],
            [(1888,416),(32,0),(32,-64),(-128,-64),(-128,-32),(0,-32),(0,0)]
        ]),
        "room22":RoomPoints(points: [
            [(1920,704),(640,0),(640,-160),(480,-160),(480,-128),(608,-128),(608,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(1920,544),(160,0),(160,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(2400,480),(160,0),(160,-128),(32,-128),(32,-96),(128,-96),(128,-32),(0,-32),(0,0)],
            [(1920,416),(32,0),(32,-32),(64,-32),(64,-64),(0,-64),(0,0)],
            [(2048,384),(64,0),(64,-32),(0,-32),(0,0)],
            [(2176,384),(64,0),(64,-32),(0,-32),(0,0)],
            [(2304,384),(64,0),(64,-32),(0,-32),(0,0)]
        ]),
        "room23":RoomPoints(points: [
            [(2560,704),(640,0),(640,-64),(608,-64),(608,-32),(32,-32),(32,-160),(0,-160),(0,0)],
            [(2560,480),(32,0),(32,-96),(64,-96),(64,-128),(0,-128),(0,0)],
            [(3073,416),(128,0),(128,-64),(0,-64),(0,0)]
        ]),
        "room24":RoomPoints(points:  [
            [(3200,704),(128,0),(128,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(3488,704),(64,0),(64,-352),(-288,-352),(-288,-288),(-256,-288),(-256,-320),(32,-320),(32,-32),(0,-32),(0,0)],
            [(3744,704),(96,0),(96,-352),(64,-352),(64,-32),(0,-32),(0,0)]
        ]),
        "room25":RoomPoints(points: [
            [(0,352),(224,0),(224,-32),(32,-32),(32,-320),(608,-320),(608,-192),(448,-192),(448,-256),(224,-256),(224,-224),(416,-224),(416,-160),(640,-160),(640,-352),(0,-352),(0,0)],
            [(512,352),(128,0),(128,-96),(96,-96),(96,-32),(0,-32),(0,0)]
        ]),
        "room26":RoomPoints(points: [
            [(640,352),(64,0),(64,-32),(32,-32),(32,-96),(0,-96),(0,0)],
            [(960,352),(320,0),(320,-64),(288,-64),(288,-32),(32,-32),(32,-64),(64,-64),(64,-96),(96,-96),(96,-128),(128,-128),(128,-160),(160,-160),(160,-192),(192,-192),(192,-224),(320,-224),(320,-256),(160,-256),(160,-224),(128,-224),(128,-192),(96,-192),(96,-160),(64,-160),(64,-128),(32,-128),(32,-96),(0,-96),(0,0)],
            [(640,192),(32,0),(32,-160),(640,-160),(0,-160),(0,0)]
        ]),
        "room27":RoomPoints(points: [
            [(1280,352),(160,0),(160,-32),(32,-32),(32,-64),(0,-64),(0,0)],
            [(1760,352),(160,0),(160,-192),(-128,-192),(-128,-160),(128,-160),(128,-64),(0,-64),(0,0)],
            [(1280,128),(288,0),(288,-32),(0,-32),(0,0)],
            [(1280,32),(640,0),(640,-32),(0,-32),(0,0)]
        ]),
        "room28":RoomPoints(points: [
            [(1920,352),(64,0),(64,-32),(32,-32),(32,-192),(0,-192),(0,0)],
            [(2048,352),(64,0),(64,-32),(32,-32),(32,-192),(160,-192),(160,-32),(128,-32),(128,0),(192,0),(192,-224),(0,-224),(0,0)],
            [(2304,352),(64,0),(64,-32),(0,-32),(0,0)],
            [(2432,352),(128,0),(128,-128),(32,-128),(32,-224),(0,-224),(0,-96),(96,-96),(96,-32),(0,-32),(0,0)],
            [(1920,32),(608,0),(608,128),(640,128),(640,-32),(0,-32),(0,0)]
        ]),
        "room29":RoomPoints(points: [
            [(2560,352),(64,0),(64,-32),(32,-32),(32,-96),(96,-96),(96,-128),(0,-128),(0,0)],
            [(2560,160),(96,0),(96,-32),(32,-32),(32,-128),(608,-128),(608,160),(544,160),(544,64),(448,64),(448,0),(416,0),(416,96),(512,96),(512,192),(640,192),(640,-160),(0,-160),(0,0)]
        ]),
        "room30":RoomPoints(points: [
            [(3808,352),(32,0),(32,-352),(-608,-352),(-608,0),(-256,0),(-256,-256),(-512,-256),(-512,-96),(-352,-96),(-352,-160),(-384,-160),(-384,-128),(-480,-128),(-480,-224),(-288,-224),(-288,-32),(-576,-32),(-576,-320),(0,-320),(0,0)]
        ])
    ]
    
    var pathsForBoundaries = [String:[CGMutablePath]]()
    var startOfBoundaries = [String:[CGPoint]]()
    
    var wallMap: SKTileMapNode!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        initGameScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initGameScene()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateMachine.enter(GameTitleState.self)
        authenticateLocalPlayer()
    }
    
    override func viewDidAppear() {
        self.startWatchingForControllers()
    }
    
    func initGameScene() {
        
        #if os(OSX)
        if let tempKeyBindings = UserDefaults.standard.dictionary(forKey: "PlayerKeys") {
            for (key, value) in tempKeyBindings {
                GameGlobals.instance.keyBindings[(key)] = (value as! String).first
            }
        }
        #endif
        
        stateMachine = GKStateMachine(states: [
            GameTitleState(withController: self),
            GamePlayState(withController: self),
            GameOverState(withController: self)
        ]);
        
        let gameScene:GKScene? = GKScene(fileNamed: "GameScene.sks")
        let scene = gameScene?.rootNode as! SKScene
        
        wallMap = scene.childNode(withName: "Wall Map") as? SKTileMapNode
        guard let brickMap = scene.childNode(withName: "Brick Map") as? SKTileMapNode else { fatalError("Missing brick map") }
        guard let keyMap = scene.childNode(withName: "Key Map") as? SKTileMapNode else { fatalError("Missing key map") }
        guard let lifeMap = scene.childNode(withName: "Life Map") as? SKTileMapNode else { fatalError("Missing life map") }
        guard let barrierMap = scene.childNode(withName: "Barrier Map") as? SKTileMapNode else { fatalError("Missing barrier map") }
        
        let tileSize = wallMap.tileSize
        let brickSize = brickMap.tileSize
        
        for (key, wallcollection) in points {
            
            startOfBoundaries[key] = [CGPoint]()
            var pathArray = [CGMutablePath]()
            
            for walls in wallcollection.points {
                startOfBoundaries[key]?.append(CGPoint(x: walls[0].0, y: walls[0].1))
                let newWallArray = walls.dropFirst()
                
                let path = CGMutablePath()
                var pointArray = [CGPoint]()
                
                for wall in newWallArray {
                    pointArray.append(CGPoint(x: wall.0, y: wall.1))
                }
                path.addLines(between: pointArray)
                path.closeSubpath()
                pathArray.append(path)
            }
            
            pathsForBoundaries[key] = pathArray
            
            for (index, path) in pathsForBoundaries[key]!.enumerated() {
                let tile = EdgeTileEntity(location: startOfBoundaries[key]![index], path: path)
                edgeTiles.append(tile)
            }
        }
        
        for col in 0...wallMap.numberOfColumns - 1 {
            for row in 0...wallMap.numberOfRows - 1 {
                let tileDefinition = wallMap.tileDefinition(atColumn: col, row: row)
                let key = keyMap.tileDefinition(atColumn: col, row: row)
                let life = lifeMap.tileDefinition(atColumn: col, row: row)
                let brickTopLeft = brickMap.tileDefinition(atColumn: col * 2, row: row * 2 )
                let barrier = barrierMap.tileDefinition(atColumn: col, row: row)
                
                let isTopLeft = brickTopLeft?.userData?["brickTile"] as? Bool
                
                if(isTopLeft ?? false) {
                    let x = CGFloat(col * 2) * brickSize.width
                    let y = CGFloat(row * 2) * brickSize.height
                    let tl = BrickTileEntity(location: CGPoint(x: x, y: y + brickSize.height), size: brickSize, center: CGPoint(x: brickSize.width / 2, y: brickSize.height / 2))
                    let tr = BrickTileEntity(location: CGPoint(x: x + brickSize.width, y: y + brickSize.height), size: brickSize, center: CGPoint(x: brickSize.width / 2, y: brickSize.height / 2))
                    let bl = BrickTileEntity(location: CGPoint(x: x, y: y ), size: brickSize, center: CGPoint(x: brickSize.width / 2, y: brickSize.height / 2))
                    let br = BrickTileEntity(location: CGPoint(x: x + brickSize.width, y: y), size: brickSize, center: CGPoint(x: brickSize.width / 2, y: brickSize.height / 2))
                    brickTiles.insert(tl)
                    brickTiles.insert(tr)
                    brickTiles.insert(bl)
                    brickTiles.insert(br)
                }
                
                let brickHere = (isTopLeft ?? false) ? true : false
                
                let isKeyTile = key?.userData?["keyTile"] as? Bool
                
                if (isKeyTile ?? false) {
                    keyTiles.insert(KeyEntity(location: CGPoint(x: (col * 32) + 16, y: (row * 32) + 16 )))
                }
                
                let isLifeTile = life?.userData?["lifeTile"] as? Bool
                
                if (isLifeTile ?? false) {
                    lifeTiles.insert(LifeEntity(location: CGPoint(x: (col * 32) + 16, y: (row * 32) + 16 )))
                }
                
                let isBarrier = barrier?.userData?["isBarrier"] as? Bool
                
                if (isBarrier ?? false) {
                    let mapCol = floor(CGFloat(col) / 20) + 1
                    let mapRow = 5 - floor(CGFloat(row) / 11)
                    
                    let room = { () -> Int in
                        if(mapRow > 1) {
                            return Int((mapRow - 1) * 6 + mapCol)
                        } else {
                            return Int(mapCol)
                        }
                    }()
                    
                    if(doorTiles[room] == nil) {
                        doorTiles[room] = Set<DoorEntity>()
                    }
                    
                    doorTiles[room]?.insert(DoorEntity(location: CGPoint(x: (col * 32) + 16, y: (row * 32) + 16 )))
                }
                
                let isGate = barrier?.userData?["isPost"] as? Bool
                
                if(isGate ?? false) {
                    gateTiles.insert(PostEntity(location: CGPoint(x: (col * 32) + 16, y: (row * 32) + 16 )))
                }
                
                if(tileDefinition == nil && !brickHere) {
                    let x = CGFloat(col) * tileSize.width
                    let y = CGFloat(row) * tileSize.height
                    let empty = CGRect(x: x, y: y, width: tileSize.width, height: tileSize.height)
                    
                    let mapCol = floor(CGFloat(col) / 20) + 1
                    let mapRow = 5 - floor(CGFloat(row) / 11)
                    
                    let room = { () -> Int in
                        if(mapRow > 1) {
                            return Int((mapRow - 1) * 6 + mapCol)
                        } else {
                            return Int(mapCol)
                        }
                    }()
                    
                    if(emptyTiles[room] == nil) {
                        emptyTiles[room] = Array<CGRect>()
                    }
                    
                    emptyTiles[room]?.append(empty)
                }
            }
        }
        
        prizeEntity = PrizeEntity()
        
        self.gameScene = GameScene(size: CGSize(width: 640, height: 352))
    }
    
    //MARK: Game Center
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if ViewController != nil {
                //self.present(ViewController!, animated: true, completion: nil)
                self.presentAsSheet(ViewController!)
            } else if(localPlayer.isAuthenticated) {
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: {(leaderboardIdentifier, error) in
                    if error != nil {
                        print(String(describing: error))
                    } else {
                        
                    }
                })
                
                GameGlobals.instance.gamecenter = true
                
                if self.currentScene is TitleScene {
                    if let scene = self.currentScene as? TitleScene {
                        scene.enableLeaderboards()
                    }
                }
            } else {
                print("Local player could not be authenticated!")
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
       // gameCenterViewController.dismiss(animated: true, completion: nil)
        gameCenterViewController.dismiss(gameCenterViewController)
    }
    
    func submitScore() {
        let score = GKScore(leaderboardIdentifier: "co.uk.berks.\(GameGlobals.instance.currentDifficulty.identifier())")
        score.value = Int64(GameGlobals.instance.score)
        
        if score.value > GameGlobals.instance.highScore {
            GameGlobals.instance.highScore = Int(score.value)
            UserDefaults.standard.set(Int(score.value), forKey: "berksHighScore")
        }
        
        GKScore.report([score]) {(error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best score submitted")
            }
        }
    }
    
    func showLeaderboard() {
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        gc.viewState = .leaderboards
        //present(gc, animated: true, completion: nil)
        //present(gc, animator: NSViewControllerPresentationAnimator)
        presentAsSheet(gc)
    }
    
    func setupGameScene() -> GameScene {
        // let scene = GameScene(size: CGSize(width: 640, height: 352))
        
        for brick in brickTiles {
            brick.reset()
        }
        
        for key in keyTiles {
            key.reset()
        }
        
        for life in lifeTiles {
            life.reset()
        }
        
        for edge in edgeTiles {
            edge.reset()
        }
        
        for gate in gateTiles {
            gate.reset()
        }
        
        for (_, entities) in doorTiles {
            for entity in entities {
                entity.reset()
            }
        }
        
        wallMap.removeFromParent()
        gameScene.addChild(wallMap)
        
        prizeEntity.reset()
        
        return self.gameScene
    }
    
    func didEnterTitleScene() {
        let scene = TitleScene(size: CGSize(width: 640, height: 352))
        scene.name = "TitleScene"
        let skView = self.view as! SKView
        scene.scaleMode = .aspectFit
        scene.gamemanager = self
        skView.presentScene(scene)
        currentScene = scene
    }
    
    func didEnterPlayScene() {
        let scene = setupGameScene()
        let skView = self.view as! SKView
        scene.name = "GameScene"
        scene.gamemanager = self
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
        currentScene = scene
    }
    
    func didEnterGameOverScene() {
        let scene = GameOverScene(size: CGSize(width: 640, height: 352))
        scene.name = "GameOverScene"
        let skView = self.view as! SKView
        scene.scaleMode = .aspectFit
        scene.gamemanager = self
        skView.presentScene(scene)
        currentScene = scene
    }
    
    // MARK: Gamepad Discovery
    func startWatchingForControllers() {
        let controller = NotificationCenter.default
        
        controller.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { note in
            if let controller = note.object as? GCController {
                self.addController(controller)
            }
        }
        
        controller.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { note in
            if let controller = note.object as? GCController {
                self.removeController(controller)
            }
        }
        
        GCController.startWirelessControllerDiscovery(completionHandler: {})
    }
    
    func addController(_ controller: GCController) {
        if let _ = controller.extendedGamepad {
            print("Adding extended controller")
            gamePad = controller.extendedGamepad
            controller.playerIndex = .index1
        } else if let _ = controller.gamepad {
            print("Adding controller")
            gamePad = controller.gamepad
            controller.playerIndex = .index1
        } else if let _ = controller.microGamepad {
            gamePad = controller.microGamepad
            controller.playerIndex = .index1
        } else {
            print("Huh?!")
        }
        
        if currentScene is GameScene {
            (currentScene as? GameSceneManager)?.controllerSetup()
            (currentScene as? GameSceneManager)?.sceneState.enter(ScenePausedState.self)
        }
        
        if currentScene is TitleScene {
            (currentScene as? TitleScene)?.controllerSetup()
        }
    }
    
    func removeController(_ controller: GCController) {
        if let _ = controller.extendedGamepad {
            print("Removing extended controller")
        }
        
        if currentScene is TitleScene {
            (currentScene as? TitleScene)?.controllerRemoved()
        }
        
        if currentScene is GameScene {
            if let sceneState = (currentScene as? GameSceneManager)?.sceneState {
                if !(sceneState.currentState is ScenePausedState) {
                    sceneState.enter(ScenePausedState.self)
                }
            }
        }
    }
}

