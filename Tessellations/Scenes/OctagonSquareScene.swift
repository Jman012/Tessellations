//
//  OctagonSquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class OctagonSquareScene: AbstractGameBoardScene {
    
    var octagon: Octagon!
    var square45: Square45!
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return OctagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
    
        var octagonRadius = effectiveWidth / ceil(CGFloat(self.logicalBoardWidth) / 2.0) / 2.0
        
        totalWidth = effectiveWidth
        totalHeight = octagonRadius * 2 * ceil(CGFloat(self.logicalBoardHeight) / 2.0)
        if totalHeight > effectiveHeight {
            octagonRadius = effectiveHeight / ceil(CGFloat(self.logicalBoardHeight) / 2.0) / 2.0
            
            totalHeight = effectiveHeight
            totalWidth = octagonRadius * 2 * ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        }
        
        
        octagon = Octagon(edgeRadius: octagonRadius, pipeWidth: octagonRadius / 2.5)
        self.shapePaths[.Octagon] = octagon.path
        self.pipePaths[.Octagon] = octagon.pipePath
        
        square45 = Square45(width: octagon.sideLength, pipeWidth: octagonRadius / 2.5)
        self.shapePaths[.Square45] = square45.path
        self.pipePaths[.Square45] = square45.pipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x: CGFloat = octagon.edgeRadius + (CGFloat(piece.col) * octagon.edgeRadius)
        let y: CGFloat = octagon.edgeRadius + (CGFloat(piece.row) * octagon.edgeRadius)
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
}