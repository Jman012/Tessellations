//
//  GameBoardScene.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

let bgColor =        UIColor.whiteColor()
let baseColor =      UIColor(colorLiteralRed: 0.831, green: 0.655, blue: 0.416, alpha: 1.0)
let secondaryColor = UIColor(colorLiteralRed: 0.831, green: 0.655, blue: 0.416, alpha: 1.0)
let strokeColor =    UIColor.clearColor()
let pipeOnColor =    UIColor(colorLiteralRed: 0.502, green: 0.322, blue: 0.082, alpha: 1.0)
let pipeOffColor =   UIColor(colorLiteralRed: 0.667, green: 0.475, blue: 0.224, alpha: 1.0)

protocol GameBoardSceneProtocol {
    func gameWon()
}

class GameBoardScene: SKScene, OctSquareBoardProtocol {
    
    var del: GameBoardSceneProtocol?
    
    let logicalBoardWidth = 5
    let logicalBoardHeight = 7
    
    var shapePaths: [PieceType: CGPath] = [:]
    var pipePaths: [PieceType: CGPath] = [:]
    
    let octagonDiameter: CGFloat
    let adjustedDiameter: CGFloat
    let squareWidth: CGFloat
    let pipeWidth: CGFloat
    var boardFrame: CGRect
    
//    var octPath: CGMutablePath
//    var squarePath: CGPath
    
//    var octPipePath: CGMutablePath
//    var squarePipePath: CGMutablePath
    
    var rowColToNode: [RowCol: SKShapeNode] = [:]
    
    var logicalBoard: OctagonSquareBoard
    
