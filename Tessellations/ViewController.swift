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
    var scene: GameBoardScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.scene = GameBoardScene(size: self.view.bounds.size)
        self.scene.scaleMode = .AspectFit
        self.scene.del = self
        
        self.sceneView.frameInterval = 4
        self.sceneView.showsFPS = true
        self.sceneView.presentScene(self.scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scene.size = self.view.bounds.size
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
    
    @IBAction func toolbarFourDidTouch(sender: UIBarButtonItem) {
        self.scene.logicalBoard.generatePrim()
    }
    
    func gameWon() {
        let alert = UIAlertController(title: "Won!", message: "Congrats", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "K.", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

