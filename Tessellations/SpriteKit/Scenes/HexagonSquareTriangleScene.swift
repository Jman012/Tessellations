//
//  HexagonSquareTriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

private let sizes: [(Int, Int)] = [
    (7, 5), /* Small */
    (11, 5), /* Medium */
    (11, 9), /* Large */
    (15, 13)  /* Huge */
]

class HexagonSquareTriangleScene: AbstractGameBoardScene {

    var hexagon30: Hexagon30!
    var square: Square!
    var square30: Square30!
    var squareN30: SquareN30!
    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    
    var bandHeight: CGFloat {
        get { return hexagon30.cornerRadius + triangleUp.height - square.halfWidth }
    }
    var halfBandHeight: CGFloat {
        get { return bandHeight / 2.0 }
    }
    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return HexagonSquareTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return HexagonSquareTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        let evenCols = ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        let oddCols = floor(CGFloat(self.logicalBoardWidth) / 2.0)
        let evenRows = ceil(CGFloat(self.logicalBoardHeight) / 2.0)
        let oddRows = floor(CGFloat(self.logicalBoardHeight) / 2.0)
        
        
        let temp: CGFloat = 1.0 / sqrt(3.0)
        let hexagonEdgeRadius = effectiveWidth / ((temp + 1.0) + oddCols + (evenCols - 1.0)*temp)
        
        self.makeShapesForHexa30EdgeRadius(hexagonEdgeRadius)
        
        totalWidth = effectiveWidth
        totalHeight = hexagon30.cornerDiameter + (evenRows-1) * (square.width + (hexagon30.cornerRadius-square.halfWidth)) + oddRows * (triangleUp.height)
        
