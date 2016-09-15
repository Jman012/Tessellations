//
//  ViewController.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, GameBoardSceneProtocol {

    @IBOutlet weak var sceneView: SKView!
    var scene: AbstractGameBoardScene!
    
    let camera = SKCameraNode()
    let panRecognizer = UIPanGestureRecognizer()
    let tapRecognizer = UITapGestureRecognizer()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var zoomButton: UIButton!
    @IBOutlet var titleButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var winnerLabel: UILabel!
    
    var shuffle = false
    var boardType: String = ""
    var allBoardTypes: [String] = []
    var boardSize: BoardSize!
    var boardNumber: UInt = 0
    var won = false
    var destructing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        panRecognizer.addTarget(self, action: #selector(ViewController.handlePan(_:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.sceneView.addGestureRecognizer(panRecognizer)
        
        tapRecognizer.addTarget(self, action: #selector(ViewController.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        self.sceneView.addGestureRecognizer(tapRecognizer)
        
        backButton.backgroundColor = Singleton.shared.palette.buttonBackground
        zoomButton.backgroundColor = Singleton.shared.palette.buttonBackground
        titleButton.backgroundColor = Singleton.shared.palette.buttonBackground
        nextButton.backgroundColor = Singleton.shared.palette.buttonBackground
        
        nextButton.hidden = true
        winnerLabel.hidden = true
        
        self.view.backgroundColor = Singleton.shared.palette.background
        
        self.titleButton.setTitle("\(self.boardSize.text()) - #\(self.boardNumber)", forState: .Normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scene = self.scene {
            scene.size = self.sceneView.frame.size
            scene.sceneSizeDidChange()
            
            self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.sceneView.paused = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shuffle(forBoardTypes boardTypes: [String], boardSize: BoardSize) {
        self.shuffle = true
        self.allBoardTypes = boardTypes
        self.boardSize = boardSize
        
        self.doShuffle()
    }
    
    func doShuffle() {
        var type = self.allBoardTypes.randomItemTrueRandom()
        while type == self.boardType {
            type = self.allBoardTypes.randomItemTrueRandom()
        }
        
        self.setBoardType(type, forBoardSize: self.boardSize)
    }
    
    func setBoardType(boardType: String, forBoardSize boardSize: BoardSize) {
        self.boardType = boardType
        self.boardSize = boardSize
        self.boardNumber = Singleton.shared.nextBoardNumberToComplete(forBoardType: boardType, size: boardSize)

        let seed = TessellationsSeed(forClassString: boardType, boardSize: boardSize, number: Int(self.boardNumber))
        TessellationsPuzzleGenSeed(seed)
        
        if let titleBut = self.titleButton {
            titleBut.setTitle("\(self.boardSize.text()) - #\(self.boardNumber)", forState: .Normal)
        }
        
        switch boardType {
        case sceneClassStrings[SceneIndex.Triangle.rawValue]:
            self.scene = TriangleScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.Square.rawValue]:
            self.scene = SquareScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.Hexagon.rawValue]:
            self.scene = HexagonScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.OctagonSquare.rawValue]:
            self.scene = OctagonSquareScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.SquareTriangle.rawValue]:
            self.scene = SquareTriangleScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.HexagonTriangle.rawValue]:
            self.scene = HexagonTriangleScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.HexagonSquareTriangle.rawValue]:
            self.scene = HexagonSquareTriangleScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        case sceneClassStrings[SceneIndex.DodecagonHexagonSquare.rawValue]:
            self.scene = DodecagonHexagonSquareScene(size: self.view.frame.size, boardSize: boardSize, margins: true)

        default:
            self.scene = SquareScene(size: self.view.frame.size, boardSize: boardSize, margins: true)
        }
        
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
//        self.sceneView.showsFPS = true
//        self.sceneView.showsNodeCount = true
//        self.sceneView.showsDrawCount = true
        self.sceneView.ignoresSiblingOrder = true
        self.sceneView.presentScene(self.scene)
        
        self.scene.size = self.sceneView.frame.size
        self.scene.sceneSizeDidChange()
        
        self.camera.setScale(kCameraZoomOut)
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
        self.scene.camera = self.camera
        
        self.scene.logicalBoard.generatePrim()
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
            
        } else if recognizer.state == .Changed {
            
            var translation = recognizer.translationInView(recognizer.view)
            translation = CGPointMake(-translation.x, translation.y)
            
            var newPosition = CGPoint(x: self.camera.position.x + translation.x * camera.xScale, y: self.camera.position.y + translation.y * camera.yScale)
            
            let cameraBounds = CGRect(x: self.scene.size.width / 2.0,
                                      y: self.scene.size.height / 2.0,
                                      width: self.scene.frame.size.width - self.scene.frame.size.width/self.camera.xScale,
                                      height: self.scene.frame.size.height - self.scene.frame.size.height/self.camera.yScale)
            
            if newPosition.x < cameraBounds.origin.x - cameraBounds.width/2 {
                newPosition.x = cameraBounds.origin.x - cameraBounds.width/2
            } else if newPosition.x > cameraBounds.origin.x + cameraBounds.width/2 {
                newPosition.x = cameraBounds.origin.x + cameraBounds.width/2
            }
            
            if newPosition.y < cameraBounds.origin.y - cameraBounds.height/2 {
                newPosition.y = cameraBounds.origin.y - cameraBounds.height/2
            } else if newPosition.y > cameraBounds.origin.y + cameraBounds.height/2 {
                newPosition.y = cameraBounds.origin.y + cameraBounds.height/2
            }
            
            self.camera.position = newPosition
            
            
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
            
        } else if (recognizer.state == .Ended) {
            
            // No code needed for panning.
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            let location = recognizer.locationInView(recognizer.view)
            self.scene.gotTapAtLocation(location)
            
        }
    }

    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func zoom(sender: UIButton) {
        guard self.won == false else {
            return
        }
        
        if self.camera.xScale == kCameraZoomOut {
            self.camera.setScale(kCameraZoomIn)
        } else {
            self.camera.setScale(kCameraZoomOut)
        }
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
    }
    
    @IBAction func next(sender: UIButton) {
        if self.destructing == false {
            self.destructing = true
            self.scene.logicalBoard.destructBoard()
        }
    }
    
    func gameWon() {
        self.camera.setScale(kCameraZoomOut)
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
        
        self.won = true
        self.nextButton.hidden = false
        self.winnerLabel.hidden = false
        self.titleButton.hidden = true
        
        Singleton.shared.progressDidComplete(number: self.boardNumber, forBoardType: boardType, size: boardSize)
        Singleton.shared.syncProgress()
    }
    
    func boardDidFinishDestructing() {
        self.destructing = false
        self.won = false
        self.nextButton.hidden = true
        self.winnerLabel.hidden = true
        self.titleButton.hidden = false
        
        if shuffle == false {
            self.setBoardType(self.boardType, forBoardSize: self.boardSize)
        } else {
            self.doShuffle()
        }
    }

}

