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
        
        self.scene.logicalBoard.generatePrim()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBoardType(boardType: String) {
        switch boardType {
        case "Triangle":
            self.scene = TriangleScene(size: self.view.bounds.size)
        case "Square":
            self.scene = SquareScene(size: self.view.bounds.size)
        case "Hexagon":
            self.scene = HexagonScene(size: self.view.bounds.size)
        case "Octagon":
            self.scene = OctagonSquareScene(size: self.view.bounds.size)
        case "Square & Triangle":
            self.scene = SquareTriangleCrazyScene(size: self.view.bounds.size)
        case "Hexagon & Triangle":
            self.scene = HexagonTriangleScene(size: self.view.bounds.size)
        case "Hexagon & Square & Triangle":
            self.scene = HexagonSquareTriangleScene(size: self.view.bounds.size)
        case "Dodeca-Hexa-Square":
            self.scene = DodecagonHexagonSquareScene(size: self.view.bounds.size)

        default:
            self.scene = SquareScene(size: self.view.bounds.size)
        }
        
        self.scene.size = self.sceneView.frame.size
        self.scene.sceneSizeDidChange()
        
        self.camera.setScale(1.0)
        self.camera.position = CGPoint(x: self.scene.size.width / 2.0, y: self.scene.size.height / 2.0)
        self.scene.camera = self.camera
        
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 3
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
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

