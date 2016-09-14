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
    let rootMarker:       UIColor
    let name:             String
    
    init(pipeEnabled: UIColor, pipeDisabled: UIColor, piece: UIColor, background: UIColor, buttonBackground: UIColor, rootMarker: UIColor, name: String) {
        self.pipeEnabled =      pipeEnabled
        self.pipeDisabled =     pipeDisabled
        self.piece =            piece
        self.background =       background
        self.buttonBackground = buttonBackground
        self.rootMarker =       rootMarker
        self.name =             name
    }
    
    init(pipeEnabled: String, pipeDisabled: String, piece: String, background: String, buttonBackground: String, rootMarker: String, name: String) {
        self.pipeEnabled =      UIColor(hexString: pipeEnabled)
        self.pipeDisabled =     UIColor(hexString: pipeDisabled)
        self.piece =            UIColor(hexString: piece)
        self.background =       UIColor(hexString: background)
        self.buttonBackground = UIColor(hexString: buttonBackground)
        self.rootMarker =       UIColor(hexString: rootMarker)
        self.name =             name
    }
    
    init(name: String, hexStrings: [String]) {
        self.init(pipeEnabled: hexStrings[0], pipeDisabled: hexStrings[1], piece: hexStrings[2], background: hexStrings[3], buttonBackground: hexStrings[4], rootMarker: hexStrings[5], name: name)
    }
    
    init() {
        self.init(name: "Default", hexStrings: ["8490A3", "93B58B", "86D68C", "F5FFF4", "BBEACA"])
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
        get {
            if let override = self.paletteOverride {
                return override
            } else {
                return allPalettes[currentPalette]
            }
        }
    }
    var currentPalette = 0
    var allPalettes: [ScenePalette] = []
    var paletteOverride: ScenePalette?
    
    // ClassString -> [Size -> Number completed]
    private var progress: [String: [BoardSize: UInt]] = [:]
    
    private init() {
        
    }
    
    func load() {
        self.loadColorPalettes()
        self.loadProgress()
    }
    
    func loadColorPalettes() {
        // Load Color Palette
        // http://paletton.com/palette.php?uid=10u0u0k72%2B%2B0j%2B%2B3u%2B%2BdTO0reqW
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var paletteIndex: Int = 0
        if let thePaletteIndex = userDefaults.objectForKey("PaletteIndex") as? Int {
            paletteIndex = thePaletteIndex
        }
        
        if let path = NSBundle.mainBundle().pathForResource("Palettes", ofType: "plist"), allPalettes = NSArray(contentsOfFile: path) as? [[String: String]] {
            for colorDict in allPalettes {
                self.allPalettes.append(ScenePalette(
                    pipeEnabled:      colorDict["pipeEnabled"]!,
                    pipeDisabled:     colorDict["pipeDisabled"]!,
                    piece:            colorDict["piece"]!,
                    background:       colorDict["background"]!,
                    buttonBackground: colorDict["backgroundSecondary"]!,
                    rootMarker:       colorDict["piece"]!,
                    name:             colorDict["name"]!))
            }
        } else {
            print("Can't find Palettes.plist, defaulting to standard palette.")
            allPalettes = [ScenePalette()]
        }
        
        currentPalette = min(paletteIndex, self.allPalettes.count + 1)
    }
    
    func loadProgress() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let theProgress = defaults.objectForKey("Progress") as? [String: [String: UInt]] {
            // Load saved progress
            for (classString, boardSizeToProgress) in theProgress {
                var classDict: [BoardSize: UInt] = [:]
                for (boardSizeStr, progressUInt) in boardSizeToProgress {
                    classDict[BoardSize(rawValue: Int(boardSizeStr)!)!] = progressUInt
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
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Convert progress to an NS-liked data structure
        let theProgress = NSMutableDictionary()
        for (classString, boardSizeToProgress) in self.progress {
            theProgress.setObject(NSMutableDictionary(), forKey: classString)
            for (boardSize, prog) in boardSizeToProgress {
                let boardSizeStr = "\(boardSize.rawValue)"
                let progNum = NSNumber(integer: Int(prog))
                theProgress.objectForKey(classString)!.setObject(progNum, forKey: boardSizeStr)
            }
        }
        
        // Then save it
        defaults.setObject(theProgress, forKey: "Progress")
        defaults.synchronize()
    }
    
    func progress(forBoardType boardType: String, size boardSize: BoardSize) -> UInt {
        if let prog = progress[boardType]?[boardSize] {
            return prog
        } else {
            fatalError("No entry for \(boardType) with \(boardSize.text()) size")
        }
    }
    
    func nextBoardNumberToComplete(forBoardType boardType: String, size boardSize: BoardSize) -> UInt {
        return progress(forBoardType: boardType, size: boardSize) + 1
    }
    
    func progressDidComplete(number number: UInt, forBoardType boardType: String, size boardSize: BoardSize) {
        if self.progress(forBoardType: boardType, size: boardSize) == number - 1 {
            self.progress[boardType]![boardSize] = number
        } else {
            fatalError("Progress out of order for \(boardType) of size \(boardSize). Last completed was #\(self.progress(forBoardType: boardType, size: boardSize)), trying to say #\(number) has been completed.")
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(kPaletteDidChange, object: nil)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(currentPalette, forKey: "PaletteIndex")
    }
    
    func setOverridePalette(palette: ScenePalette?) {
        self.paletteOverride = palette
        self.setAppPalette(self.currentPalette)
    }
    
}