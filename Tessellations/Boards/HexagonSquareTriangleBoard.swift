//
//  HexagonSquareTriangleBoard.swift
//  Tessellations
//
//  Created by James Linnell on 8/17/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class HexagonSquareTriangleBoard: AbstractGameBoard {
    
    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                
                let type: PieceType?
                if (row % 4 == 0 && col % 4 == 1) || (row % 4 == 2 && col % 4 == 3) {
                    /* Hexagon 30 Degrees */
                    type = .Hexagon30
                } else if (row % 4 == 0 && col % 4 == 3) || (row % 4 == 2 && col % 4 == 1) {
                    /* Square (Regular) */
                    type = .Square
                } else if (row % 4 == 1 && col % 4 == 2) || (row % 4 == 3 && col % 4 == 0) {
                    /* Square (30) */
                    type = .Square30
                } else if (row % 4 == 1 && col % 4 == 0) || (row % 4 == 3 && col % 4 == 2) {
                    /* Square (Negative 30) */
                    type = .SquareN30
                } else if (row % 4 == 1 && col % 4 == 1) || (row % 4 == 3 && col % 4 == 3) {
                    /* Triangle Up */
                    type = .TriangleUp
                } else if (row % 4 == 1 && col % 4 == 3) || (row % 4 == 3 && col % 4 == 1) {
                    /* Triangle Down */
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
        case .Hexagon30:
            switch direction {
            case .NorthNorthEast: rowCol.row -= 1; rowCol.col += 1
            case .East:                            rowCol.col += 2
            case .SouthSouthEast: rowCol.row += 1; rowCol.col += 1
            case .SouthSouthWest: rowCol.row += 1; rowCol.col -= 1
            case .West:                            rowCol.col -= 2
            case .NorthNorthWest: rowCol.row -= 1; rowCol.col -= 1
            default: break
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
            
        case .TriangleUp:
            switch direction {
            case .South:            rowCol.row += 1
            case .NorthEastEast:                     rowCol.col += 1
            case .NorthWestWest:                     rowCol.col -= 1
            default: break
            }
            
        case .TriangleDown:
            switch direction {
            case .North:            rowCol.row -= 1
            case .SouthEastEast:                     rowCol.col += 1
            case .SouthWestWest:                     rowCol.col -= 1
            default: break
            }
            
        default:
            return nil
        }
        
        return rowCol
    }

}
