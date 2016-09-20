//
//  MenuBaseCell.swift
//  Tessellations
//
//  Created by James Linnell on 9/12/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuBaseCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        
    }
    
    override func didMoveToSuperview() {
        self.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        if UIScreen.mainScreen().scale == 1.0 {
            self.layer.borderWidth = 0.5
        } else {
            self.layer.borderWidth = 0.25
        }
    }
    
    func setColors() {
        self.contentView.backgroundColor = Singleton.shared.palette.background
    }
    
}
