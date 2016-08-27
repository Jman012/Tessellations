//
//  PieceNode.swift
//  Tessellations
//
//  Created by James Linnell on 8/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class PieceNode: SKSpriteNode {
    
    let pieceType: PieceType
    var row: Int
    var col: Int

    var pipeNodes: [Direction: PipeNode] = [:]
    var bubble: SKShapeNode?
    var rootMarker: SKShapeNode?
    
    weak var abstractScene: AbstractGameBoardScene?
    var pipeEnabledTexture: SKTexture {
        get { return abstractScene!.pipeTexturesEnabled[self.pieceType]! }
    }
    var pipeDisabledTexture: SKTexture {
        get { return abstractScene!.pipeTexturesDisabled[self.pieceType]! }
    }
    var pipeNodePool: Pool<PipeNode> {
        get { return abstractScene!.pipeNodePool[self.pieceType]! }
    }
    
    
    
    init(texture: SKTexture, type: PieceType, row: Int, col: Int) {
        self.pieceType = type
        self.row = row
        self.col = col
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPipeState(state: PipeState, forLogicalDirection logicalDirection: Direction) {
        // 1. Remove anything there first and foremost
        self.removePipe(forDirection: logicalDirection)
        
        if state != .None {
            // And if the desired state is something
            let enabled = (state == .Branch || state == .Source)
            
            // Then add a pipe back from the pool
            let newPipeNode = self.getNewPipeNode()
            self.addPipe(newPipeNode, forLogicalDirection: logicalDirection, enabled: enabled)
        }
    }
    
    func rotateToDegrees(degrees: CGFloat) {
        for (direction, pipeNode) in self.pipeNodes {
            self.zRotation = degrees
            pipeNode.zRotation = self.zRotation - CGFloat(Double(direction.rawValue).degrees)
        }
    }
    
    
    
    private func getNewPipeNode() -> PipeNode {
        
        if let poolNode = pipeNodePool.getItem() {
            // Got node from Pool
            return poolNode
        } else {
            // Make new pipe node
            return PipeNode()
        }
    }
    
    private func addPipe(pipeNode: PipeNode, forLogicalDirection logicalDirection: Direction, enabled: Bool) {
        
        /* Just in case */
        self.removePipe(forDirection: logicalDirection)
        
        
        /* Set pipeNode data */
        pipeNode.row = self.row
        pipeNode.col = self.col
        pipeNode.logicalDirection = logicalDirection
        pipeNode.enabled = enabled
        
        pipeNode.name = "\(self.pieceType) Pipe pointing \(logicalDirection)"
        pipeNode.position = self.position
        pipeNode.zRotation = self.zRotation - CGFloat(Double(logicalDirection.rawValue).degrees)
        if enabled {
            pipeNode.texture = pipeEnabledTexture
        } else {
            pipeNode.texture = pipeDisabledTexture
        }
        pipeNode.size = pipeNode.texture!.size()
        
        
        /* Add to structures */
        self.pipeNodes[logicalDirection] = pipeNode
        abstractScene!.pipeTree.addChild(pipeNode)
    }
    
    private func removePipe(forDirection logicalDirection: Direction) {
        if let pipeNode = self.pipeNodes[logicalDirection] {
            
            // Make sure to detach it from everything
            pipeNode.removeFromParent()
            
            self.pipeNodes.removeValueForKey(pipeNode.logicalDirection)
            
            // Then submit it back to the pool
            pipeNodePool.giveItem(pipeNode)
        }
        
        // Else, already removed. No work to do.
    }

}
