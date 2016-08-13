//
//  HexagonTriangleBoard.swift
//  Tessellations
//
//  Created by James Linnell on 8/12/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class HexagonTriangleBoard: AbstractGameBoard {
    
    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                let type: PieceType?
                if col % 2 == 0 { // Even Col
                    switch row % 4 {
                    case 0: type = nil
                    case 1: type = .Hexagon
                    case 2: type = .TriangleDown
                    case 3: type = .TriangleUp
                    default: type = nil
                    }
                } else { // Odd Col
                    switch row % 4 {
                    case 0: type = .TriangleDown
                    case 1: type = .TriangleUp
                    case 2: type = nil
                    case 3: type = .Hexagon
                    default: type = nil
                    }
                }
                
                
                if let theType = type {
                    let piece = Piece(row: row, col: col, type: theType)
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
        case .Hexagon:
            switch direction {
            case .North:         rowCol.row += -2
            case .NorthEastEast: rowCol.row += -1; rowCol.col +=  1
            case .SouthEastEast:                   rowCol.col +=  1
            case .South:         rowCol.row +=  1
            case .SouthWestWest:                   rowCol.col += -1
            case .NorthWestWest: rowCol.row += -1; rowCol.col += -1
            default: return nil
            }
            
        case .TriangleUp:
            switch direction {
            case .South:         rowCol.row +=  2
            case .NorthEastEast:                   rowCol.col += 1
            case .NorthWestWest:                   rowCol.col += -1
            default: return nil
            }
            
        case .TriangleDown:
            switch direction {
            case .North:         rowCol.row += -1
            case .SouthEastEast: rowCol.row +=  1; rowCol.col += 1
            case .SouthWestWest: rowCol.row +=  1; rowCol.col += -1
            default: return nil
            }
            
        default:
            return nil
        }
        
        return rowCol
    }

}
