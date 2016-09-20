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
            self.applyImage(nil)
            
            self.updateProgress()
        }
    }
    @IBOutlet var indicator: UIActivityIndicatorView!
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
        self.indicator.startAnimating()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.setColors), name: kPaletteDidChange, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuBoardCell.applyImage(_:)), name: kThumbnailImageDidChange, object: nil)
    }
    
    func applyImage(sender: NSNotification?) {
        if let userInfo = sender?.userInfo, let theClass = userInfo[kClassString] as? String where theClass != self.typeString {
            return
        }
        
        self.pieceImageView.image = Singleton.shared.pieceThumbnailImages[typeString]
        self.pipeImageView.image = Singleton.shared.pipeThumbnailImages[typeString]
        self.rootImageView.image = Singleton.shared.rootThumbnailImages[typeString]
        
        if pieceImageView.image != nil && pipeImageView.image != nil && rootImageView.image != nil {
            self.pieceImageView.hidden = false
            self.pipeImageView.hidden = false
            self.rootImageView.hidden = false
            
            self.indicator.stopAnimating()
            self.indicator.hidden = true
        } else {
            self.pieceImageView.hidden = true
            self.pipeImageView.hidden = true
            self.rootImageView.hidden = true
            
            self.indicator.startAnimating()
            self.indicator.hidden = false
        }
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
