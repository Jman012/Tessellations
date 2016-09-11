//
//  GameBoardScene.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

//let bgColor =         UIColor.whiteColor()
//let baseColor =       UIColor(colorLiteralRed: 0.831, green: 0.655, blue: 0.416, alpha: 1.0)
//let baseColor =      UIColor.whiteColor()
//let secondaryColor =  UIColor(colorLiteralRed: 0.831, green: 0.655, blue: 0.416, alpha: 1.0)
//let pathStrokeColor = UIColor.whiteColor()
//let pathStrokeColor = UIColor.clearColor()
//let pipeStrokeColor = UIColor.clearColor()
//let pipeOnColor =     UIColor(colorLiteralRed: 0.502, green: 0.322, blue: 0.082, alpha: 1.0)
//let pipeOffColor =    UIColor(colorLiteralRed: 0.667, green: 0.475, blue: 0.224, alpha: 1.0)


enum BoardSize: Int {
    case Small = 0
    case Medium = 1
    case Large = 2
    case Huge = 3
    
    func text() -> String {
        switch self {
        case .Small: return "Small"
        case .Medium: return "Medium"
        case .Large: return "Large"
        case .Huge: return "Huge"
        }
    }
    
    static func count() -> Int {
        return 4
    }
}

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
    var gameIsWon = false
    
    required init(size: CGSize, boardSize: BoardSize, margins: Bool) {
        
        super.init(size: size)
        
        self.requiredInitialization(margins)
        
        self.logicalBoard = self.initLogicalBoard(boardSize: boardSize)
        
        self.logicalBoard.delegate = self
        self.setShapePaths()
        self.constructTextures()
    }
    
    init(size: CGSize, boardWidth: Int, boardHeight: Int, margins: Bool) {
        
        super.init(size: size)
        
        self.requiredInitialization(margins)
        
        self.logicalBoardWidth = boardWidth
        self.logicalBoardHeight = boardHeight
        self.logicalBoard = self.initLogicalBoard()
        
        self.logicalBoard.delegate = self
        self.setShapePaths()
        self.constructTextures()
    }
    
    func requiredInitialization(margins: Bool) {
        
        pieceTree.zPosition = 1
        self.addChild(pieceTree)
        pipeTree.zPosition = 2
        self.addChild(pipeTree)
        rootMarkerTree.zPosition = 3
        self.addChild(rootMarkerTree)
        
        rootMarker.fillColor = Singleton.shared.palette.piece
        rootMarker.strokeColor = Singleton.shared.palette.piece
        rootMarker.lineWidth = 1.0
        rootMarker.name = "Root Marker"
        rootMarker.zPosition = 4
        
        if !margins {
            self.margins = CGSizeZero
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        fatalError("initLogialBoard(boardSize:) has not been implemented")
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
    
    class func thumbnail(size: CGSize, addToView view: UIView, completion: ((image: UIImage) -> Void)) {
        guard let scene = self.thumbnailScene(size) else {
            fatalError("Couldn't get thumbnail scene of type \(self.self)")
        }
        
        let skView = SKView(frame: CGRect(origin: CGPointZero, size: size))
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
        
        dispatch_sync(dispatch_get_main_queue(), {
            view.addSubview(skView)
        })
        
//        let window = UIApplication.sharedApplication().delegate!.window!
//        window!.addSubview(skView)
//        window!.sendSubviewToBack(skView)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        skView.drawViewHierarchyInRect(skView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
//        skView.removeFromSuperview()
        
        completion(image: image)
        
//        return image
    }
    
    func constructTextures() {
        let skView = SKView()
        let shapeNode = SKShapeNode()
        shapeNode.fillColor = Singleton.shared.palette.piece
        shapeNode.strokeColor = Singleton.shared.palette.piece
        shapeNode.lineWidth = 1.0
        
        var zoomScale = CGAffineTransformMakeScale(1.0 + kCameraZoomIn, 1.0 + kCameraZoomIn)
        
        // Shape
        for (pieceType, path) in self.shapePaths {
            shapeNode.path = CGPathCreateCopyByTransformingPath(path, &zoomScale)

            let largerSide: CGFloat
            if shapeNode.frame.width > shapeNode.frame.height {
                largerSide = shapeNode.frame.width * 1.2
            } else {
                largerSide = shapeNode.frame.height * 1.2
            }
            
            let texture = skView.textureFromNode(shapeNode, crop:
                CGRect(origin: CGPoint(x: -largerSide/2, y: -largerSide/2),
                       size:   CGSize(width: largerSide, height: largerSide)))
            self.shapeTextures[pieceType] = texture
            
            self.pipeNodePool[pieceType] = Pool<PipeNode>()
        }
        
        // Pipe Enabled
        shapeNode.fillColor = Singleton.shared.palette.pipeEnabled
        shapeNode.strokeColor = Singleton.shared.palette.pipeEnabled
        
        for (pieceType, path) in self.pipePaths {
            shapeNode.path = CGPathCreateCopyByTransformingPath(path, &zoomScale)
            let pieceShapeSize = self.shapeTextures[pieceType]!.size()
            let texture = skView.textureFromNode(shapeNode, crop: CGRect(origin: CGPoint(x: -pieceShapeSize.width/2, y: -pieceShapeSize.height/2), size: pieceShapeSize))
            self.pipeTexturesEnabled[pieceType] = texture
            
            currentBoardPipeWidth = shapeNode.frame.width
            
        }
        
        // Pipe Disabled
        shapeNode.fillColor = Singleton.shared.palette.pipeDisabled
        shapeNode.strokeColor = Singleton.shared.palette.pipeDisabled
        
        for (pieceType, path) in self.pipePaths {
            shapeNode.path = CGPathCreateCopyByTransformingPath(path, &zoomScale)
            let pieceShapeSize = self.shapeTextures[pieceType]!.size()
            let texture = skView.textureFromNode(shapeNode, crop: CGRect(origin: CGPoint(x: -pieceShapeSize.width/2, y: -pieceShapeSize.height/2), size: pieceShapeSize))
            self.pipeTexturesDisabled[pieceType] = texture
        }
        
        // Bubble
        let bubble = SKShapeNode(circleOfRadius: currentBoardPipeWidth * 0.5 * 1.2 * kCameraZoomIn)
        bubble.lineWidth = 1.0
        bubble.fillColor = Singleton.shared.palette.pipeEnabled
        bubble.strokeColor = Singleton.shared.palette.pipeEnabled
        bubbleEnabledTexture = skView.textureFromNode(bubble)
        bubble.fillColor = Singleton.shared.palette.pipeDisabled
        bubble.strokeColor = Singleton.shared.palette.pipeDisabled
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
        
        if margins != CGSizeZero {
            self.backgroundColor = Singleton.shared.palette.background
        } else {
            self.backgroundColor = UIColor.clearColor()
        }
        
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
                
                var zoomScale = CGAffineTransformMakeScale(1.0 + kCameraZoomIn, 1.0 + kCameraZoomIn)
                let scaledPath = CGPathCreateCopyByTransformingPath(self.shapePaths[node.pieceType]!, &zoomScale)
                return CGPathContainsPoint(scaledPath, nil, locationInNode, false)
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
        guard gameIsWon == false else {
            return
        }
        
        let location = self.convertPointFromView(location)
        if let node = self.pieceAtPoint(location) {
            self.logicalBoard.rotatePiece(row: node.row, col: node.col)
        }
    }
    
    func gameWon() {
        gameIsWon = true
        if let del = self.del {
            del.gameWon()
        }
    }
    
    override func didFinishUpdate() {
        
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
            
            rootMarker.runAction(SKAction.scaleTo(kCameraZoomIn * 0.5 * (currentBoardPipeWidth / node.frame.size.width), duration: 0))
            
            rootMarker.position = node.position
            rootMarker.zPosition = 4
        }
    }
}

