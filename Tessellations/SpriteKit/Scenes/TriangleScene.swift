//
//  TriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

private let sizes: [(Int, Int)] = [
    (5, 4), /* Small */
    (5, 6), /* Medium */
    (7, 8), /* Large */
    (9, 10)  /* Huge */
]

class TriangleScene: AbstractGameBoardScene {

    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return TriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return TriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override class func size(boardSize: BoardSize) -> (Int, Int) {
        return sizes[boardSize.rawValue]
    }
    
    override func setShapePaths() {
        
        // Measurements: http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle_files/image036.gif
        // http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
        let tri_a = effectiveWidth / ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        triangleUp = TriangleUp(sideLength: tri_a, pipeWidth: tri_a / 5.0)
        triangleDown = TriangleDown(sideLength: tri_a, pipeWidth: tri_a / 5.0)

        totalWidth = effectiveWidth
        totalHeight = triangleUp.height * CGFloat(self.logicalBoardHeight)
        if totalHeight > effectiveHeight {
            let tri_height = effectiveHeight / CGFloat(self.logicalBoardHeight)
            triangleUp = TriangleUp(height: tri_height, pipeWidth: tri_height * 2.0 / (5 * CGFloat(sqrt(3.0))))
            triangleDown = TriangleDown(height: tri_height, pipeWidth: tri_height * 2.0 / (5 * CGFloat(sqrt(3.0))))

            totalHeight = effectiveHeight
            totalWidth = triangleUp.sideLength * ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        }
        
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = triangleUp.sideLength/2 + (CGFloat(piece.col) * triangleUp.sideLength/2)
        var y = CGFloat(piece.row) * triangleUp.height
        if piece.col % 2 == piece.row % 2 {
            y += triangleUp.r
        } else {
            y += triangleUp.R
        }
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }

    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        
        let scene = TriangleScene(size: size, boardWidth: 1, boardHeight: 1, margins: false)
        
        let piece = scene.logicalBoard.getPiece(row: 0, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: piece, inTrueDir: .SouthEastEast)
        
        return scene
    }
}
