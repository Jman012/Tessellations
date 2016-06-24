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
        
        self.scene = GameBoardScene(size: CGSize(width: 1000, height: 1000))
        self.scene.scaleMode = .AspectFit
        
        self.sceneView.presentScene(self.scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func toolbarOneDidTouch(sender: UIBarButtonItem) {
        
    }

}

