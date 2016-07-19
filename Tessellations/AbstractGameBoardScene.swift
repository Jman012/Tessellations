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

class AbstractGameBoardScene: SKScene, OctSquareBoardProtocol {
    
    var del: GameBoardSceneProtocol?
    
    let logicalBoardWidth = 5
    let logicalBoardHeight = 7
    
    var shapePaths: [PieceType: CGPath] = [:]
    var pipePaths: [PieceType: CGPath] = [:]
    
    var rowColToNode: [RowCol: SKShapeNode] = [:]
    
    var logicalBoard: OctagonSquareBoard
    
    required override init(size: CGSize) {
        
        self.logicalBoard = OctagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
        
        super.init(size: size)
        
        self.logicalBoard.delegate = self
        self.setShapePaths()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setShapePaths() {
        fatalError("setShapePaths() has not been implemented")
    }
    
    func pieceToPoint(piece: Piece) -> CGPoint {
        fatalError("pieceToPoint() has not been implemented")
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
                
            case .Branch:
                pipe.fillColor = UIColor.redColor()
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

