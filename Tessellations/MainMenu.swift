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
    
    /* Menu: (old)
     * Section 0:
     *   Size | Color dropdowns
     * Section 1:
     *   Shuffle button
     * Section 2:
     *   Board buttons
     */
    
    /* Menu:
     * Section 0:
     *   Color leftright (row 0)
     *   Size leftright  (row 1)
     * Section 1: (not done yet)
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
        
        menuData.append(["Color", "Size"])
//        menuData.append(["Shuffle"])
        menuData.append(sceneClassStrings)
        
        self.collectionView?.backgroundColor = Singleton.shared.palette.background
        Singleton.shared.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for cell in self.collectionView!.visibleCells() {
            if let boardCell = cell as? MenuBoardCell {
                boardCell.updateProgress()
            }
        }
    }
    
    func singleton(singleton: Singleton, didMoveToPalette palette: ScenePalette) {
        self.collectionView?.backgroundColor = Singleton.shared.palette.background
        self.collectionView?.reloadData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return menuData.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuData[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            return self.constructLeftRightCellForIndexPath(indexPath)
            
        case 1:
            return self.constructBoardCellForIndexPath(indexPath)
        
        default:
            fatalError("Bad index path")
        }
    }
    
    func constructBoardCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuBoardCell", forIndexPath: indexPath) as! MenuBoardCell
        
        cell.setColors()
        cell.collectionVC = self
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
    
    func constructLeftRightCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuLeftRightOptionCell", forIndexPath: indexPath) as! MenuLeftRightOptionCell
        
        cell.setColors()
        
        cell.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        cell.layer.borderWidth = 0.25
        
        if indexPath.row == 0 {
            cell.maxValue = Singleton.shared.allPalettes.count - 1
            cell.value = Singleton.shared.currentPalette
            cell.label.text = "Color: \(Singleton.shared.palette.name)"
            
            cell.valueDidChange = {
                sender in
                
                Singleton.shared.setAppPalette(sender.value)
                sender.label.text = "Color: \(Singleton.shared.palette.name)"
            }
        } else if indexPath.row == 1 {
            cell.maxValue = BoardSize.count() - 1
            cell.value = boardSize.rawValue
            cell.label.text = "Difficulty: \(boardSize.text())"
            
            cell.valueDidChange = {
                sender in
                
                self.boardSize = BoardSize(rawValue: sender.value)!
                sender.label.text = "Difficulty: \(self.boardSize.text())"
                
                for cell in self.collectionView!.visibleCells() {
                    if let boardCell = cell as? MenuBoardCell {
                        boardCell.redoImage(nil)
                        boardCell.updateProgress()
                    }
                }
            }
        }
        
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
