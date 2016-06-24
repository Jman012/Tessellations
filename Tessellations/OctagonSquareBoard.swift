//
//  OctagonSquareBoard.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

enum PieceType {
    case Octagon
    case Square
}

enum Direction: UInt {
    case North     = 0
    case NorthEast = 1
    case East      = 2
    case SouthEast = 3
    case South     = 4
    case SouthWest = 5
    case West      = 6
    case NorthWest = 7
    
    func opposite() -> Direction {
        return Direction(rawValue: (self.rawValue + 4) % 8)!
    }
}

protocol OctSquareBoardProtocol {
    func pieceDidChange(piece: Piece)
    func pieceDidRotate(piece: Piece)
    func boardDidClear()
}

struct Piece {
    var row: Int
    var col: Int
    var type: PieceType
    var pipeBits: UInt8
    var absLogicalAngle: UInt
}

class OctSquareBoard: NSObject {
    
    private var octWidth: UInt
    private var octHeight: UInt
    
    
    private var octagons: [[UInt8]]
    private var squares: [[UInt8]]
    private var logicalOctagonAngles: [[UInt]]
    private var logicalSquareAngles: [[UInt]]
    var delegate: OctSquareBoardProtocol?
    
    init(octagonsWide octWidth: UInt, octagonsTall octHeight: UInt) {
        
        guard octWidth >= 1 && octHeight >= 1 else {
            exit(1)
        }
        
        self.octWidth = octWidth
        self.octHeight = octHeight
        
        // Initialize the two tables of pieces, squares being one less in both directions
        octagons = Array<Array<UInt8>>(count: Int(octHeight), repeatedValue: Array<UInt8>(count: Int(octWidth), repeatedValue: 0))
        squares = Array<Array<UInt8>>(count: Int(octHeight - 1), repeatedValue: Array<UInt8>(count: Int(octWidth - 1), repeatedValue: 0))
        
        logicalOctagonAngles = Array<Array<UInt>>(count: Int(octHeight), repeatedValue: Array<UInt>(count: Int(octWidth), repeatedValue: 0))
        logicalSquareAngles = Array<Array<UInt>>(count: Int(octHeight - 1), repeatedValue: Array<UInt>(count: Int(octWidth - 1), repeatedValue: 0))
    }
    
    func pRowColIsLegalOfType(type: PieceType, pRow: Int, pCol: Int) -> Bool {
        switch type {
        case .Octagon:
            return pRow < Int(self.octHeight) && pRow >= 0 && pCol < Int(self.octWidth) && pCol >= 0
        case .Square:
            return pRow < Int(self.octHeight-1) && pRow >= 0 && pCol < Int(self.octWidth-1) && pCol >= 0
        }
    }
    
    func logicalRowColToPhysical(row row: Int, col: Int) -> (pieceType: PieceType, pRow: Int, pCol: Int)? {
        if row % 2 == 0 && col % 2 == 0 {
            return (.Octagon, row / 2, col / 2)
        } else if row % 2 == 1 && col % 2 == 1 {
            return (.Square, (row - 1) / 2, (col - 1) / 2)
        } else {
            return nil
        }
    }
    
    func physicalRowColToLogical(row row: Int, col: Int, pieceType: PieceType) -> (row: Int, col: Int) {
        switch pieceType {
        case .Octagon:
            return (row * 2, col * 2)
        case .Square:
            return (row * 2 + 1, col * 2 + 1)
        }
    }
    
