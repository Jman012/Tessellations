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
            let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
            if let image = appDelegate.thumbnailImages[typeString] {
                self.imageView.image = image
                self.label.hidden = true
            }
        }
    }
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var highlightView: UIView!
    
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
}
