//
//  MenuSizeColorCell.swift
//  Tessellations
//
//  Created by James Linnell on 8/29/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

enum SizeColorSelection {
    case None
    case Size
    case Color
}

class MenuSizeColorCell: UICollectionViewCell {
    
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var sizeArrow: UIImageView!
    @IBOutlet var sizeSliderView: UIView!
    @IBOutlet var sizeSlider: UISlider!
    
    @IBOutlet var colorLabel: UILabel!
    @IBOutlet var colorArrow: UIImageView!
    @IBOutlet var colorPickerView: UIView!
    @IBOutlet var colorPickerScroll: UIScrollView!
    
    var selection: SizeColorSelection = .None
    var boardSize: BoardSize = .Small {
        didSet {
            self.collectionVC?.boardSize = self.boardSize
            self.sizeLabel.text = self.boardSize.text()
        }
    }
    weak var collectionVC: MainMenu?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sizeSlider.value = 0
        boardSize = .Small
        
        colorPickerScroll.contentSize = CGSize(width: CGFloat(Singleton.shared.allPalettes.count) * 44.0, height: 44.0)
        var point = CGPointZero
        for (i, palette) in Singleton.shared.allPalettes.enumerate() {
            let image = Singleton.shared.imageForPalette(palette)
            let button = UIButton(type: .Custom)
            button.setBackgroundImage(image, forState: .Normal)
            button.frame.size = CGSize(width: 44.0, height: 44.0)
            button.frame.origin = point
            button.tag = i
            button.addTarget(self, action: #selector(MenuSizeColorCell.paletteButtonTouched(_:)), forControlEvents: .TouchUpInside)
            colorPickerScroll.addSubview(button)
            
            point.x += 44.0
        }
    }
    
    func setColors() {
        self.contentView.backgroundColor = Singleton.shared.palette.background
        sizeSlider.tintColor = Singleton.shared.palette.piece
    }
    
    func paletteButtonTouched(sender: UIButton) {
//        Singleton.shared.setAppPalette(Singleton.shared.allPalettes[sender.tag])
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        let touch = touches.first!
        let location = touch.locationInView(self)
        if location.y < 44.0 {
            /* Size or Color Buttons */
            let newSelection: SizeColorSelection
            if location.x < self.frame.width / 2.0 {
                /* Size */
                newSelection = .Size
            } else {
                /* Color */
                newSelection = .Color
            }
            
            if selection == .None {
                // Need to unhide before animation
                self.setSelection(newSelection)
            }
            
            self.toggleSelectionFor(newSelection)

            self.collectionVC?.collectionView?.performBatchUpdates({
                self.collectionVC?.selection = self.selection
            }, completion: {
                finished in
                self.setSelection(self.selection)
            })
        } else {
            /* Dropdown */
            if selection == .Color {
//                let 
            }
        }
    }
    
    func toggleSelectionFor(toggle: SizeColorSelection) {
        if selection == .None {
            selection = toggle
        } else {
            selection = .None
        }
    }
    
    @IBAction func valueChanged(sender: UISlider) {
        sizeSlider.value = round(sizeSlider.value)
        boardSize = BoardSize(rawValue: Int(sizeSlider.value))!
    }
    
    func setSelection(selection: SizeColorSelection) {
        switch selection {
        case .None:
            sizeSliderView.hidden = true
            colorPickerView.hidden = true
            
        case .Size:
            sizeSliderView.hidden = false
            colorPickerView.hidden = true
            
        case .Color:
            sizeSliderView.hidden = true
            colorPickerView.hidden = false
        }
    }
}
