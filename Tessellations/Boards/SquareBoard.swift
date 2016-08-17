//
//  SquareBoard.swift
//  Tessellations
//
//  Created by James Linnell on 7/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class SquareBoard: AbstractGameBoard {

    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                let piece = Piece(row: row, col: col, type: .Square)
                board[row].append(piece)
            }
        }
    }
    
    override func adjacentPieceDisplacement(piece piece: Piece, direction: Direction) -> RowCol? {
        guard piece.legalDirections.contains(direction) else {
            print("Invalid direction \(direction) for piece \(piece) for displacement.")
            return nil
        }
        
        var rowCol = RowCol(row: 0, col: 0)
        
        switch direction {
        case .North:
            rowCol.row = rowCol.row - 1
        case .East:
            rowCol.col = rowCol.col + 1
        case .South:
            rowCol.row = rowCol.row + 1
        case .West:
            rowCol.col = rowCol.col - 1
        default:
            return nil
        }
        
        return rowCol
    }
}