    func getPiece(row row: Int, col: Int) -> Piece? {
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col)
            where self.pRowColIsLegalOfType(pieceType, pRow: pRow, pCol: pCol) {
            
            switch pieceType {
            case .Octagon:
                return Piece(row: row, col: col, type: .Octagon, pipeBits: self.octagons[pRow][pCol], absLogicalAngle: self.getPieceAngle(row: row, col: col)!)
            case .Square:
                return Piece(row: row, col: col, type: .Square, pipeBits: self.squares[pRow][pCol], absLogicalAngle: self.getPieceAngle(row: row, col: col)!)
            }
        } else {
            return nil
        }
    }
    
    func getPieceAngle(row row: Int, col: Int) -> UInt? {
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col)
            where self.pRowColIsLegalOfType(pieceType, pRow: pRow, pCol: pCol) {
            
            switch pieceType {
            case .Octagon:
                return self.logicalOctagonAngles[pRow][pCol]
            case .Square:
                return self.logicalSquareAngles[pRow][pCol]
            }
        } else {
            return nil
        }
    }
    
    func setPiecePipeBits(row row: Int, col: Int, pipeBits: UInt8) -> Bool {
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col)
            where self.pRowColIsLegalOfType(pieceType, pRow: pRow, pCol: pCol) {
            
            let absLogicalAngle: UInt
            switch pieceType {
            case .Octagon:
                octagons[pRow][pCol] = pipeBits
                absLogicalAngle = logicalOctagonAngles[pRow][pCol]
            case .Square:
                squares[pRow][pCol] = pipeBits
                absLogicalAngle = logicalSquareAngles[pRow][pCol]
            }
            
            if let del = self.delegate {
                del.pieceDidChange(Piece(row: row, col: col, type: pieceType, pipeBits: pipeBits, absLogicalAngle: absLogicalAngle))
            }
        } else {
            // Bad logical address
            print("Bad logical address: row=\(row), col=\(col). Exiting.")
            return false
        }
        
        return true
    }
    
    func getPieceNSEW(row row: Int, col: Int, direction: Direction) -> Piece? {
        var row = row, col = col
        switch direction {
        case .North:
            row = row - 2
        case .South:
            row = row + 2
        case .East:
            col = col + 2
        case .West:
            col = col - 2
        case .NorthEast:
            row = row - 1
            col = col + 1
        case .NorthWest:
            row = row - 1
            col = col - 1
        case .SouthEast:
            row = row + 1
            col = col + 1
        case .SouthWest:
            row = row + 1
            col = col - 1
        }
        
        return self.getPiece(row: row, col: col)
    }
    
    func setPipeDirection(row row: Int, col: Int, direction: Direction, set: Bool) -> Bool {
        guard let piece = self.getPiece(row: row, col: col) else {
            return false
        }
        
        
        if piece.type == .Square && (direction == .North || direction == .South ||
            direction == .East || direction == .West) {
            print("Trying to set invalid direction for square piece")
            return false
        }
        
        let newPipeBits: UInt8
        if set {
            newPipeBits = piece.pipeBits | UInt8(1 << direction.rawValue)
        } else {
            newPipeBits = piece.pipeBits & ~UInt8(1 << direction.rawValue)
        }
        
        // This will call the delegate for us
        self.setPiecePipeBits(row: row, col: col, pipeBits: newPipeBits)
        
        return true
    }
    
    func rotatePiece(row row: Int, col: Int) -> Bool {
        guard let piece = self.getPiece(row: row, col: col) else {
            return false
        }
        
        let (_, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col)!
        
        switch piece.type {
        case .Octagon:
            self.logicalOctagonAngles[pRow][pCol] = (self.logicalOctagonAngles[pRow][pCol] + 1) % 8
            if let del = self.delegate {
                del.pieceDidRotate(Piece(row: row, col: col, type: .Octagon, pipeBits: piece.pipeBits, absLogicalAngle: self.logicalOctagonAngles[pRow][pCol]))
            }
        case .Square:
            self.logicalSquareAngles[pRow][pCol] = (self.logicalSquareAngles[pRow][pCol] + 2) % 8
            if let del = self.delegate {
                del.pieceDidRotate(Piece(row: row, col: col, type: .Square, pipeBits: piece.pipeBits, absLogicalAngle: self.logicalSquareAngles[pRow][pCol]))
            }
            
        }
        
        return true
    }
    
    func forAllPieces(callback: (piece: Piece) -> Void) {
        for (pRow, rows) in self.octagons.enumerate() {
            for (pCol, pipeBits) in rows.enumerate() {
                let (lRow, lCol) = self.physicalRowColToLogical(row: pRow, col: pCol, pieceType: .Octagon)
                callback(piece: Piece(row: lRow, col: lCol, type: .Octagon, pipeBits: pipeBits, absLogicalAngle: self.getPieceAngle(row: lRow, col: lCol)!))
            }
        }
        
        for (pRow, rows) in self.squares.enumerate() {
            for (pCol, pipeBits) in rows.enumerate() {
                let (lRow, lCol) = self.physicalRowColToLogical(row: pRow, col: pCol, pieceType: .Square)
                callback(piece: Piece(row: lRow, col: lCol, type: .Square, pipeBits: pipeBits, absLogicalAngle: self.getPieceAngle(row: lRow, col: lCol)!))
            }
        }
    }
    
    func clearBoard() {
        octagons = Array<Array<UInt8>>(count: Int(self.octHeight), repeatedValue: Array<UInt8>(count: Int(self.octWidth), repeatedValue: 0))
        squares = Array<Array<UInt8>>(count: Int(self.octHeight - 1), repeatedValue: Array<UInt8>(count: Int(self.octWidth - 1), repeatedValue: 0))
        
        logicalOctagonAngles = Array<Array<UInt>>(count: Int(self.octHeight), repeatedValue: Array<UInt>(count: Int(self.octWidth), repeatedValue: 0))
        logicalSquareAngles = Array<Array<UInt>>(count: Int(self.octHeight - 1), repeatedValue: Array<UInt>(count: Int(self.octWidth - 1), repeatedValue: 0))
        
        if let del = self.delegate {
            del.boardDidClear()
        }
    }
    
    func randomizeBoard() {
        self.forAllPieces {
            piece in
            
            let numRots = random() % 8
            for _ in 0..<numRots {
                self.rotatePiece(row: piece.row, col: piece.col)
            }
        }
    }
    
    var hakRow: Int = 0
    var hakCol: Int = 0
    var hakRunning: Bool = false
}

