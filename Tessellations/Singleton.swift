//
//  Singleton.swift
//  Tessellations
//
//  Created by James Linnell on 8/28/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

struct ScenePalette {
    let pipeEnabled:      UIColor
    let pipeDisabled:     UIColor
    let piece:            UIColor
    let background:       UIColor
    let buttonBackground: UIColor
    
    init(pipeEnabled: UIColor, pipeDisabled: UIColor, piece: UIColor, background: UIColor, buttonBackground: UIColor) {
        self.pipeEnabled =      pipeEnabled
        self.pipeDisabled =     pipeDisabled
        self.piece =            piece
        self.background =       background
        self.buttonBackground = buttonBackground
    }
    
    init(pipeEnabled: String, pipeDisabled: String, piece: String, background: String, buttonBackground: String) {
        self.pipeEnabled =      UIColor(hexString: pipeEnabled)
        self.pipeDisabled =     UIColor(hexString: pipeDisabled)
        self.piece =            UIColor(hexString: piece)
        self.background =       UIColor(hexString: background)
        self.buttonBackground = UIColor(hexString: buttonBackground)
    }
    
    init(hexStrings: [String]) {
        self.init(pipeEnabled: hexStrings[0], pipeDisabled: hexStrings[1], piece: hexStrings[2], background: hexStrings[3], buttonBackground: hexStrings[4])
    }
    
    init() {
        self.init(hexStrings: ["8490A3", "93B58B", "86D68C", "F5FFF4", "BBEACA"])
    }
    
    func allColors() -> [UIColor] {
        return [pipeEnabled, pipeDisabled, piece, background, buttonBackground]
    }
}

protocol SingletonProtocol: class {
    func singleton(singleton: Singleton, didMoveToPalette palette: ScenePalette)
}

class Singleton {
    
    static let shared = Singleton()
    
//    var delegates: [Weak<SingletonProtocol>] = []
    weak var delegate: SingletonProtocol?
    var palette: ScenePalette
//    let currentPalette = 0
    var allPalettes: [ScenePalette] = []
    
    private init() {
        
        // Load Color Palette
        if let path = NSBundle.mainBundle().pathForResource("Palettes", ofType: "plist"), allPalettes = NSArray(contentsOfFile: path) as? [[String]] {
            for colors in allPalettes {
                self.allPalettes.append(ScenePalette(hexStrings: colors))
            }
            palette = self.allPalettes[1]
        } else {
            print("Can't find Palettes.plist, defaulting to standard palette.")
            palette = ScenePalette()
        }
    }
    
    func imageForPalette(palette: ScenePalette) -> UIImage {
        let container = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 44.0, height: 44.0)))
        let view = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 44.0, height: 44.0/5.0)))
        container.addSubview(view)
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(44.0, 44.0), true, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        
        for color in palette.allColors() {
            view.backgroundColor = color
            container.layer.renderInContext(ctx!)
//            view.frame = CGRect(origin: CGPoint(x: view.frame.origin.x + 44.0/5.0, y: 0), size: view.frame.size)
            view.frame.origin.y += 44.0/5.0
            
            
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setAppPalette(palette: ScenePalette) {
        self.palette = palette
        if let del = delegate {
            del.singleton(self, didMoveToPalette: palette)
        }
    }
    
}