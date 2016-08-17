//
//  HexagonTriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/12/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class HexagonTriangleScene: AbstractGameBoardScene {

    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    var hexagon: Hexagon!

    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 7
        self.logicalBoardHeight = 10
        return HexagonTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        // Try by width
        var tri_a = (self.size.width / ceil(CGFloat(self.logicalBoardWidth)/2)) / 2
        triangleUp = TriangleUp(sideLength: tri_a, pipeWidth: tri_a / 4)
        totalWidth = self.size.width
        totalHeight = triangleUp.height * CGFloat(self.logicalBoardHeight)
        if totalHeight > self.size.height {
            tri_a = self.size.height / CGFloat(self.logicalBoardHeight)
            totalHeight = self.size.height
            totalWidth = tri_a * 2 * ceil(CGFloat(self.logicalBoardWidth)/2)
        }
        
        
        triangleUp = TriangleUp(sideLength: tri_a, pipeWidth: tri_a / 3.5)
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        triangleDown = TriangleDown(sideLength: tri_a, pipeWidth: tri_a / 3.5)
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
        
        hexagon = Hexagon(triangleSide: tri_a, pipeWidth: tri_a / 3.5)
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

}
