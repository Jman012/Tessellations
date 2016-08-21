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
    var octSquareScene: OctagonSquareScene!
    var hexagonScene: HexagonScene!
    var squareScene: SquareScene!
    var triangleScene: TriangleScene!
    var squareTriangleCrazyScene: SquareTriangleCrazyScene!
    var hexagonTriangleScene: HexagonTriangleScene!
    var dodecagonHexagonSquareScene: DodecagonHexagonSquareScene!
    var hexagonSquareTriangleScene: HexagonSquareTriangleScene!
    
    var allScenes: [AbstractGameBoardScene] = []
    
    let camera = SKCameraNode()
    let panRecognizer = UIPanGestureRecognizer()
    let tapRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        panRecognizer.addTarget(self, action: #selector(ViewController.handlePan(_:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panRecognizer)
        
        tapRecognizer.addTarget(self, action: #selector(ViewController.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
        
        self.octSquareScene = OctagonSquareScene(size: self.view.bounds.size)
        self.hexagonScene = HexagonScene(size: self.view.bounds.size)
        self.squareScene = SquareScene(size: self.view.bounds.size)
        self.triangleScene = TriangleScene(size: self.view.bounds.size)
        self.squareTriangleCrazyScene = SquareTriangleCrazyScene(size: self.view.bounds.size)
        self.hexagonTriangleScene = HexagonTriangleScene(size: self.view.bounds.size)
        self.dodecagonHexagonSquareScene = DodecagonHexagonSquareScene(size: self.view.bounds.size)
        self.hexagonSquareTriangleScene = HexagonSquareTriangleScene(size: self.view.bounds.size)
        self.allScenes = [octSquareScene, hexagonScene, squareScene, triangleScene, squareTriangleCrazyScene, hexagonTriangleScene, dodecagonHexagonSquareScene, hexagonSquareTriangleScene]
        
        for aScene in self.allScenes {
            aScene.camera = self.camera
        }
        self.camera.setScale(1.0)
        
        self.scene = self.hexagonSquareTriangleScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for aScene in self.allScenes {
            aScene.size = self.sceneView.frame.size
            aScene.sceneSizeDidChange()
        }
        
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    @IBAction func toolbarKrusDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.generateKruskal()
    }
    
    @IBAction func toolbarHakDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.generateHuntAndKill()
    }
    
    @IBAction func toolbarRandDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.randomizeBoard()
    }
    
    @IBAction func toolbarPrimDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.generatePrim()
    }
    
    @IBAction func toolbarOSDidTouch(sender: UIBarButtonItem) {
        self.scene = self.octSquareScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarHDidTouch(sender: UIBarButtonItem) {
        self.scene = self.hexagonScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarSDidTouch(sender: UIBarButtonItem) {
        self.scene = self.squareScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarTDidTouch(sender: UIBarButtonItem) {
        self.scene = self.triangleScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarSTCDidTouch(sender: UIBarButtonItem) {
        self.scene = self.squareTriangleCrazyScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarHTDidTouch(sender: UIBarButtonItem) {
        self.scene = self.hexagonTriangleScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarDHSDidTouch(sender: UIBarButtonItem) {
        self.scene = self.dodecagonHexagonSquareScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    @IBAction func toolbarHSTDidTouch(sender: UIBarButtonItem) {
        self.scene = self.hexagonSquareTriangleScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    func gameWon() {
        let alert = UIAlertController(title: "Won!", message: "Congrats", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "K.", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

