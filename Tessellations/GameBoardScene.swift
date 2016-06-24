//
//  GameBoardScene.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class GameBoardScene: SKScene, OctSquareBoardProtocol {
    
    let octagonsWide = 3
    let octagonsTall = 3
    
    let octagonDiameter: CGFloat
    let adjustedDiameter: CGFloat
    let squareWidth: CGFloat
    let pipeWidth: CGFloat
    
    let octPath: CGMutablePath
    let squarePath: CGPath
    
    let octPipePath: CGMutablePath
    var squarePipePath: CGMutablePath
    let rotateActionOct = SKAction.rotateByAngle(CGFloat(-M_PI_4), duration: 0)
    let rotateActionSquare = SKAction.rotateByAngle(CGFloat(-M_PI_2), duration: 0)
    
    var rowColToNode: [RowCol: SKShapeNode] = [:]
    
    var logicalBoard: OctSquareBoard
    
    required override init(size: CGSize) {
        
        self.octagonDiameter = size.width / CGFloat(self.octagonsWide * 2)
        self.adjustedDiameter = octagonDiameter + (octagonDiameter * CGFloat(cos(0.degrees)) - octagonDiameter * CGFloat(cos(22.5.degrees)))
        self.squareWidth = adjustedDiameter * CGFloat(sin((45/2).degrees) * 2)
        self.pipeWidth = squareWidth / 3
        
        self.octPath = CGPathCreateMutable()
        var angle = 45.0 / 2
        CGPathMoveToPoint(self.octPath, nil, self.adjustedDiameter * CGFloat(cos(angle.degrees)), self.adjustedDiameter * CGFloat(sin(angle.degrees)))
        for _ in 0..<7 {
            angle += 45.0
            CGPathAddLineToPoint(self.octPath, nil, self.adjustedDiameter * CGFloat(cos(angle.degrees)), self.adjustedDiameter * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(self.octPath)
        
        var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        self.squarePath = CGPathCreateWithRect(CGRectMake(-self.squareWidth / 2, -self.squareWidth / 2, self.squareWidth, self.squareWidth), &transform)
        
        self.octPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (self.octPipePath, nil, self.pipeWidth * (-1/2), self.octagonDiameter)
        CGPathAddLineToPoint(self.octPipePath, nil, self.pipeWidth * (1/2), self.octagonDiameter)
        CGPathAddLineToPoint(self.octPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (self.octPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (self.octPipePath)
        
        self.squarePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (self.squarePipePath, nil, self.pipeWidth * (-1/2), self.squareWidth / 2)
        CGPathAddLineToPoint(self.squarePipePath, nil, self.pipeWidth * (1/2), self.squareWidth / 2)
        CGPathAddLineToPoint(self.squarePipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (self.squarePipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (self.squarePipePath)
        
        
        self.logicalBoard = OctSquareBoard(octagonsWide: self.octagonsWide, octagonsTall: self.octagonsTall)
        
        super.init(size: size)
        
        self.logicalBoard.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rowColToPoint(row row: Int, col: Int) -> CGPoint {
        if row % 2 == 0 && col % 2 == 0 {
            /* Octagon */
            return CGPoint(x: (CGFloat(col) * self.octagonDiameter) + self.octagonDiameter,
                           y: self.size.height - (CGFloat(row) * self.octagonDiameter) - self.octagonDiameter)
        } else if row % 2 == 1 && col % 2 == 1 {
            /* Square */
            return CGPoint(x: (CGFloat(col) * self.octagonDiameter) + self.octagonDiameter,
                           y: self.size.height - (CGFloat(row) * self.octagonDiameter) - self.octagonDiameter)
        } else {
            return CGPoint(x: 0, y: 0)
        }
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.logicalBoard.forAllPieces {
            // TODO: Change to Piece()
            (row: Int, col: Int, pieceType: PieceType, pipeBits: UInt8) -> Void in
            
            print("r=\(row), c=\(col) -> \(self.rowColToPoint(row: row, col: col))")
            let node: SKShapeNode
            switch pieceType {
            case .Octagon:
                let octagon = SKShapeNode(path: self.octPath)
                octagon.position = self.rowColToPoint(row: row, col: col)
                octagon.fillColor = UIColor.brownColor()
                octagon.strokeColor = UIColor.whiteColor()
                octagon.name = "Octagon \(row) \(col)"
                node = octagon
                
            case .Square:
                let square = SKShapeNode(path: self.squarePath)
                square.position = self.rowColToPoint(row: row, col: col)
                square.fillColor = UIColor.redColor()
                square.strokeColor = UIColor.whiteColor()
                square.name = "Square \(row) \(col)"
                
                node = square
            }
            
            node.userData = NSMutableDictionary()
            node.userData!["row"] = row
            node.userData!["col"] = col
            self.addChild(node)
            self.rowColToNode[RowCol(row: row, col: col)] = node
            
            self.refreshPipesForPiece(node, piece: Piece(row: row, col: col, type: pieceType, pipeBits: pipeBits, absLogicalAngle: 0)) // TODO: Change to Piece()
        }
    }
    
    func refreshPipesForPiece(node: SKShapeNode, piece: Piece) {
        piece.pipeBits.forEachBit {
            (bit, flag) in
            
            guard flag else {
                return
            }
            
            let path: CGMutablePath
            if piece.type == .Octagon {
                path = self.octPipePath
            } else {
                path = self.squarePipePath
            }
            
            let pipe = SKShapeNode(path: path)
            pipe.fillColor = UIColor.greenColor()
            pipe.strokeColor = UIColor.clearColor()
            pipe.name = "Pipe \(bit) \(piece.row) \(piece.col)"
            pipe.runAction(SKAction.rotateByAngle(-CGFloat(bit) * CGFloat(M_PI_4), duration: 0))
            node.addChild(pipe)
        }
    }
    
    func pieceAtPoint(touch: UITouch) -> SKShapeNode? {
        let location = touch.locationInNode(self)
        let nodes = self.nodesAtPoint(location).filter {
            theNode in
            if let shapeNode = theNode as? SKShapeNode {
                // TODO: Apply a rotation transform as a safeguard, even though
                // pieces will always be in the same orientation.
                return CGPathContainsPoint(shapeNode.path, nil, touch.locationInNode(shapeNode), false)
            } else {
                return false
            }
        }
        
        guard var node = nodes.first as? SKShapeNode else {
            return nil
        }
        
        while true {
            if let userData = node.userData where userData["row"] != nil && userData["col"] != nil {
                return node
            } else if let newNode = node.parent as? SKShapeNode {
                node = newNode
            } else {
                return nil
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        
        if let node = self.pieceAtPoint(touch!) {
            
            let row = node.userData!["row"] as! Int
            let col = node.userData!["col"] as! Int
            
            print("Touched at r=\(row), c=\(col)")
            self.logicalBoard.rotatePiece(row: row, col: col)
        }
    }
    
    func pieceDidChange(piece: Piece) {
        
    }
    
    func pieceDidRotate(piece: Piece) {
        if let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] {
            node.runAction(SKAction.rotateToAngle(-CGFloat(M_PI_4) * CGFloat(piece.absLogicalAngle), duration: 1, shortestUnitArc: true))
        }
    }
}
