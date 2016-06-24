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
    
    func logicalRowColToPhysical(row row: Int, col: Int) -> (pieceType: PieceType, pRow: Int, pCol: Int)? {
        if row % 2 == 0 && col % 2 == 0 && row/2 < Int(self.octHeight) && col/2 < Int(self.octWidth) {
            return (.Octagon, row / 2, col / 2)
        } else if row % 2 == 1 && col % 2 == 1 && (row-1)/2 < Int(self.octHeight) && (col-1)/2 < Int(self.octWidth) {
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
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col) {
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
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col) {
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
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col) {
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
    
    var hakRow: Int = 0
    var hakCol: Int = 0
    var hakRunning: Bool = false
    func generateHuntAndKill() {
        if hakRunning == false {
            self.clearBoard()
            hakRow = 0
            hakCol = 0
            hakRunning = true
        }
        
        if let _ = self.getPiece(row: hakRow, col: hakCol) where hakRunning == true {
            self.setPipeDirection(row: hakRow, col: hakCol, direction: .South, set: true)
            hakCol = hakCol + 2
            self.performSelector(#selector(self.generateHuntAndKill), withObject: nil, afterDelay: 0.5)
        } else {
            hakRunning = false
        }
    }
    
}

