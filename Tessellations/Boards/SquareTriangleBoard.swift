//
//  SquareTriangleBoard.swift
//  Tessellations
//
//  Created by James Linnell on 8/27/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class SquareTriangleBoard: AbstractGameBoard {
    
    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                
                let mRow = row % 4
                let mCol = col % 4
                
                let type: PieceType?
                if        (mRow, mCol) == (0, 0) || (mRow, mCol) == (2, 2) {
                    type = .TriangleLeft
                } else if (mRow, mCol) == (0, 2) || (mRow, mCol) == (2, 0) {
                    type = .TriangleRight
                } else if (mRow, mCol) == (1, 0) || (mRow, mCol) == (3, 2) {
                    type = .SquareN30
                } else if (mRow, mCol) == (1, 1) || (mRow, mCol) == (3, 3) {
                    type = .TriangleUp
                } else if (mRow, mCol) == (1, 2) || (mRow, mCol) == (3, 0) {
                    type = .Square30
                } else if (mRow, mCol) == (1, 3) || (mRow, mCol) == (3, 1) {
                    type = .TriangleDown
                } else {
                    type = nil
                }
                
                if type != nil {
                    let piece = Piece(row: row, col: col, type: type!)
                    board[row].append(piece)
                } else {
                    board[row].append(nil)
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
        
        switch piece.type {
        case .TriangleUp:
            switch direction {
            case .South:            rowCol.row += 2
            case .NorthEastEast:                     rowCol.col += 1
            case .NorthWestWest:                     rowCol.col -= 1
            default: return nil
            }
            
            
        case .TriangleDown:
            switch direction {
            case .North:            rowCol.row -= 2
            case .SouthEastEast:                     rowCol.col += 1
            case .SouthWestWest:                     rowCol.col -= 1
            default: return nil
            }
            
        case .TriangleLeft:
            switch direction {
            case .East:                              rowCol.col += 2
            case .SouthSouthWest:   rowCol.row += 1
            case .NorthNorthWest:   rowCol.row -= 1
            default: return nil
            }
            
        case .TriangleRight:
            switch direction {
            case .West:                              rowCol.col -= 2
            case .SouthSouthEast:   rowCol.row += 1
            case .NorthNorthEast:   rowCol.row -= 1
            default: return nil
            }
            
        case .Square30:
            switch direction {
            case .NorthNorthWest:   rowCol.row -= 1
            case .NorthEastEast:                     rowCol.col += 1
            case .SouthSouthEast:   rowCol.row += 1
            case .SouthWestWest:                     rowCol.col -= 1
            default: return nil
            }
            
        case .SquareN30:
            switch direction {
            case .NorthNorthEast:   rowCol.row -= 1
            case .NorthWestWest:                     rowCol.col -= 1
            case .SouthSouthWest:   rowCol.row += 1
            case .SouthEastEast:                     rowCol.col += 1
            default: return nil
            }
            
        default:
            return nil
        }
        
        return rowCol
    }


}
