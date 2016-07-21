//
//  TriangleBoard.swift
//  Tessellations
//
//  Created by James Linnell on 7/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class TriangleBoard: AbstractGameBoard {

    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                if row % 2 == col % 2 {
                    let piece = Piece(row: row, col: col, type: .TriangleDown)
                    board[row].append(piece)
                } else {
                    let piece = Piece(row: row, col: col, type: .TriangleUp)
                    board[row].append(piece)
                }
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
        case .NorthEastEast:
            rowCol.col = rowCol.col + 1
        case .SouthEastEast:
            rowCol.col = rowCol.col + 1
        case .South:
            rowCol.row = rowCol.row + 1
        case .NorthWestWest:
            rowCol.col = rowCol.col - 1
        case .SouthWestWest:
            rowCol.col = rowCol.col - 1
        default:
            return nil
        }
        
        return rowCol
    }
}
