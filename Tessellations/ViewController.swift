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
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.sceneView.paused = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBoardType(boardType: String) {
        switch boardType {
        case sceneClassStrings[SceneIndex.Triangle.rawValue]:
            self.scene = TriangleScene(size: self.view.frame.size, boardWidth: 7, boardHeight: 8, margins: true)
        case sceneClassStrings[SceneIndex.Square.rawValue]:
            self.scene = SquareScene(size: self.view.frame.size, boardWidth: 7, boardHeight: 10, margins: true)
        case sceneClassStrings[SceneIndex.Hexagon.rawValue]:
            self.scene = HexagonScene(size: self.view.frame.size, boardWidth: 7, boardHeight: 8, margins: true)
        case sceneClassStrings[SceneIndex.OctagonSquare.rawValue]:
            self.scene = OctagonSquareScene(size: self.view.frame.size, boardWidth: 9, boardHeight: 13, margins: true)
        case sceneClassStrings[SceneIndex.SquareTriangle.rawValue]:
            self.scene = SquareTriangleCrazyScene(size: self.view.frame.size, boardWidth: 12, boardHeight: 12, margins: true)
        case sceneClassStrings[SceneIndex.HexagonTriangle.rawValue]:
            self.scene = HexagonTriangleScene(size: self.view.frame.size, boardWidth: 7, boardHeight: 10, margins: true)
        case sceneClassStrings[SceneIndex.HexagonSquareTriangle.rawValue]:
            self.scene = HexagonSquareTriangleScene(size: self.view.frame.size, boardWidth: 15, boardHeight: 13, margins: true)
        case sceneClassStrings[SceneIndex.DodecagonHexagonSquare.rawValue]:
            self.scene = DodecagonHexagonSquareScene(size: self.view.frame.size, boardWidth: 13, boardHeight: 13, margins: true)

        default:
            self.scene = SquareScene(size: self.view.frame.size, boardWidth: 7, boardHeight: 10, margins: true)
        }
        
        self.camera.setScale(1.0)
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
        self.scene.camera = self.camera
        
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 1
        self.sceneView.showsFPS = true
        self.sceneView.showsNodeCount = true
        self.sceneView.showsDrawCount = true
        self.sceneView.ignoresSiblingOrder = true
        self.sceneView.presentScene(self.scene)
        
        self.scene.size = self.sceneView.frame.size
        self.scene.sceneSizeDidChange()
        
        self.scene.logicalBoard.generatePrim()
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
            
        } else if recognizer.state == .Changed {
            
            var translation = recognizer.translationInView(recognizer.view)
            translation = CGPointMake(-translation.x, translation.y)
            
            var newPosition = CGPoint(x: self.camera.position.x + translation.x, y: self.camera.position.y + translation.y)
            
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

    
    @IBAction func zoom(sender: UIBarButtonItem) {
        if self.camera.xScale == 1.0 {
            self.camera.setScale(0.7)
        } else {
            self.camera.setScale(1.0)
        }
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
    }
    
    func gameWon() {
        let alert = UIAlertController(title: "Won!", message: "Congrats", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "K.", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

