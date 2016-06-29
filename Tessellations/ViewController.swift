//
//  ViewController.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: SKView!
    var scene: GameBoardScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.scene = GameBoardScene(size: CGSize(width: self.view.frame.width, height: self.view.frame.width))
        self.scene.scaleMode = .AspectFit
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.showsDrawCount = true
        self.sceneView.showsNodeCount = true
        self.sceneView.presentScene(self.scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func toolbarOneDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.generateKruskal()
    }
    
    @IBAction func toolbarTwoDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.generateHuntAndKill()
    }
    
    @IBAction func toolbarThreeDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.randomizeBoard()
    }

}

