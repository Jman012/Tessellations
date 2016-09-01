//
//  MenuLeftRightOptionCell.swift
//  Tessellations
//
//  Created by James Linnell on 8/31/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuLeftRightOptionCell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    var value: Int = 0
    var maxValue: Int = 0
    var valueDidChange: ((sender: MenuLeftRightOptionCell) -> Void)?
    
    func setColors() {
        self.contentView.backgroundColor = Singleton.shared.palette.background
    }
    
    @IBAction func buttonTouched(sender: UIButton) {
        if sender == leftButton {
            value -= 1
            if value < 0 {
                value = 0
            }
            if let callback = valueDidChange {
                callback(sender: self)
            }
        } else if sender == rightButton {
            value += 1
            if value > maxValue {
                value = maxValue
            }
            if let callback = valueDidChange {
                callback(sender: self)
            }
        }
    }
}
