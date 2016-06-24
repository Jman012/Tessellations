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
}

struct Piece {
    var row: Int
    var col: Int
    var type: PieceType
    var pipeBits: UInt8
    var absLogicalAngle: UInt
}

class OctSquareBoard {
    
    private var octagons: [[UInt8]]
    private var squares: [[UInt8]]
    private var logicalOctagonAngles: [[UInt]]
    private var logicalSquareAngles: [[UInt]]
    var delegate: OctSquareBoardProtocol?
    
    init(octagonsWide octWidth: Int, octagonsTall octHeight: Int) {
        
        // Initialize the two tables of pieces, squares being one less in both directions
        octagons = Array<Array<UInt8>>(count: octHeight, repeatedValue: Array<UInt8>(count: octWidth, repeatedValue: 0))
        squares = Array<Array<UInt8>>(count: octHeight - 1, repeatedValue: Array<UInt8>(count: octWidth - 1, repeatedValue: 0))
        
        logicalOctagonAngles = Array<Array<UInt>>(count: octHeight, repeatedValue: Array<UInt>(count: octWidth, repeatedValue: 0))
        logicalSquareAngles = Array<Array<UInt>>(count: octHeight - 1, repeatedValue: Array<UInt>(count: octWidth - 1, repeatedValue: 0))
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
    
    func getPiece(row row: Int, col: Int) -> (pRow: Int, pCol: Int, PieceType, UInt8)? {
        if let (pieceType, pRow, pCol) = self.logicalRowColToPhysical(row: row, col: col) {
            switch pieceType {
            case .Octagon:
                return (pRow, pCol, .Octagon, self.octagons[pRow][pCol])
            case .Square:
                return (pRow, pCol, .Square, self.squares[pRow][pCol])
            }
        } else {
            // Bad logical address
            print("Bad logical address: row=\(row), col=\(col). Exiting.")
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
                del.pieceDidChange(Piece(row: row, col: col, type: .Square, pipeBits: pipeBits, absLogicalAngle: absLogicalAngle))
            }
        } else {
            // Bad logical address
            print("Bad logical address: row=\(row), col=\(col). Exiting.")
            return false
        }
        
        return true
    }
    
    func getPieceNSEW(row row: Int, col: Int, direction: Direction) -> (PieceType, UInt8, row: Int, col: Int)? {
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
        
        if let (_, _, pieceType, pipeBits) = self.getPiece(row: row, col: col) {
            return (pieceType, pipeBits, row, col)
        } else {
            return nil
        }
    }
    
    func setPipeDirection(row row: Int, col: Int, direction: Direction, set: Bool) -> Bool {
        guard let (_, _, pieceType, pipeBits) = self.getPiece(row: row, col: col) else {
            return false
        }
        
        
        if pieceType == .Square && (direction == .North || direction == .South ||
            direction == .East || direction == .West) {
            print("Trying to set invalid direction for square piece")
            return false
        }
        
        let newPipeBits: UInt8
        if set {
            newPipeBits = pipeBits | UInt8(1 << direction.rawValue)
        } else {
            newPipeBits = pipeBits & ~UInt8(1 << direction.rawValue)
        }
        
        self.setPiecePipeBits(row: row, col: col, pipeBits: newPipeBits)
        
        if let del = self.delegate {
            del.pieceDidChange(Piece(row: row, col: col, type: pieceType, pipeBits: pipeBits, absLogicalAngle: 0))
        }
        
        return true
    }
    
    func rotatePiece(row row: Int, col: Int) -> Bool {
        guard let (pRow, pCol, pieceType, pipeBits) = self.getPiece(row: row, col: col) else {
            return false
        }
        
        switch pieceType {
        case .Octagon:
            self.logicalOctagonAngles[pRow][pCol] = (self.logicalOctagonAngles[pRow][pCol] + 1) % 8
            if let del = self.delegate {
                del.pieceDidRotate(Piece(row: row, col: col, type: .Octagon, pipeBits: pipeBits, absLogicalAngle: self.logicalOctagonAngles[pRow][pCol]))
            }
        case .Square:
            self.logicalSquareAngles[pRow][pCol] = (self.logicalSquareAngles[pRow][pCol] + 2) % 8
            if let del = self.delegate {
                del.pieceDidRotate(Piece(row: row, col: col, type: .Square, pipeBits: pipeBits, absLogicalAngle: self.logicalSquareAngles[pRow][pCol]))
            }
            
        }
        
        return true
    }
    
    func forAllPieces(callback: (row: Int, col: Int, pieceType: PieceType, pipeBits: UInt8) -> Void) {
        for (pRow, rows) in self.octagons.enumerate() {
            for (pCol, pipeBits) in rows.enumerate() {
                let (lRow, lCol) = self.physicalRowColToLogical(row: pRow, col: pCol, pieceType: .Octagon)
                callback(row: lRow, col: lCol, pieceType: .Octagon, pipeBits: pipeBits)
            }
        }
        
        for (pRow, rows) in self.squares.enumerate() {
            for (pCol, pipeBits) in rows.enumerate() {
                let (lRow, lCol) = self.physicalRowColToLogical(row: pRow, col: pCol, pieceType: .Square)
                callback(row: lRow, col: lCol, pieceType: .Square, pipeBits: pipeBits)
            }
        }
    }
    
}

