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
}

class Singleton {
    
    static let shared = Singleton()
    
    let palette: ScenePalette
    
    private init() {
        
        // Load Color Palette
        if let path = NSBundle.mainBundle().pathForResource("Palettes", ofType: "plist"), allPalettes = NSArray(contentsOfFile: path) as? [[String]] {
            palette = ScenePalette(hexStrings: allPalettes[1])
        } else {
            print("Can't find Palettes.plist, defaulting to standard palette.")
            palette = ScenePalette()
        }
    }
    
}