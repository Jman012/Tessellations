//
//  HexagonTriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/12/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

private let sizes: [(Int, Int)] = [
    (3, 6), /* Small */
    (5, 6), /* Medium */
    (7, 10), /* Large */
    (9, 14)  /* Huge */
]

class HexagonTriangleScene: AbstractGameBoardScene {

    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    var hexagon: Hexagon!
    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return HexagonTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return HexagonTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        // Try by width
        var tri_a = (effectiveWidth / ceil(CGFloat(self.logicalBoardWidth)/2)) / 2
        triangleUp = TriangleUp(sideLength: tri_a, pipeWidth: tri_a / 4)
        totalWidth = effectiveWidth
        totalHeight = triangleUp.height * CGFloat(self.logicalBoardHeight)
        if totalHeight > effectiveHeight {
            tri_a = effectiveHeight / CGFloat(self.logicalBoardHeight)
            totalHeight = effectiveHeight
            totalWidth = tri_a * 2 * ceil(CGFloat(self.logicalBoardWidth)/2)
        }
        
        
        triangleUp = TriangleUp(sideLength: tri_a, pipeWidth: tri_a / 5)
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        triangleDown = TriangleDown(sideLength: tri_a, pipeWidth: tri_a / 5)
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
        
        hexagon = Hexagon(triangleSide: tri_a, pipeWidth: tri_a / 5)
        self.shapePaths[.Hexagon] = hexagon.path
        self.pipePaths[.Hexagon] = hexagon.pipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = triangleUp.sideLength + (CGFloat(piece.col) * triangleUp.sideLength)
        var y = triangleUp.height + (CGFloat(piece.row/2) * 2 * triangleUp.height)
        
        if piece.type == .TriangleUp {
            y += triangleUp.R
        } else if piece.type == .TriangleDown {
            y -= triangleUp.R
        }
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        
        let scene = HexagonTriangleScene(size: size, boardWidth: 2, boardHeight: 2, margins: false)
        let newHexagonCornerDiameter = scene.hexagon.cornerDiameter - (scene.triangleUp.sideLength / 2.0)

        scene.hexagon = Hexagon(cornerDiameter: newHexagonCornerDiameter, pipeWidth: 1)
        scene.hexagon = Hexagon(cornerDiameter: newHexagonCornerDiameter, pipeWidth: scene.hexagon.sideLength / 3.5)
        scene.shapePaths[.Hexagon] = scene.hexagon.path
        scene.pipePaths[.Hexagon] = scene.hexagon.pipePath
//
        scene.triangleUp = TriangleUp(sideLength: scene.hexagon.sideLength, pipeWidth: scene.hexagon.sideLength / 3.5)
        scene.shapePaths[.TriangleUp] = scene.triangleUp.path
        scene.pipePaths[.TriangleUp] = scene.triangleUp.pipePath
        
        scene.totalWidth = scene.effectiveWidth
        scene.totalHeight = scene.hexagon.edgeDiameter
        
        scene.logicalBoard.board[0][1] = nil
        scene.logicalBoard.sourceRow = 1
        scene.logicalBoard.sourceCol = 0
        
        let hPiece = scene.logicalBoard.getPiece(row: 1, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: hPiece, inTrueDir: .SouthEastEast)
        
        let tPiece = scene.logicalBoard.getPiece(row: 1, col: 1)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: tPiece, inTrueDir: .NorthWestWest)
        
        scene.constructTextures()
        
        return scene
    }

}
