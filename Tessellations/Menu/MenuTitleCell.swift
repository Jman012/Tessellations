//
//  MenuTitleCell.swift
//  Tessellations
//
//  Created by James Linnell on 9/10/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuTitleCell: MenuBaseCell {
    
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.setColors), name: kPaletteDidChange, object: nil)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
    }
    
    override func setColors() {
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.label.textColor = Singleton.shared.palette.pipeEnabled
    }
    
}
