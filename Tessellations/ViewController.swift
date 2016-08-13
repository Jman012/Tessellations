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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.octSquareScene = OctagonSquareScene(size: self.view.bounds.size)
        self.hexagonScene = HexagonScene(size: self.view.bounds.size)
        self.squareScene = SquareScene(size: self.view.bounds.size)
        self.triangleScene = TriangleScene(size: self.view.bounds.size)
        self.squareTriangleCrazyScene = SquareTriangleCrazyScene(size: self.view.bounds.size)
        self.hexagonTriangleScene = HexagonTriangleScene(size: self.view.bounds.size)
        
        self.scene = self.hexagonTriangleScene
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.octSquareScene.size = self.sceneView.frame.size
        self.hexagonScene.size = self.sceneView.frame.size
        self.squareScene.size = self.sceneView.frame.size
        self.triangleScene.size = self.sceneView.frame.size
        self.squareTriangleCrazyScene.size = self.sceneView.frame.size
        self.hexagonTriangleScene.size = self.sceneView.frame.size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func gameWon() {
        let alert = UIAlertController(title: "Won!", message: "Congrats", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "K.", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

