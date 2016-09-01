//
//  MenuBoardCell.swift
//  Tessellations
//
//  Created by James Linnell on 8/21/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuBoardCell: UICollectionViewCell {

    var typeString: String! {
        didSet {
            if let image = thumbnailImages[typeString] {
                self.imageView.image = image
                self.label.hidden = true
            }
        }
    }
    @IBOutlet var label: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var highlightView: UIView!
    
    weak var collectionVC: MainMenu!
    
    override var highlighted: Bool {
        didSet {
            highlightView.hidden = !highlightView.hidden
        }
    }
    
    override var selected: Bool {
        didSet {
            highlightView.hidden = !highlightView.hidden
        }
    }
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.redoImage), name: kThumbnailImageDidChange, object: nil)
    }
    
    func setColors() {
        self.contentView.backgroundColor = Singleton.shared.palette.background
    }
    
    func redoImage(sender: NSNotification?) {
        if let not = sender {
            let classString = not.userInfo![kClassString]! as! String
            if classString == self.typeString {
                if let image = thumbnailImages[typeString] {
                    self.imageView.image = image
                    self.label.hidden = true
                }
            }
        } else {
            if let image = thumbnailImages[typeString] {
                self.imageView.image = image
                self.label.hidden = true
            }
        }
    }
    
    func updateProgressText() {
        progressLabel.text = "\(Singleton.shared.progress[typeString]![collectionVC.boardSize]) / 100"
    }
}
