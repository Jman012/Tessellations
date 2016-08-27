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
//let pathStrokeColor = UIColor.whiteColor()
let pathStrokeColor = UIColor.clearColor()
let pipeStrokeColor = UIColor.clearColor()
let pipeOnColor =     UIColor(colorLiteralRed: 0.502, green: 0.322, blue: 0.082, alpha: 1.0)
let pipeOffColor =    UIColor(colorLiteralRed: 0.667, green: 0.475, blue: 0.224, alpha: 1.0)


protocol GameBoardSceneProtocol: class {
    func gameWon()
}

class AbstractGameBoardScene: SKScene, AbstractGameBoardProtocol {
    
    weak var del: GameBoardSceneProtocol?
    
    var logicalBoardWidth = 1
    var logicalBoardHeight = 1
    
    var margins = CGSize(width: 20, height: 44.0)
    var effectiveWidth: CGFloat {
        get { return size.width - margins.width*2 }
    }
    var effectiveHeight: CGFloat {
        get { return size.height - margins.height*2 }
    }
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    var shapePaths: [PieceType: CGPath] = [:]
    var pipePaths: [PieceType: CGPath] = [:]
    
    var shapeTextures: [PieceType: SKTexture] = [:]
    var pipeTexturesEnabled: [PieceType: SKTexture] = [:]
    var pipeTexturesDisabled: [PieceType: SKTexture] = [:]
    var bubbleEnabledTexture: SKTexture?
    var bubbleDisabledTexture: SKTexture?
    
    var pipeNodePool: [PieceType: Pool<PipeNode>] = [:]
    var bubbleNodePool = Pool<SKSpriteNode>()
    
    var rowColToNode: [RowCol: PieceNode] = [:]
    let pieceTree = SKNode()
    let pipeTree = SKNode()
    let rootMarkerTree = SKNode()
    let rootMarker = SKShapeNode()
    var currentBoardPipeWidth: CGFloat = 0.0
    
    var logicalBoard: AbstractGameBoard!
    
    required init(size: CGSize, boardWidth: Int, boardHeight: Int, margins: Bool) {
        
        super.init(size: size)
        
        pieceTree.zPosition = 1
        self.addChild(pieceTree)
        pipeTree.zPosition = 2
        self.addChild(pipeTree)
        rootMarkerTree.zPosition = 3
        self.addChild(rootMarkerTree)
        
        rootMarker.fillColor = baseColor
        rootMarker.strokeColor = baseColor
        rootMarker.lineWidth = 1.0
        rootMarker.name = "Root Marker"
        rootMarker.zPosition = 4
        
        logicalBoardWidth = boardWidth
        logicalBoardHeight = boardHeight
        if !margins {
            self.margins = CGSizeZero
        }
        
        self.logicalBoard = self.initLogicalBoard()
        self.logicalBoard.delegate = self
        self.setShapePaths()
        self.constructTextures()
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
    
    class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        /* Override this */
        return nil
    }
    
    class func thumbnail(size: CGSize) -> UIImage? {
        guard let scene = self.thumbnailScene(size) else {
            return nil
        }
        
        let skView = SKView(frame: CGRect(origin: CGPointZero, size: size))
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
        
        let window = UIApplication.sharedApplication().delegate!.window!
        window!.addSubview(skView)
        window!.sendSubviewToBack(skView)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        skView.drawViewHierarchyInRect(skView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        skView.removeFromSuperview()
        
        return image
    }
    
    func constructTextures() {
        let skView = SKView()
        let shapeNode = SKShapeNode()
        shapeNode.fillColor = baseColor
        shapeNode.strokeColor = baseColor
        shapeNode.lineWidth = 1.0
        
        
        // Shape
        for (pieceType, path) in self.shapePaths {
            shapeNode.path = path
//            print("For pieceType \(pieceType), frame=\(shapeNode.frame)")
            let largerSide: CGFloat
            if shapeNode.frame.width > shapeNode.frame.height {
                largerSide = shapeNode.frame.width
//                print("Using width")
            } else {
                largerSide = shapeNode.frame.height
//                print("Using height")
            }
            
            let texture = skView.textureFromNode(shapeNode, crop:
                CGRect(origin: CGPoint(x: -largerSide/2, y: -largerSide/2),
                       size:   CGSize(width: largerSide, height: largerSide)))
            self.shapeTextures[pieceType] = texture
            
            self.pipeNodePool[pieceType] = Pool<PipeNode>()
        }
        
        // Pipe Enabled
        shapeNode.fillColor = pipeOnColor
        shapeNode.strokeColor = pipeOnColor
        
        for (pieceType, path) in self.pipePaths {
            shapeNode.path = path
            let pieceShapeSize = self.shapeTextures[pieceType]!.size()
            let texture = skView.textureFromNode(shapeNode, crop: CGRect(origin: CGPoint(x: -pieceShapeSize.width/2, y: -pieceShapeSize.height/2), size: pieceShapeSize))
            self.pipeTexturesEnabled[pieceType] = texture
            
            currentBoardPipeWidth = shapeNode.frame.width
            
        }
        
        // Pipe Disabled
        shapeNode.fillColor = pipeOffColor
        shapeNode.strokeColor = pipeOffColor
        
        for (pieceType, path) in self.pipePaths {
            shapeNode.path = path
            let pieceShapeSize = self.shapeTextures[pieceType]!.size()
            let texture = skView.textureFromNode(shapeNode, crop: CGRect(origin: CGPoint(x: -pieceShapeSize.width/2, y: -pieceShapeSize.height/2), size: pieceShapeSize))
            self.pipeTexturesDisabled[pieceType] = texture
        }
        
        // Bubble
        let bubble = SKShapeNode(circleOfRadius: currentBoardPipeWidth * 0.5 * 1.2)
        bubble.lineWidth = 1.0
        bubble.fillColor = pipeOnColor
        bubble.strokeColor = pipeOnColor
        bubbleEnabledTexture = skView.textureFromNode(bubble)
        bubble.fillColor = pipeOffColor
        bubble.strokeColor = pipeOffColor
        bubbleDisabledTexture = skView.textureFromNode(bubble)
    }
    
