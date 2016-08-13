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

    var tri_a: CGFloat = 0
    var tri_r: CGFloat = 0
    var tri_R: CGFloat = 0
    var pipeWidth: CGFloat = 0
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 9
        self.logicalBoardHeight = 14
        return HexagonTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        // Try by width
        tri_a = (self.size.width / ceil(CGFloat(self.logicalBoardWidth)/2)) / 2
        totalWidth = self.size.width
        totalHeight = tri_a * CGFloat(self.logicalBoardHeight)
        if totalHeight > self.size.height {
            tri_a = self.size.height / CGFloat(self.logicalBoardHeight)
            totalHeight = self.size.height
            totalWidth = tri_a * 2 * ceil(CGFloat(self.logicalBoardWidth)/2)
        }
        
//        tri_a = 30
        tri_r = tri_a * sqrt(3.0) / 6.0
        tri_R = tri_a * sqrt(3.0) / 3.0
        pipeWidth = tri_a / 4
        totalHeight = CGFloat(self.logicalBoardHeight) * (tri_r + tri_R)
        
        var triangleUpPath = CGPathCreateMutable()
        var angle = 90.0
        CGPathMoveToPoint(triangleUpPath, nil, tri_R * CGFloat(cos(angle.degrees)), tri_R * CGFloat(sin(angle.degrees)))
        for _ in 0..<2 {
            angle += 120.0
            CGPathAddLineToPoint(triangleUpPath, nil, tri_R * CGFloat(cos(angle.degrees)), tri_R * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(triangleUpPath)
        var transformScale = CGAffineTransformMakeScale(0.90, 0.90)
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
        transformScale = CGAffineTransformMakeScale(1.0, 0.90)
        trianglePipePath = CGPathCreateMutableCopyByTransformingPath(trianglePipePath, &transformScale)!
        self.pipePaths[.TriangleUp] = trianglePipePath
        self.pipePaths[.TriangleDown] = trianglePipePath
        
        
        
        
        let hexRadius = tri_a
        let adjustedRadius = hexRadius * CGFloat(sin(60.0.degrees))
        
        var hexPath = CGPathCreateMutable()
        angle = 0.0
        CGPathMoveToPoint(hexPath, nil, hexRadius * CGFloat(cos(angle.degrees)), hexRadius * CGFloat(sin(angle.degrees)))
        for _ in 0..<5 {
            angle += 60.0
            CGPathAddLineToPoint(hexPath, nil, hexRadius * CGFloat(cos(angle.degrees)), hexRadius * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(hexPath)
        transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        hexPath = CGPathCreateMutableCopyByTransformingPath(hexPath, &transformScale)!
        self.shapePaths[.Hexagon] = hexPath
        
        
        var hexPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (hexPipePath, nil, pipeWidth * (-1/2), adjustedRadius - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, pipeWidth * (1/2), adjustedRadius - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (hexPipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (hexPipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        hexPipePath = CGPathCreateMutableCopyByTransformingPath(hexPipePath, &transformScale)!
        self.pipePaths[.Hexagon] = hexPipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = tri_a + (CGFloat(piece.col) * tri_a)
        var y = (tri_r + tri_R) + (CGFloat(piece.row/2) * 2 * (tri_r + tri_R))
        
        if piece.type == .TriangleUp {
            y += tri_R
        } else if piece.type == .TriangleDown {
            y -= tri_R
        }
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }

}
