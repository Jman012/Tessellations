//
//  MainMenu.swift
//  Tessellations
//
//  Created by James Linnell on 8/21/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import QuartzCore

class MainMenu: UICollectionViewController {

    let menuData: [[String]] = [["Triangle", "Square", "Hexagon", "Octagon", "Square & Triangle", "Hexagon & Triangle",
                                 "Hexagon & Square & Triangle", "Dodeca-Hexa-Square"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = " "
        
//        self.collectionView?.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize =
            CGSize(width: self.collectionView!.frame.size.width / 2.0,
                   height: self.collectionView!.frame.size.width / 2.0)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return menuData.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuData[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MenuBoardCell", forIndexPath: indexPath) as! MenuBoardCell
        
        cell.backgroundColor = UIColor.whiteColor()
        cell.highlightView.hidden = true
//        if indexPath.row % 4 == 0 {
            cell.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
            cell.layer.borderWidth = 0.25
//        } else {
//            cell.layer.borderColor = UIColor.clearColor().CGColor
//            cell.layer.borderWidth = 0.0
//        }
        
        cell.label.textColor = UIColor.blackColor()
        cell.label.text = menuData[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("MenuBoardCellSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuBoardCellSegue" {
            let viewController = segue.destinationViewController as! ViewController
            let cell = sender as! MenuBoardCell
            viewController.setBoardType(cell.label!.text!)
        }
    }

}
