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
    let name:             String
    
    init(pipeEnabled: UIColor, pipeDisabled: UIColor, piece: UIColor, background: UIColor, buttonBackground: UIColor, name: String) {
        self.pipeEnabled =      pipeEnabled
        self.pipeDisabled =     pipeDisabled
        self.piece =            piece
        self.background =       background
        self.buttonBackground = buttonBackground
        self.name =             name
    }
    
    init(pipeEnabled: String, pipeDisabled: String, piece: String, background: String, buttonBackground: String, name: String) {
        self.pipeEnabled =      UIColor(hexString: pipeEnabled)
        self.pipeDisabled =     UIColor(hexString: pipeDisabled)
        self.piece =            UIColor(hexString: piece)
        self.background =       UIColor(hexString: background)
        self.buttonBackground = UIColor(hexString: buttonBackground)
        self.name =             name
    }
    
    init(hexStrings: [String]) {
        self.init(pipeEnabled: hexStrings[0], pipeDisabled: hexStrings[1], piece: hexStrings[2], background: hexStrings[3], buttonBackground: hexStrings[4], name: hexStrings[5])
    }
    
    init() {
        self.init(hexStrings: ["8490A3", "93B58B", "86D68C", "F5FFF4", "BBEACA", "Default"])
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
    weak var delegate: SingletonProtocol?
    
    var palette: ScenePalette {
        get { return allPalettes[currentPalette] }
    }
    var currentPalette = 0
    var allPalettes: [ScenePalette] = []
    
    // ClassString -> [Size -> Number completed]
    var progress: [String: [BoardSize: UInt]] = [:]
    
    private init() {
        
    }
    
    func load() {
        self.loadColorPalettes()
        self.loadProgress()
    }
    
    func loadColorPalettes() {
        // Load Color Palette
        if let path = NSBundle.mainBundle().pathForResource("Palettes", ofType: "plist"), allPalettes = NSArray(contentsOfFile: path) as? [[String]] {
            for colors in allPalettes {
                self.allPalettes.append(ScenePalette(hexStrings: colors))
            }
            currentPalette = 0
        } else {
            print("Can't find Palettes.plist, defaulting to standard palette.")
            allPalettes = [ScenePalette()]
        }
    }
    
    func loadProgress() {
        // Load progress
        let defaults = NSUserDefaults.standardUserDefaults()
        if let theProgress = defaults.objectForKey("Progress") as? [String: [Int: UInt]] {
            for (classString, boardSizeToProgress) in theProgress {
                var classDict: [BoardSize: UInt] = [:]
                for (boardSizeInt, progress) in boardSizeToProgress {
                    classDict[BoardSize(rawValue: boardSizeInt)!] = progress
                }
                self.progress[classString] = classDict
            }
        } else {
            // Make fresh one
            for classString in sceneClassStrings {
                self.progress[classString] = [:]
                for boardSizeNum in 0..<BoardSize.count() {
                    self.progress[classString]![BoardSize(rawValue: boardSizeNum)!] = 0
                }
            }
        }
    }
    
    func syncProgress() {
        
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
            view.frame.origin.y += 44.0/5.0
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setAppPalette(paletteNum: Int) {
        currentPalette = paletteNum
        if let del = delegate {
            del.singleton(self, didMoveToPalette: palette)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.generateThumbnails()
    }
    
}