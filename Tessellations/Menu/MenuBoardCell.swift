//
//  MenuBoardCell.swift
//  Tessellations
//
//  Created by James Linnell on 8/21/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class MenuBoardCell: MenuBaseCell {

    var typeString: String! {
        didSet {
            self.pieceImageView.image = pieceThumbnailImages[typeString]
            self.pipeImageView.image = pipeThumbnailImages[typeString]
            self.rootImageView.image = rootThumbnailImages[typeString]
            
            self.label.hidden = true
            self.updateProgress()
        }
    }
    @IBOutlet var label: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressMaxLabel: UILabel!
    
    @IBOutlet var pieceImageView: UIImageView!
    @IBOutlet var pipeImageView: UIImageView!
    @IBOutlet var rootImageView: UIImageView!
    
    @IBOutlet var highlightView: UIView!
    @IBOutlet var progressView: SquarePieProgressView!
    @IBOutlet var sizeLabel: UILabel!
    var progress: UInt {
        get { return Singleton.shared.progress(forBoardType: typeString, size: collectionVC.boardSize) }
    }
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.setColors), name: kPaletteDidChange, object: nil)
    }
    
    override func setColors() {
        super.setColors()
        self.progressView.progressColor = Singleton.shared.palette.buttonBackground
        
        self.pieceImageView.tintColor = Singleton.shared.palette.piece
        self.pipeImageView.tintColor = Singleton.shared.palette.pipeEnabled
        self.rootImageView.tintColor = Singleton.shared.palette.rootMarker
    }
    
    func updateProgress() {
        progressLabel.text = "\(self.progress)"
        progressMaxLabel.text = "\(Int(floor(CGFloat(self.progress) / 100) + 1) * 100)"
        progressView.percent = (CGFloat(self.progress % 100)) / 100.0
    }
}