        if totalHeight > effectiveHeight {
            // Change the proportions to fit the screen is the original didn't fit nicely
            let percent = effectiveHeight / totalHeight
            
            totalWidth = totalWidth * percent
            totalHeight = effectiveHeight
            
            self.makeShapesForHexa30EdgeRadius(hexagonEdgeRadius * percent)
        }
        
    }
    
    func makeShapesForHexa30SideLength(hexagon30SideLength: CGFloat) {
        let hex = Hexagon30(triangleSide: hexagon30SideLength, pipeWidth: 0.0)
        self.makeShapesForHexa30Width(hex.edgeDiameter)
    }
    
    func makeShapesForHexa30EdgeRadius(hexagon30EdgeRadius: CGFloat) {
        let hex = Hexagon30(edgeRadius: hexagon30EdgeRadius, pipeWidth: 0.0)
        self.makeShapesForHexa30Width(hex.edgeDiameter)
    }
    
    func makeShapesForHexa30Width(hexagon30Width: CGFloat) {
        hexagon30 = Hexagon30(edgeDiameter: hexagon30Width, pipeWidth: 0)
        let pipeWidth = hexagon30.sideLength / 5.0
        
        hexagon30 = Hexagon30(edgeDiameter: hexagon30Width, pipeWidth: pipeWidth)
        self.shapePaths[.Hexagon30] = hexagon30.path
        self.pipePaths[.Hexagon30] = hexagon30.pipePath
        
        square = Square(width: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.Square] = square.path
        self.pipePaths[.Square] = square.pipePath
        
        square30 = Square30(width: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.Square30] = square30.path
        self.pipePaths[.Square30] = square30.pipePath
        
        squareN30 = SquareN30(width: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.SquareN30] = squareN30.path
        self.pipePaths[.SquareN30] = squareN30.pipePath
        
        triangleUp = TriangleUp(sideLength: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        triangleDown = TriangleDown(sideLength: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let (row, col) = (piece.row, piece.col)
        var x: CGFloat = 0, y: CGFloat = 0
        
        if margins != CGSizeZero {
            // Normal
            if (row % 4 == 0 && col % 4 == 1) || (row % 4 == 2 && col % 4 == 3) || /* Hex 30 */
               (row % 4 == 0 && col % 4 == 3) || (row % 4 == 2 && col % 4 == 1) {  /* Square */
                /* BOTH Hexagon 30 Degrees AND Square (Regular) */
                x = (square.halfWidth + hexagon30.edgeRadius) + (square.halfWidth + hexagon30.edgeRadius) * CGFloat(col - 1) * 0.5
                y = hexagon30.cornerRadius + (hexagon30.cornerRadius + triangleUp.height + square.halfWidth) * (CGFloat(row) * 0.5)
                
            } else {
                /* Sq30, Sq-30, TUp, and TDown */
                x = (square.halfWidth + hexagon30.edgeRadius) * 0.5 + CGFloat(col) * (hexagon30.edgeRadius + square.halfWidth) * 0.5
                y = (hexagon30.cornerRadius + square.halfWidth + halfBandHeight) + CGFloat(row - 1) * 0.5 * (bandHeight + square.width)
                
                if (row % 4 == 1 && col % 4 == 1) || (row % 4 == 3 && col % 4 == 3) {
                    /* Triangle Up */
                    y = y + halfBandHeight - triangleUp.r
                } else if (row % 4 == 1 && col % 4 == 3) || (row % 4 == 3 && col % 4 == 1) {
                    /* Triangle Down */
                    y = y - halfBandHeight + triangleDown.r
                }
            }
        } else {
            // Thumbnail, slightly different
            if (row % 4 == 0 && col % 4 == 1) || (row % 4 == 2 && col % 4 == 3) || /* Hex 30 */
                (row % 4 == 0 && col % 4 == 3) || (row % 4 == 2 && col % 4 == 1) {  /* Square */
                /* BOTH Hexagon 30 Degrees AND Square (Regular) */
                x = hexagon30.edgeRadius + (square.halfWidth + hexagon30.edgeRadius) * CGFloat(col - 1) * 0.5
                y = hexagon30.cornerRadius + (hexagon30.cornerRadius + triangleUp.height + square.halfWidth) * (CGFloat(row) * 0.5)
                
            } else {
                /* Sq30, Sq-30, TUp, and TDown */
                x = ((square.halfWidth + hexagon30.edgeRadius) * 0.5 - square.halfWidth) + CGFloat(col) * (hexagon30.edgeRadius + square.halfWidth) * 0.5
                y = (hexagon30.cornerRadius + square.halfWidth + halfBandHeight) + CGFloat(row - 1) * 0.5 * (bandHeight + square.width)
                
                if (row % 4 == 1 && col % 4 == 1) || (row % 4 == 3 && col % 4 == 3) {
                    /* Triangle Up */
                    y = y + halfBandHeight - triangleUp.r
                } else if (row % 4 == 1 && col % 4 == 3) || (row % 4 == 3 && col % 4 == 1) {
                    /* Triangle Down */
                    y = y - halfBandHeight + triangleDown.r
                }
            }
        }
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        let scene = HexagonSquareTriangleScene(size: size, boardWidth: 4, boardHeight: 2, margins: false)
        
        scene.logicalBoard.board[1][0] = nil
        scene.logicalBoard.board[1][1] = nil
        scene.logicalBoard.board[0][3] = nil
        scene.logicalBoard.sourceCol = 1
        
        let hexagonSideLength = size.width / CGFloat(1.0 + sqrt(3.0))
        scene.makeShapesForHexa30SideLength(hexagonSideLength)
        
        let evenRows = ceil(CGFloat(scene.logicalBoardHeight) / 2.0)
        let oddRows = floor(CGFloat(scene.logicalBoardHeight) / 2.0)
        scene.totalHeight = scene.hexagon30.cornerDiameter + (evenRows-1) * (scene.square.width + scene.triangleUp.r) + oddRows * (scene.triangleUp.height)
        scene.totalWidth = scene.effectiveWidth
        
        if scene.totalHeight > scene.effectiveHeight {
            // Change the proportions to fit the screen is the original didn't fit nicely
            let percent = scene.effectiveHeight / scene.totalHeight
            
            scene.totalWidth = scene.totalWidth * percent
            scene.totalHeight = scene.effectiveHeight
            
            scene.makeShapesForHexa30SideLength(hexagonSideLength * percent)
        }
        
        scene.constructTextures()
        scene.refreshAllPieces()
        
        let hPiece = scene.logicalBoard.getPiece(row: 0, col: 1)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: hPiece, inTrueDir: .SouthSouthEast)
        
        let sPiece = scene.logicalBoard.getPiece(row: 1, col: 2)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: sPiece, inTrueDir: .NorthEastEast)
        scene.logicalBoard.setPipeState(.Source, ofPiece: sPiece, inTrueDir: .NorthNorthWest)
        
        let tPiece = scene.logicalBoard.getPiece(row: 1, col: 3)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: tPiece, inTrueDir: .SouthWestWest)

        
        return scene
    }
}
