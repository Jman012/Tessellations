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

    var tri_a: CGFloat = 0
    var tri_r: CGFloat = 0
    var tri_R: CGFloat = 0
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 9
        self.logicalBoardHeight = 8
        return TriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        // Measurements: http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle_files/image036.gif
        // http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
        tri_a = size.width / ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        tri_r = tri_a * sqrt(3.0) / 6.0
        tri_R = tri_a * sqrt(3.0) / 3.0
        totalWidth = self.size.width
        totalHeight = (tri_r + tri_R) * CGFloat(self.logicalBoardHeight)
        if totalHeight > self.size.height {
            let tri_height = self.size.height / CGFloat(self.logicalBoardHeight)
            tri_r = tri_height / 3.0
            tri_R = tri_height * (2.0 / 3.0)
            tri_a = (6 * tri_r) / sqrt(3.0)
            totalHeight = self.size.height
            totalWidth = tri_a * ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        }
        
        let pipeWidth = tri_a / 5.0
        
        var triangleUpPath = CGPathCreateMutable()
        var angle = 90.0
        CGPathMoveToPoint(triangleUpPath, nil, tri_R * CGFloat(cos(angle.degrees)), tri_R * CGFloat(sin(angle.degrees)))
        for _ in 0..<2 {
            angle += 120.0
            CGPathAddLineToPoint(triangleUpPath, nil, tri_R * CGFloat(cos(angle.degrees)), tri_R * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(triangleUpPath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        triangleUpPath = CGPathCreateMutableCopyByTransformingPath(triangleUpPath, &transformScale)!
        self.shapePaths[.TriangleUp] = triangleUpPath
        
        var transformRotate = CGAffineTransformMakeRotation(CGFloat(180.0.degrees))
        let triangleDownPath = CGPathCreateMutableCopyByTransformingPath(triangleUpPath, &transformRotate)!
        self.shapePaths[.TriangleDown] = triangleDownPath
        
        
        var trianglePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (trianglePipePath, nil, pipeWidth * (-1/2), tri_r - 0.5)
        CGPathAddLineToPoint(trianglePipePath, nil, pipeWidth * (1/2), tri_r - 0.5)
        CGPathAddLineToPoint(trianglePipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (trianglePipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (trianglePipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        trianglePipePath = CGPathCreateMutableCopyByTransformingPath(trianglePipePath, &transformScale)!
        self.pipePaths[.TriangleUp] = trianglePipePath
        self.pipePaths[.TriangleDown] = trianglePipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = tri_a/2 + (CGFloat(piece.col) * tri_a/2)
        var y = tri_r + CGFloat(piece.row) * (tri_r + tri_R)
        if piece.col % 2 == piece.row % 2 {
            y += tri_r
        } else {
            y += tri_R
        }
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }

}
