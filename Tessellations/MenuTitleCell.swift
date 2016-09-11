//
//  MenuTitleCell.swift
//  Tessellations
//
//  Created by James Linnell on 9/10/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuTitleCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.setColors), name: kPaletteDidChange, object: nil)
    }
    
    func setColors() {
        self.contentView.backgroundColor = Singleton.shared.palette.background
    }
}
