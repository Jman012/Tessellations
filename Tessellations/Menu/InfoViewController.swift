//
//  InfoViewController.swift
//  Tessellations
//
//  Created by James Linnell on 9/14/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.backButton.backgroundColor = Singleton.shared.palette.buttonBackground
        
        self.textView.contentInset = UIEdgeInsets(top: 50, left: 8, bottom: 8, right: 8)
        self.textView.backgroundColor = Singleton.shared.palette.background
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