    required override init(size: CGSize) {
        
        self.octagonDiameter = size.width / ceil(CGFloat(self.logicalBoardWidth) / 2.0) / 2.0
        self.adjustedDiameter = octagonDiameter + (octagonDiameter * CGFloat(cos(0.degrees)) - octagonDiameter * CGFloat(cos(22.5.degrees)))
        self.squareWidth = adjustedDiameter * CGFloat(sin((45/2).degrees) * 2)
        self.pipeWidth = squareWidth / 2.5
        self.boardFrame = CGRect(x: 0, y: 0, width: self.octagonDiameter * 2 * CGFloat(self.logicalBoardWidth), height: self.octagonDiameter * 2 * CGFloat(self.logicalBoardHeight))

        
        var octPath = CGPathCreateMutable()
        var angle = 45.0 / 2
        CGPathMoveToPoint(octPath, nil, self.adjustedDiameter * CGFloat(cos(angle.degrees)), self.adjustedDiameter * CGFloat(sin(angle.degrees)))
        for _ in 0..<7 {
            angle += 45.0
            CGPathAddLineToPoint(octPath, nil, self.adjustedDiameter * CGFloat(cos(angle.degrees)), self.adjustedDiameter * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(octPath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        octPath = CGPathCreateMutableCopyByTransformingPath(octPath, &transformScale)!
        self.shapePaths[.Octagon] = octPath
        
        var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        var squarePath = CGPathCreateWithRect(CGRectMake(-self.squareWidth / 2, -self.squareWidth / 2, self.squareWidth, self.squareWidth), &transform)
        squarePath = CGPathCreateMutableCopyByTransformingPath(squarePath, &transformScale)!
        self.shapePaths[.Square] = squarePath
        
        var octPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (octPipePath, nil, self.pipeWidth * (-1/2), self.octagonDiameter - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), self.octagonDiameter - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (octPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (octPipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        octPipePath = CGPathCreateMutableCopyByTransformingPath(octPipePath, &transformScale)!
        self.pipePaths[.Octagon] = octPipePath
        
        var squarePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (squarePipePath, nil, self.pipeWidth * (-1/2), self.squareWidth / 2)
        CGPathAddLineToPoint(squarePipePath, nil, self.pipeWidth * (1/2), self.squareWidth / 2)
        CGPathAddLineToPoint(squarePipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (squarePipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (squarePipePath)
        squarePipePath = CGPathCreateMutableCopyByTransformingPath(squarePipePath, &transformScale)!
        self.pipePaths[.Square] = squarePipePath

        
        
        self.logicalBoard = OctagonSquareBoard(octagonsWide: self.logicalBoardWidth, octagonsTall: self.logicalBoardHeight)
        
        super.init(size: size)
        
        self.boardFrame.origin.y = (self.frame.height - self.octagonDiameter * CGFloat(self.logicalBoardHeight)) / 2.0
        
        self.logicalBoard.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pieceToPoint(piece: Piece) -> CGPoint {
        let (row, col) = (piece.row, piece.col)
        
        if row % 2 == 0 && col % 2 == 0 {
            /* Octagon */
            return CGPoint(x: (CGFloat(col) * self.octagonDiameter) + self.octagonDiameter,
                           y: self.size.height - (CGFloat(row) * self.octagonDiameter) - self.octagonDiameter - self.boardFrame.origin.y)
        } else if row % 2 == 1 && col % 2 == 1 {
            /* Square */
            return CGPoint(x: (CGFloat(col) * self.octagonDiameter) + self.octagonDiameter,
                           y: self.size.height - (CGFloat(row) * self.octagonDiameter) - self.octagonDiameter - self.boardFrame.origin.y)
        } else {
            return CGPoint(x: 0, y: 0)
        }
    }
    
    func nodeForPiece(piece: Piece) -> SKShapeNode {
        let node = SKShapeNode(path: self.shapePaths[piece.type]!)
        node.position = self.pieceToPoint(piece)
        node.fillColor = baseColor
        
        node.strokeColor = strokeColor
        node.lineWidth = 0.0
        node.userData = NSMutableDictionary()
        node.userData!["row"] = piece.row
        node.userData!["col"] = piece.col
        
        return node
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = bgColor
        
        self.logicalBoard.forAllPieces {
            (piece: Piece) in
            
            // To reduce repetition below
            let (row, col) = (piece.row, piece.col)
            
            let node = self.nodeForPiece(piece)
            
            self.addChild(node)
            self.rowColToNode[RowCol(row: row, col: col)] = node
            
            self.refreshPipesForPiece(node, piece: piece)
            
        }
    }
    
    func refreshPipesForPiece(node: SKShapeNode, piece: Piece) {
        node.removeAllChildren()
        
        piece.forEachPipeState {
            trueDir, status in
            
            guard status != .None else {
                return
            }
            
            let path = self.pipePaths[piece.type]!
            
            let pipe = SKShapeNode(path: path)
            switch status {
            case .Disabled:
                pipe.fillColor = pipeOffColor
                
            case .Branch: fallthrough
            case .Source:
                pipe.fillColor = pipeOnColor
                
            default: break
            }
            pipe.strokeColor = UIColor.clearColor()
            pipe.name = "Pipe \(trueDir.rawValue) \(piece.row) \(piece.col)"
            pipe.runAction(SKAction.rotateToAngle(-CGFloat(Double(piece.logicalDirForTrueDir(trueDir).rawValue).degrees), duration: 0, shortestUnitArc: true))
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
            
            self.logicalBoard.rotatePiece(row: row, col: col)
        }
    }
    
    func gameWon() {
        if let del = self.del {
            del.gameWon()
        }
    }
    
    func boardDidClear() {
        for node in self.children {
            // Remove the pipes of each piece
            node.removeAllChildren()
            node.runAction(SKAction.rotateToAngle(0, duration: 0))
        }
    }
    
    func pieceDidChange(piece: Piece) {
        if let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] {
            self.refreshPipesForPiece(node, piece: piece)
        }
    }
    
    func pieceDidRotate(piece: Piece) {
        if let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] {
            node.runAction(SKAction.rotateToAngle(-CGFloat(Double(piece.absLogicalAngle).degrees), duration: 0, shortestUnitArc: true))
        }
    }
}

