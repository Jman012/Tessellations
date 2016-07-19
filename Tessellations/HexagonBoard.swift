//
//  HexagonBoard.swift
//  Tessellations
//
//  Created by James Linnell on 7/19/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class HexagonBoard: AbstractGameBoard {
    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                if col % 2 == 0 && row == 0 {
                    board[row].append(nil)
                } else {
                    let piece = Piece(row: row, col: col, type: .Hexagon)
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
            rowCol.row = rowCol.row - 2
            rowCol.col = rowCol.col + 0
        case .NorthEast:
            rowCol.row = rowCol.row - 1
            rowCol.col = rowCol.col + 1
        case .East:
            rowCol.row = rowCol.row + 0
            rowCol.col = rowCol.col + 2
        case .SouthEast:
            rowCol.row = rowCol.row + 1
            rowCol.col = rowCol.col + 1
        case .South:
            rowCol.row = rowCol.row + 2
            rowCol.col = rowCol.col + 0
        case .SouthWest:
            rowCol.row = rowCol.row + 1
            rowCol.col = rowCol.col - 1
        case .West:
            rowCol.row = rowCol.row + 0
            rowCol.col = rowCol.col - 2
        case .NorthWest:
            rowCol.row = rowCol.row - 1
            rowCol.col = rowCol.col - 1
        default:
            return nil
        }
        
        return rowCol
    }
}
