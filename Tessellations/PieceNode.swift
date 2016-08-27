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
    var bubble: SKSpriteNode!
    var rootMarker: SKSpriteNode!
    
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
    var bubbleEnabledTexture: SKTexture {
        get { return abstractScene!.bubbleEnabledTexture! }
    }
    var bubbleDisabledTexture: SKTexture {
        get { return abstractScene!.bubbleDisabledTexture! }
    }
    var bubbleNodePool: Pool<SKSpriteNode> {
        get { return abstractScene!.bubbleNodePool }
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
        
        if self.pipeNodes.count == 1 {
            // If there's only one pipe
            if self.bubble == nil {
                // Make sure we have a bubble node on us and in the tree
                self.bubble = self.getNewBubbleNode()
                abstractScene?.pipeTree.addChild(self.bubble)
            }
            
            let (_, singlePipe) = self.pipeNodes.first!
            if singlePipe.enabled {
                bubble.texture = bubbleEnabledTexture
            } else {
                bubble.texture = bubbleDisabledTexture
            }
            bubble.size = bubble.texture!.size()
            bubble.position = self.position
            bubble.zPosition = 2
            bubble.name = "Bubble \(row, col) \(singlePipe.enabled)"
            
        } else {
            if self.bubble != nil {
                abstractScene?.pipeTree.removeChildrenInArray([self.bubble])
                bubbleNodePool.giveItem(self.bubble)
                self.bubble = nil
            }
        }
    }
    
    func rotateToDegrees(degrees: CGFloat) {
        for (direction, pipeNode) in self.pipeNodes {
            self.zRotation = degrees
            pipeNode.zRotation = self.zRotation - CGFloat(Double(direction.rawValue).degrees)
        }
    }
    
    
    
    private func getNewBubbleNode() -> SKSpriteNode {
        if let bubbleNode = bubbleNodePool.getItem() {
            // Got node from Pool
            return bubbleNode
        } else {
            // Make new pipe node
            return SKSpriteNode()
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
        pipeNode.zPosition = 2
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
