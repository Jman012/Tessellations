//
//  MenuLeftRightOptionCell.swift
//  Tessellations
//
//  Created by James Linnell on 8/31/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuLeftRightOptionCell: MenuBaseCell {
    
    @IBOutlet var optionLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    var value: Int = 0
    var maxValue: Int = 0
    var valueDidChange: ((sender: MenuLeftRightOptionCell) -> Void)?
    
    override func setColors() {
        super.setColors()
        
        self.leftButton.backgroundColor = Singleton.shared.palette.buttonBackground
        self.rightButton.backgroundColor = Singleton.shared.palette.buttonBackground
    }
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.setColors), name: kPaletteDidChange, object: nil)
    }
    
    @IBAction func buttonTouched(sender: UIButton) {
        if sender == leftButton {
            value -= 1
            if value < 0 {
                value = maxValue
            }
            if let callback = valueDidChange {
                callback(sender: self)
            }
        } else if sender == rightButton {
            value += 1
            if value > maxValue {
                value = 0
            }
            if let callback = valueDidChange {
                callback(sender: self)
            }
        }
    }
}
