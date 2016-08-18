//
//  SquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class SquareScene: AbstractGameBoardScene {
    
    var square: Square!
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0

    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 7
        self.logicalBoardHeight = 7
        return SquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        var squareWidth = size.width / CGFloat(self.logicalBoardWidth)
        totalHeight = CGFloat(self.logicalBoardHeight) * squareWidth
        totalWidth = size.width
        if totalHeight > self.size.height {
            squareWidth = size.height / CGFloat(self.logicalBoardHeight)
            totalHeight = size.height
            totalWidth = CGFloat(self.logicalBoardWidth) * squareWidth
        }
            
        square = Square(width: squareWidth, pipeWidth: squareWidth / 3)
        
        self.shapePaths[.Square] = square.path
        self.pipePaths[.Square] = square.pipePath
    
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = square.width/2 + (CGFloat(piece.col) * square.width)
        let y = square.width/2 + (CGFloat(piece.row) * square.width)
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
}