    func nodeForPiece(piece: Piece) -> PieceNode {
        let node = PieceNode(texture: self.shapeTextures[piece.type]!, type: piece.type, row: piece.row, col: piece.col)
        node.position = self.pieceToPoint(piece)
        
        node.abstractScene = self
        node.name = "\(piece.type) \(node.row, node.col)"
        node.zPosition = 1
        
        return node
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = bgColor
        
        self.refreshAllPieces()
    }
    
    func refreshAllPieces() {
        self.pieceTree.removeAllChildren()
        self.pipeTree.removeAllChildren()
        self.rootMarkerTree.removeAllChildren()
        
        self.logicalBoard.forAllPieces {
            (piece: Piece) in
            
            // To reduce repetition below
            let (row, col) = (piece.row, piece.col)
            
            let node = self.nodeForPiece(piece)
            self.pieceTree.addChild(node)
            self.rowColToNode[RowCol(row: row, col: col)] = node
            
            piece.forEachPipeState {
                trueDir, state in
                
                self.piecePipeDidChangeState(piece, logicalDir: piece.logicalDirForTrueDir(trueDir), fromOldState: .None)
            }
            
            self.pieceDidRotate(piece)
            
        }
    }
    
    func sceneSizeDidChange() {
        self.setShapePaths()
        self.constructTextures()
        self.refreshAllPieces()
    }
    
    func pieceAtPoint(location: CGPoint) -> PieceNode? {
        let nodes = self.nodesAtPoint(location).filter {
            theNode in
            if let node = theNode as? PieceNode {
                // TODO: Apply a rotation transform as a safeguard, even though
                // pieces will always be in the same orientation.
                let locationInNode = self.convertPoint(location, toNode: node)
                return CGPathContainsPoint(self.shapePaths[node.pieceType]!, nil, locationInNode, false)
            } else {
                return false
            }
        }
        
        guard let node = nodes.first as? PieceNode else {
            return nil
        }
        
        return node
    }
    
    func gotTapAtLocation(location: CGPoint) {
        let location = self.convertPointFromView(location)
        if let node = self.pieceAtPoint(location) {
            self.logicalBoard.rotatePiece(row: node.row, col: node.col)
        }
    }
    
    func gameWon() {
        if let del = self.del {
            del.gameWon()
        }
    }
    
    func boardDidClear() {
        for node in self.pieceTree.children {
            guard let pieceNode = node as? PieceNode else {
                continue
            }
            // Remove the pipes of each piece
            for (_, pipe) in pieceNode.pipeNodes {
                pipe.removeFromParent()
            }
            pieceNode.pipeNodes.removeAll()
            pieceNode.bubble = nil
            pieceNode.runAction(SKAction.rotateToAngle(0, duration: 0))
        }
    }
    
    func pieceDidRotate(piece: Piece) {
        if let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] {
            node.rotateToDegrees(-CGFloat(Double(piece.absAngle).degrees))
        }
    }
    
    func piecePipeDidChangeState(piece: Piece, logicalDir: Direction, fromOldState oldState: PipeState) {
        guard let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)] else {
            if self.view != nil {
                print("Unexpected error: piece not found in dictionary")
            }
            return
        }
        
        let newState = piece.pipeState(forTrueDir: piece.trueDirForLogicalDir(logicalDir))!
        
        node.setPipeState(newState, forLogicalDirection: logicalDir)
        
        
        if self.logicalBoard.pieceIsRoot(piece) {
            if rootMarker.parent == nil {
                rootMarkerTree.addChild(rootMarker)
            }
            
            let node = self.rowColToNode[RowCol(row: piece.row, col: piece.col)]!
            rootMarker.path = self.shapePaths[piece.type]!
            
            rootMarker.runAction(SKAction.scaleTo(0.5 * (currentBoardPipeWidth / node.frame.size.width), duration: 0))
            
            rootMarker.position = node.position
            rootMarker.zPosition = 4
        }
    }
}

