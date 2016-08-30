//
//  MenuButtonCell.swift
//  Tessellations
//
//  Created by James Linnell on 8/29/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuButtonCell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = Singleton.shared.palette.background
    }
}
