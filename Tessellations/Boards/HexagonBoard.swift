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
                if col % 2 == 0 && row + 1 == boardHeight {
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
            rowCol.row = rowCol.row - 1
        case .South:
            rowCol.row = rowCol.row + 1
        case .NorthEastEast:
            if piece.col % 2 == 0 {
                rowCol.row = rowCol.row + 0
                rowCol.col = rowCol.col + 1
            } else {
                rowCol.row = rowCol.row - 1
                rowCol.col = rowCol.col + 1
            }
        case .SouthEastEast:
            if piece.col % 2 == 0 {
                rowCol.row = rowCol.row + 1
                rowCol.col = rowCol.col + 1
            } else {
                rowCol.row = rowCol.row + 0
                rowCol.col = rowCol.col + 1
            }
        case .NorthWestWest:
            if piece.col % 2 == 0 {
                rowCol.row = rowCol.row + 0
                rowCol.col = rowCol.col - 1
            } else {
                rowCol.row = rowCol.row - 1
                rowCol.col = rowCol.col - 1
            }
        case .SouthWestWest:
            if piece.col % 2 == 0 {
                rowCol.row = rowCol.row + 1
                rowCol.col = rowCol.col - 1
            } else {
                rowCol.row = rowCol.row + 0
                rowCol.col = rowCol.col - 1
            }
        default:
            return nil
        }
        
        return rowCol
    }
}
