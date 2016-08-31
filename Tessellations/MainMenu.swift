//
//  MainMenu.swift
//  Tessellations
//
//  Created by James Linnell on 8/21/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import QuartzCore

class MainMenu: UICollectionViewController, UICollectionViewDelegateFlowLayout, SingletonProtocol {
    
    /* Menu:
     * Section 0:
     *   Size | Color dropdowns
     * Section 1:
     *   Shuffle button
     * Section 2:
     *   Board buttons
     */

    var menuData: [[String]] = []
    
    var selection: SizeColorSelection = .None
    var boardSize: BoardSize = .Small
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = " "
        
        menuData.append([])
//        menuData.append(["Shuffle"])
        menuData.append(sceneClassStrings)
        
        self.collectionView?.backgroundColor = Singleton.shared.palette.background
        Singleton.shared.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for cell in self.collectionView!.visibleCells() {
            if let boardCell = cell as? MenuBoardCell {
                boardCell.redoImage()
            }
        }
    }
    
    func singleton(singleton: Singleton, didMoveToPalette palette: ScenePalette) {
        self.collectionView?.backgroundColor = Singleton.shared.palette.background
        self.collectionView?.reloadData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return menuData.count + 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return menuData[section].count
        default:
            return 0
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            return self.constructSizeColorCellForIndexPath(indexPath)
            
        case 1:
            return self.constructBoardCellForIndexPath(indexPath)
        
        default:
            fatalError("Bad index path")
        }
    }
    
    func constructBoardCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuBoardCell", forIndexPath: indexPath) as! MenuBoardCell
        
        cell.setColors()
        cell.highlightView.hidden = true
        cell.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        cell.layer.borderWidth = 0.25
        
        cell.typeString = menuData[indexPath.section][indexPath.row]
        cell.label.textColor = UIColor.blackColor()
        cell.label.text = menuData[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func constructSizeColorCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuSizeColorCell", forIndexPath: indexPath) as! MenuSizeColorCell
        
        cell.setColors()
        cell.sizeSlider.tintColor = Singleton.shared.palette.piece
        cell.collectionVC = self
        
        cell.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        cell.layer.borderWidth = 0.25
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            // SizeColorCell will do its own touch recognizing and use
            // its weak reference to self to do work
            break
            
        case 1:
            self.performSegueWithIdentifier("MenuBoardCellSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))
            
        default:
            break
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuBoardCellSegue" {
            let viewController = segue.destinationViewController as! ViewController
            let cell = sender as! MenuBoardCell
            viewController.setBoardType(cell.label!.text!, forBoardSize: boardSize)
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            if selection == .None {
                return CGSize(width: collectionView.frame.width, height: 44.0)
            } else {
                return CGSize(width: collectionView.frame.width, height: 88.0)
            }
            
        case 1:
            return CGSize(width: self.collectionView!.frame.size.width / 2.0,
                          height: self.collectionView!.frame.size.width / 2.0)
            
        default:
            return CGSizeZero
        }
    }

}
