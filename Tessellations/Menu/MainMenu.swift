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
     * Section 1:
     *   Shuffle button
     * Section 2:
     *   Board buttons
     */
    
    @IBOutlet var backgroundImageView: UIImageView!
    let bgImage = UIImage(named: "BackgroundTile")!.imageWithRenderingMode(.AlwaysTemplate)

    var menuData: [[String]] = []
    
    var boardSize: BoardSize = .Small
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = " "
        
        menuData.append(["Title"])
        menuData.append(["Color", "Size"])
        menuData.append(["Shuffle"])
        menuData.append(sceneClassStrings)
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        Singleton.shared.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.backgroundImageView.image = self.bgImage
        self.backgroundImageView.tintColor = Singleton.shared.palette.piece
        
        for cell in self.collectionView!.visibleCells() {
            if let boardCell = cell as? MenuBoardCell {
                boardCell.updateProgress()
            }
        }
    }
    
    func singleton(singleton: Singleton, didMoveToPalette palette: ScenePalette) {
        self.collectionView?.backgroundColor = singleton.palette.background
        self.view.backgroundColor = singleton.palette.background
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
            return self.constructTitleCellForIndexPath(indexPath)
            
        case 1:
            return self.constructLeftRightCellForIndexPath(indexPath)
            
        case 2:
            return self.constructButtonCellForIndexPath(indexPath)
            
        case 3:
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
        
        let classString = menuData[indexPath.section][indexPath.row]
        
        cell.typeString = classString
        cell.label.textColor = UIColor.blackColor()
        cell.label.text = classString
        
        let theClass = NSClassFromString(classString)! as! AbstractGameBoardScene.Type
        let size = theClass.size(self.boardSize)
        cell.sizeLabel.text = "\(size.0) x \(size.1)"
        
        return cell
    }
    
    func constructLeftRightCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuLeftRightOptionCell", forIndexPath: indexPath) as! MenuLeftRightOptionCell
        
        cell.setColors()
        
        if indexPath.row == 0 {
            cell.maxValue = Singleton.shared.allPalettes.count - 1
            cell.value = Singleton.shared.currentPalette
            cell.optionLabel.text = "Color:"
            cell.valueLabel.text = "\(Singleton.shared.palette.name)"
            
            cell.valueDidChange = {
                sender in
                
                Singleton.shared.setAppPalette(sender.value)
                sender.valueLabel.text = "\(Singleton.shared.palette.name)"
                
                self.backgroundImageView.tintColor = Singleton.shared.palette.piece
            }
        } else if indexPath.row == 1 {
            cell.maxValue = BoardSize.count() - 1
            cell.value = boardSize.rawValue
            cell.optionLabel.text = "Difficulty:"
            cell.valueLabel.text = "\(boardSize.text())"
            
            cell.valueDidChange = {
                sender in
                
                self.boardSize = BoardSize(rawValue: sender.value)!
                sender.valueLabel.text = "\(self.boardSize.text())"
                
                for cell in self.collectionView!.visibleCells() {
                    if let boardCell = cell as? MenuBoardCell {
                        boardCell.redoImage(nil)
                        boardCell.updateProgress()
                        
                        let theClass = NSClassFromString(boardCell.typeString)! as! AbstractGameBoardScene.Type
                        let size = theClass.size(self.boardSize)
                        boardCell.sizeLabel.text = "\(size.0) x \(size.1)"
                    }
                }
            }
        }
        
        return cell
    }
    
    func constructButtonCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuButtonCell", forIndexPath: indexPath) as! MenuButtonCell
        
        cell.setColors()
        cell.label.text = "Shuffle"
        
        return cell
    }
    
    func constructTitleCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("MenuTitleCell", forIndexPath: indexPath) as! MenuTitleCell
        
        cell.setColors()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        
        case 2:
            // Shuffle
            self.performSegueWithIdentifier("MenuBoardCellSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))
            break
            
        case 3:
            self.performSegueWithIdentifier("MenuBoardCellSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))
            
        default:
            break
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuBoardCellSegue" {
            let viewController = segue.destinationViewController as! ViewController
            if let cell = sender as? MenuBoardCell {
                viewController.setBoardType(cell.label!.text!, forBoardSize: boardSize)
            } else if (sender as? MenuButtonCell) != nil {
                viewController.shuffle(forBoardTypes: sceneClassStrings, boardSize: boardSize)
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        
        case 0:
            return CGSize(width: self.collectionView!.frame.size.width, height: 88.0)
            
        case 1, 2:
            return CGSize(width: self.collectionView!.frame.size.width, height: 44.0)
            
        case 3:
            return CGSize(width: self.collectionView!.frame.size.width / 2.0,
                          height: self.collectionView!.frame.size.width / 2.0)
            
        default:
            return CGSizeZero
        }
    }

}
