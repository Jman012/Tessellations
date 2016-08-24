//
//  HexagonScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class HexagonScene: AbstractGameBoardScene {
    
    var hexagon: Hexagon!
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return HexagonBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }

    override func setShapePaths() {
        
        var hexRadius = effectiveWidth / (2 + 1.5 * CGFloat(self.logicalBoardWidth-1))
        hexagon = Hexagon(cornerRadius: hexRadius, pipeWidth: hexRadius / 2.5)
        totalHeight = CGFloat(self.logicalBoardHeight * 2) * hexagon.edgeRadius
        totalWidth = effectiveWidth
        if totalHeight > effectiveHeight {
            hexRadius = effectiveHeight / (2 * CGFloat(self.logicalBoardHeight) * CGFloat(sin(60.0.degrees)))
            hexagon = Hexagon(cornerRadius: hexRadius, pipeWidth: hexRadius / 2.5)
            totalHeight = effectiveHeight
            totalWidth = (2*hexRadius) + (CGFloat(self.logicalBoardWidth - 1) * (hexRadius * 1.5))
        }
        
        self.shapePaths[.Hexagon] = hexagon.path
        self.pipePaths[.Hexagon] = hexagon.pipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = hexagon.cornerRadius + (CGFloat(piece.col) * (hexagon.cornerRadius * 1.5))
        var y = hexagon.edgeRadius + (CGFloat(piece.row) * hexagon.edgeRadius * 2)
        if piece.col % 2 == 0 {
            y += hexagon.edgeRadius
        }
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
}
