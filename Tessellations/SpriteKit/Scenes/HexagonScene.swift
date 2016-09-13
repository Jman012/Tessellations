//
//  HexagonScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

private let sizes: [(Int, Int)] = [
    (4, 4), /* Small */
    (5, 6), /* Medium */
    (7, 8), /* Large */
    (9, 10) /* Huge */
]

class HexagonScene: AbstractGameBoardScene {
    
    var hexagon: Hexagon!
    var shouldMoveDown: Bool = true
    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return HexagonBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return HexagonBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override class func size(boardSize: BoardSize) -> (Int, Int) {
        return sizes[boardSize.rawValue]
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
        if piece.col % 2 == 0 && shouldMoveDown {
            y += hexagon.edgeRadius
        }
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        
        let scene = HexagonScene(size: size, boardWidth: 1, boardHeight: 1, margins: false)
        scene.logicalBoard.board[0][0] = Piece(row: 0, col: 0, type: .Hexagon)
        scene.shouldMoveDown = false
        
        let piece = scene.logicalBoard.getPiece(row: 0, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: piece, inTrueDir: .SouthEastEast)
        
        return scene
    }
}
