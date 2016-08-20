//
//  GameBoardScene.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

let bgColor =         UIColor.whiteColor()
let baseColor =       UIColor(colorLiteralRed: 0.831, green: 0.655, blue: 0.416, alpha: 1.0)
//let baseColor =      UIColor.whiteColor()
let secondaryColor =  UIColor(colorLiteralRed: 0.831, green: 0.655, blue: 0.416, alpha: 1.0)
let pathStrokeColor = UIColor.whiteColor()
let pipeStrokeColor = UIColor.clearColor()
let pipeOnColor =     UIColor(colorLiteralRed: 0.502, green: 0.322, blue: 0.082, alpha: 1.0)
let pipeOffColor =    UIColor(colorLiteralRed: 0.667, green: 0.475, blue: 0.224, alpha: 1.0)

protocol GameBoardSceneProtocol {
    func gameWon()
}

class AbstractGameBoardScene: SKScene, OctSquareBoardProtocol {
    
    var del: GameBoardSceneProtocol?
    
    var logicalBoardWidth = 7
    var logicalBoardHeight = 6
    
    var shapePaths: [PieceType: CGPath] = [:]
    var pipePaths: [PieceType: CGPath] = [:]
    
    var rowColToNode: [RowCol: PieceNode] = [:]
    
    var logicalBoard: AbstractGameBoard!
    
    required override init(size: CGSize) {
        
        super.init(size: size)
        
        self.logicalBoard = self.initLogicalBoard()
        self.logicalBoard.delegate = self
        self.setShapePaths()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initLogicalBoard() -> AbstractGameBoard {
        fatalError("initLogialBoard() has not been implemented")
    }
    
    func setShapePaths() {
        fatalError("setShapePaths() has not been implemented")
    }
    
    func pieceToPoint(piece: Piece) -> CGPoint {
        fatalError("pieceToPoint() has not been implemented")
    }
    
    func nodeForPiece(piece: Piece) -> PieceNode {
        let node = PieceNode(path: self.shapePaths[piece.type]!)
        node.position = self.pieceToPoint(piece)
        node.fillColor = baseColor
        
        node.strokeColor = pathStrokeColor
        node.lineWidth = 2.0
        
        node.row = piece.row
        node.col = piece.col
        
        return node
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = bgColor
        
        self.refreshAllPieces()
    }
    
    func refreshAllPieces() {
        self.removeAllChildren()
        
        self.logicalBoard.forAllPieces {
            (piece: Piece) in
            
            // To reduce repetition below
            let (row, col) = (piece.row, piece.col)
            
            let node = self.nodeForPiece(piece)
            
            self.addChild(node)
            self.rowColToNode[RowCol(row: row, col: col)] = node
            
            piece.forEachPipeState {
                trueDir, state in
                
                self.piecePipeDidChangeState(piece, logicalDir: piece.logicalDirForTrueDir(trueDir), fromOldState: .None)
            }
            
        }
    }
    
    func sceneSizeDidChange() {
        self.setShapePaths()
        self.refreshAllPieces()
    }
    
    func pieceAtPoint(touch: UITouch) -> PieceNode? {
        let location = touch.locationInNode(self)
        let nodes = self.nodesAtPoint(location).filter {
            theNode in
            if let shapeNode = theNode as? PieceNode {
                // TODO: Apply a rotation transform as a safeguard, even though
                // pieces will always be in the same orientation.
                return CGPathContainsPoint(shapeNode.path, nil, touch.locationInNode(shapeNode), false)
            } else {
                return false
            }
        }
        
        guard let node = nodes.first as? PieceNode else {
            return nil
        }
        
        return node
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        
        if let node = self.pieceAtPoint(touch!) {
            
            self.logicalBoard.rotatePiece(row: node.row!, col: node.col!)
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
    
    func pieceDidRotate(piece: Piece) {
        if let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] {
            node.zRotation = -CGFloat(Double(piece.absLogicalAngle).degrees)
        }
    }
    
    func piecePipeDidChangeState(piece: Piece, logicalDir: Direction, fromOldState oldState: PipeState) {
        guard let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] else {
            print("Unexpected error: piece not found in dictionary")
            return
        }
        
        let newState = piece.pipeState(forTrueDir: piece.trueDirForLogicalDir(logicalDir))!
        guard oldState != newState else {
            return
        }
        
        if oldState == .None {
            // New pipe is activated in some way
            let path = self.pipePaths[piece.type]!
            let pipe = SKShapeNode(path: path)
            
            switch newState {
            case .Disabled:
                pipe.fillColor = pipeOffColor
            case .Branch:
                fallthrough
            case .Source:
                pipe.fillColor = pipeOnColor
                
            default: break
            }
            
            pipe.strokeColor = pipeStrokeColor
            pipe.lineWidth = 0.0
            pipe.name = "Pipe \(logicalDir)"
            node.addChild(pipe)
            node.pipeNodes[logicalDir] = pipe
        
            pipe.runAction(SKAction.rotateToAngle(-CGFloat(Double(logicalDir.rawValue).degrees), duration: 0, shortestUnitArc: true))
        }
    
        else if newState == .None {
            // Remove the pipe from the node
            // (shouldn't really ever happen)
            
            let pipe: SKShapeNode = node.pipeNodes[logicalDir]!
            node.removeChildrenInArray([pipe])
            pipe.removeFromParent()
            node.pipeNodes.removeValueForKey(logicalDir)
        }
        
        else {
            // Pipe is changing between
            // Disabled, Branch, and Source
            // So just change color
            
            let pipe: SKShapeNode = node.pipeNodes[logicalDir]!
            switch newState {
            case .Disabled:
                pipe.fillColor = pipeOffColor
            case .Branch:
                fallthrough
            case .Source:
                pipe.fillColor = pipeOnColor
                
            default: break
            }
        }
        
        
        // Now for miscellaneous stuff to handle
        // Root marker
        if self.logicalBoard.pieceIsRoot(piece) && node.rootMarker == nil {
            let pipe = node.pipeNodes[logicalDir]!

            let rootMarker = SKShapeNode(path: self.shapePaths[piece.type]!)
            let pipeWidth = pipe.frame.size.width
            rootMarker.runAction(SKAction.scaleTo(0.9 * (pipeWidth / node.frame.size.width), duration: 0))
            rootMarker.fillColor = baseColor
            rootMarker.strokeColor = UIColor.clearColor()
            rootMarker.lineWidth = 0.0
            node.addChild(rootMarker)
        }
        
        if node.pipeNodes.count == 1 {
            let pipe: SKShapeNode = node.pipeNodes[logicalDir]!
            if node.bubble == nil {
                let bubble = SKShapeNode(circleOfRadius: pipe.frame.size.width * 0.5 * 1.3)
                bubble.strokeColor = UIColor.clearColor()
                bubble.lineWidth = 0.0
                node.bubble = bubble
            }
            node.bubble?.fillColor = pipe.fillColor
            
            node.bubble!.removeFromParent()
            node.addChild(node.bubble!)
        } else if node.bubble != nil {
            node.bubble?.removeFromParent()
        }
        
    }
}
