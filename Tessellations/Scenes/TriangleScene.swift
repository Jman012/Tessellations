//
//  TriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class TriangleScene: AbstractGameBoardScene {

    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!

    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 7
        self.logicalBoardHeight = 8
        return TriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        // Measurements: http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle_files/image036.gif
        // http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
        let tri_a = size.width / ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        triangleUp = TriangleUp(sideLength: tri_a, pipeWidth: tri_a / 5.0)
        triangleDown = TriangleDown(sideLength: tri_a, pipeWidth: tri_a / 5.0)

        totalWidth = self.size.width
        totalHeight = triangleUp.height * CGFloat(self.logicalBoardHeight)
        if totalHeight > self.size.height {
            let tri_height = self.size.height / CGFloat(self.logicalBoardHeight)
            triangleUp = TriangleUp(height: tri_height, pipeWidth: tri_height * 2.0 / (5 * CGFloat(sqrt(3.0))))
            triangleDown = TriangleDown(height: tri_height, pipeWidth: tri_height * 2.0 / (5 * CGFloat(sqrt(3.0))))

            totalHeight = self.size.height
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

}
