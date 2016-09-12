//
//  SquareTriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/27/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

private let sizes: [(Int, Int)] = [
    (3, 5), /* Small */
    (7, 5), /* Medium */
    (7, 9), /* Large */
    (11, 13)  /* Huge */
]

class SquareTriangleScene: AbstractGameBoardScene {
    
    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    var triangleLeft: TriangleLeft!
    var triangleRight: TriangleRight!
    var square30: Square30!
    var squareN30: SquareN30!

    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return SquareTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return SquareTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        let numOddW = floor(Double(self.logicalBoardWidth) / 2.0)
        let numEvenW = ceil(Double(self.logicalBoardWidth) / 2.0)
        let numOddH = floor(Double(self.logicalBoardHeight) / 2.0)
        let numEvenH = ceil(Double(self.logicalBoardHeight) / 2.0)
        
        var denominator = (1.0 + sqrt(3.0))/(2.0)
        denominator += (0.5 * numOddW)
        denominator += (sqrt(3.0)/2.0)*(numEvenW - 1.0)
        let sideLength = effectiveWidth / CGFloat(denominator)
        
        self.makeShapesForSideLength(sideLength)
        
        totalWidth = effectiveWidth
        let a = triangleUp.sideLength
        let h = triangleUp.height
        totalHeight = a + (CGFloat(numOddH) * h) + (CGFloat(numEvenH) - 1.0) * 0.5 * a
        
        if totalHeight > effectiveHeight {
            // Change the proportions to fit the screen is the original didn't fit nicely
            let percent = effectiveHeight / totalHeight
            
            totalWidth = totalWidth * percent
            totalHeight = effectiveHeight
            
            self.makeShapesForSideLength(sideLength * percent)
        }
        
    }
    
    func makeShapesForSideLength(sideLength: CGFloat) {
        let pipeWidth = sideLength / 5.0
       
        triangleUp = TriangleUp(sideLength: sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        triangleDown = TriangleDown(sideLength: sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
        
        triangleLeft = TriangleLeft(sideLength: sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleLeft] = triangleLeft.path
        self.pipePaths[.TriangleLeft] = triangleLeft.pipePath
        
        triangleRight = TriangleRight(sideLength: sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleRight] = triangleRight.path
        self.pipePaths[.TriangleRight] = triangleRight.pipePath
        
        square30 = Square30(width: sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.Square30] = square30.path
        self.pipePaths[.Square30] = square30.pipePath
        
        squareN30 = SquareN30(width: sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.SquareN30] = squareN30.path
        self.pipePaths[.SquareN30] = squareN30.pipePath
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let (row, col) = (piece.row, piece.col)
        
        let a = triangleUp.sideLength
        let h = triangleUp.height
        
        var x: CGFloat = 0, y: CGFloat = 0
        
        let temp = (0.5 * (h + 0.5 * a))
        x = temp      + (CGFloat(col) * temp)
        y = (0.5 * a) + (CGFloat(row) * temp)
        
        switch piece.type {
        case .TriangleUp:
            y = y + temp - triangleUp.r
        case .TriangleDown:
            y = y - temp + triangleUp.r
        case .TriangleLeft:
            x = x + temp - triangleUp.r
        case .TriangleRight:
            x = x - temp + triangleUp.r
        
            
        default: break
        }
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        
        let scene = SquareTriangleScene(size: size, boardWidth: 1, boardHeight: 2, margins: false)
        scene.logicalBoard.sourceRow = 1
        
        let tPiece = scene.logicalBoard.getPiece(row: 0, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: tPiece, inTrueDir: .SouthSouthWest)
        
        let sPiece = scene.logicalBoard.getPiece(row: 1, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: sPiece, inTrueDir: .NorthNorthEast)
        
        return scene
    }

}
