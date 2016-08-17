//
//  DodecagonHexagonSquareBoard.swift
//  Tessellations
//
//  Created by James Linnell on 8/15/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class DodecagonHexagonSquareBoard: AbstractGameBoard {
    
    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                
                let type: PieceType?
                if (row % 4 == 0 && col % 4 == 0) || (row % 4 == 2 && col % 4 == 2) {
                    /* Dodecagon */
                    type = .Dodecagon
                } else if (row % 4 == 0 && col % 4 == 2) || (row % 4 == 2 && col % 4 == 0) {
                    /* Square (Regular) */
                    type = .Square
                } else if (row % 4 == 1 && col % 4 == 0) || (row % 4 == 3 && col % 4 == 0) ||
                          (row % 4 == 1 && col % 4 == 2) || (row % 4 == 3 && col % 4 == 2) {
                    /* Hexagons */
                    type = .Hexagon
                } else if (row % 4 == 1 && col % 4 == 1) || (row % 4 == 3 && col % 4 == 3) {
                    /* Square30 */
                    type = .Square30
                } else if (row % 4 == 1 && col % 4 == 3) || (row % 4 == 3 && col % 4 == 1) {
                    /* Square Opposite 30 (Negative) */
                    type = .SquareN30
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
        case .Dodecagon:
            switch direction {
            case .North:            rowCol.row -= 1
            case .NorthNorthEast:   rowCol.row -= 1; rowCol.col += 1
            case .NorthEastEast:    rowCol.row -= 1; rowCol.col += 2
            case .East:                              rowCol.col += 2
            case .SouthEastEast:    rowCol.row += 1; rowCol.col += 2
            case .SouthSouthEast:   rowCol.row += 1; rowCol.col += 1
            case .South:            rowCol.row += 1
            case .SouthSouthWest:   rowCol.row += 1; rowCol.col -= 1
            case .SouthWestWest:    rowCol.row += 1; rowCol.col -= 2
            case .West:                              rowCol.col -= 2
            case .NorthWestWest:    rowCol.row -= 1; rowCol.col -= 2
            case .NorthNorthWest:   rowCol.row -= 1; rowCol.col -= 1
            default: break
            }
        
        case .Hexagon:
            if (piece.row % 4 == 1 && piece.col % 4 == 0) || (piece.row % 4 == 3 && piece.col % 4 == 2) {
                /* Y shaped hexagons */
                switch direction {
                case .North:            rowCol.row -= 1
                case .NorthEastEast:                     rowCol.col += 1
                case .SouthEastEast:    rowCol.row += 1; rowCol.col += 2
                case .South:            rowCol.row += 1
                case .SouthWestWest:    rowCol.row += 1; rowCol.col -= 2
                case .NorthWestWest:                     rowCol.col -= 1
                default: break
                }
            } else {
                /* A shaped hexagons */
                switch direction {
                case .North:            rowCol.row -= 1
                case .NorthEastEast:    rowCol.row -= 1; rowCol.col += 2
                case .SouthEastEast:                     rowCol.col += 1
                case .South:            rowCol.row += 1
                case .SouthWestWest:                     rowCol.col -= 1
                case .NorthWestWest:    rowCol.row -= 1; rowCol.col -= 2
                default: break
                }
            }
        
        case .Square:
            switch direction {
            case .North:    rowCol.row -= 1
            case .East:                      rowCol.col += 2
            case .South:    rowCol.row += 1
            case .West:                      rowCol.col -= 2
            default: break
            }
            
        case .Square30:
            switch direction {
            case .NorthNorthWest:   rowCol.row -= 1; rowCol.col -= 1
            case .NorthEastEast:                     rowCol.col += 1
            case .SouthSouthEast:   rowCol.row += 1; rowCol.col += 1
            case .SouthWestWest:                     rowCol.col -= 1
            default: break
            }
        
        case .SquareN30:
            switch direction {
            case .NorthNorthEast:   rowCol.row -= 1; rowCol.col += 1
            case .SouthEastEast:                     rowCol.col += 1
            case .SouthSouthWest:   rowCol.row += 1; rowCol.col -= 1
            case .NorthWestWest:                     rowCol.col -= 1
            
            
            default: break
            }
            
        default:
            return nil
        }
        
        return rowCol
    }


}