extension OctSquareBoard {

    
    func generateHuntAndKill() {
        // Reset and start algorithm
        if hakRunning == false {
            print("Starting Hunt and Kill")
            self.clearBoard()
            hakRow = 0
            hakCol = 0
            hakRunning = true
        }
        
        if let _ = self.getPiece(row: hakRow, col: hakCol) where hakRunning == true {
            // Run the algorithm
            let neighbors = self.freeNeighbors(row: hakRow, col: hakCol)
            
            if neighbors.count > 0 {
                let neighborDir = neighbors.randomItem()
                let neighbor = self.getPieceNSEW(row: hakRow, col: hakCol, direction: neighborDir)!
                print("On r=\(hakRow),c=\(hakCol). Going \(neighborDir.rawValue)")
                
                self.setPipeDirection(row: hakRow, col: hakCol, direction: neighborDir, set: true)
                self.setPipeDirection(row: neighbor.row, col: neighbor.col, direction: neighborDir.opposite(), set: true)
                
                hakRow = neighbor.row
                hakCol = neighbor.col
                print("    Now, r=\(hakRow),c=\(hakCol)")
                
//                self.performSelector(#selector(self.generateHuntAndKill), withObject: nil, afterDelay: 0.3)
                self.generateHuntAndKill()

            } else if let (row, col) = hunt() {
                print("No neighbors, hunted new target: r=\(row),c=\(col)")
                
                let neighborDir = self.adjacentNeighbors(row: row, col: col).randomItem()
                let neighbor = self.getPieceNSEW(row: row, col: col, direction: neighborDir)!
                
                self.setPipeDirection(row: row, col: col, direction: neighborDir, set: true)
                self.setPipeDirection(row: neighbor.row, col: neighbor.col, direction: neighborDir.opposite(), set: true)
                
                hakRow = row
                hakCol = col
                self.performSelector(#selector(self.generateHuntAndKill), withObject: nil, afterDelay: 1.0)
            } else {
                print("On r=\(hakRow),c=\(hakCol). No neighbors. Hunt failed. Stopping.")
                hakRunning = false
            }

        } else {
            // Stop the algorithm
            print("Error")
            hakRunning = false
        }
    }
    
    func adjacentNeighbors(row row: Int, col: Int) -> [Direction] {
        let piece = self.getPiece(row: row, col: col)
        let dirs: [Direction]
        if piece?.type == .Square {
            dirs = [.NorthEast, .NorthWest, .SouthEast, .SouthWest]
        } else {
            dirs = [.North, .NorthEast, .NorthWest, .South, .SouthEast, .SouthWest, .East, .West]
        }
        return dirs.filter {
            if let piece = self.getPieceNSEW(row: row, col: col, direction: $0) {
                return piece.pipeBits > 0
            } else {
                return false
            }
        }

    }
    
    func freeNeighbors(row row: Int, col: Int) -> [Direction] {
        let piece = self.getPiece(row: row, col: col)
        let dirs: [Direction]
        if piece?.type == .Square {
            dirs = [.NorthEast, .NorthWest, .SouthEast, .SouthWest]
        } else {
            dirs = [.North, .NorthEast, .NorthWest, .South, .SouthEast, .SouthWest, .East, .West]
        }
        return dirs.filter {
            if let piece = self.getPieceNSEW(row: row, col: col, direction: $0) {
                return piece.pipeBits == 0
            } else {
                return false
            }
        }
    }
    
    func hunt() -> (row: Int, col: Int)? {
        var row: Int = -1
        var col: Int = -1
        self.forAllPieces {
            piece in
            
            if piece.pipeBits == 0 && self.adjacentNeighbors(row: piece.row, col: piece.col).count > 0 {
                (row, col) = (piece.row, piece.col)
                return
            }
        }
        
        if row != -1 && col != -1 {
            return (row, col)
        } else {
            return nil
        }
    }
    
}

