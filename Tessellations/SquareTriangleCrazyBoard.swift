//
//  SquareTriangleCrazyBoard.swift
//  Tessellations
//
//  Created by James Linnell on 8/10/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation

class SquareTriangleCrazyBoard: AbstractGameBoard {
    
    func pieceTypeForRowCol(rowCol: RowCol, stepsUp: Int, stepsLeft: Int) -> (PieceType, stepsUp: Int, stepsLeft: Int)? {
        if (rowCol.row < 3 && rowCol.col < 3) || (rowCol.row == 2 && rowCol.col == 3) {
            // Base Case
            if rowCol.row == 0 && rowCol.col == 1 {
                return (.TriangleDown, stepsUp, stepsLeft)
            } else if rowCol.row == 1 && rowCol.col == 0 {
                return (.Square30, stepsUp, stepsLeft)
            } else if rowCol.row == 1 && rowCol.col == 2 {
                return (.TriangleUp, stepsUp, stepsLeft)
            } else if rowCol.row == 2 && rowCol.col == 1 {
                return (.TriangleLeft, stepsUp, stepsLeft)
            } else if rowCol.row == 2 && rowCol.col == 2 {
                return (.Square, stepsUp, stepsLeft)
            } else if rowCol.row == 2 && rowCol.col == 3 {
                return (.TriangleRight, stepsUp, stepsLeft)
            } else {
                return nil
            }
        } else {
            // Recursive case
            if rowCol.row - 3 >= 0 && rowCol.col - 1 >= 0 {
                return self.pieceTypeForRowCol(RowCol(row: rowCol.row - 3, col: rowCol.col - 1),
                                               stepsUp: stepsUp + 1,
                                               stepsLeft: stepsLeft)
            } else if rowCol.row + 1 < self.boardHeight && rowCol.col - 3 >= 0 {
                return self.pieceTypeForRowCol(RowCol(row: rowCol.row + 1, col: rowCol.col - 3),
                                               stepsUp: stepsUp,
                                               stepsLeft: stepsLeft + 1)
            }  else if rowCol.row - 1 >= 0 && rowCol.col + 3 < self.boardWidth {
                return self.pieceTypeForRowCol(RowCol(row: rowCol.row - 1, col: rowCol.col + 3),
                                               stepsUp: stepsUp,
                                               stepsLeft: stepsLeft - 1)
            } else if rowCol.row + 3 < self.boardHeight && rowCol.col + 1 >= 0 {
                return self.pieceTypeForRowCol(RowCol(row: rowCol.row + 3, col: rowCol.col + 1),
                                               stepsUp: stepsUp - 1,
                                               stepsLeft: stepsLeft)
            } else {
                // Da fuq
                exit(1)
            }
        }
    }
    
    func printBoard() {
        /* For debugging */
        for row in 0..<boardHeight {
            for col in 0..<boardWidth {
                if let piece = board[row][col] {
                    switch piece.type {
                    case .Square:
                        print("S", separator: "", terminator: "")
                    case .Square30:
                        print("3", separator: "", terminator: "")
                    case .TriangleUp:
                        print("^", separator: "", terminator: "")
                    case .TriangleLeft:
                        print("<", separator: "", terminator: "")
                    case .TriangleRight:
                        print(">", separator: "", terminator: "")
                    case .TriangleDown:
                        print("v", separator: "", terminator: "")
                    default:
                        print("E", separator: "", terminator: "")
                    }
                } else {
                    print(" ", separator: "", terminator: "")
                }
            }
            print("\n", separator: "", terminator: "")
        }
    }
    
    override func initPieces() {
        board = []
        
        for row in 0..<boardHeight {
            board.append([])
            for col in 0..<boardWidth {
                if let (type, _, _) = self.pieceTypeForRowCol(RowCol(row: row, col: col), stepsUp: 0, stepsLeft: 0) {
                    let piece = Piece(row: row, col: col, type: type)
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
        case .Square:
            switch direction {
            case .North: rowCol.row -= 1
            case .East: rowCol.col += 1
            case .South: rowCol.row += 1
            case .West: rowCol.col -= 1
            default: break
            }
        case .Square30:
            switch direction {
            case .NorthNorthWest: rowCol.row -= 1; rowCol.col -= 1
            case .NorthEastEast: rowCol.row -= 1; rowCol.col += 1
            case .SouthSouthEast: rowCol.row += 1; rowCol.col += 1
            case .SouthWestWest: rowCol.row += 1; rowCol.col -= 1
            default: break
            }
        case .TriangleUp:
            switch direction {
            case .South: rowCol.row += 1
            case .NorthEastEast: rowCol.row -= 1; rowCol.col += 1
            case .NorthWestWest: rowCol.row -= 1; rowCol.col -= 1
            default: break
            }
        case .TriangleDown:
            switch direction {
            case .North: rowCol.row -= 1
            case .SouthEastEast: rowCol.row += 1; rowCol.col += 1
            case .SouthWestWest: rowCol.row += 1; rowCol.col -= 1
            default: break
            }
        case .TriangleLeft:
            switch direction {
            case .East: rowCol.col += 1
            case .SouthSouthWest: rowCol.row += 1; rowCol.col -= 1
            case .NorthNorthWest: rowCol.row -= 1; rowCol.col -= 1
            default: break
            }
        case .TriangleRight:
            switch direction {
            case .West: rowCol.col -= 1
            case .SouthSouthEast: rowCol.row += 1; rowCol.col += 1
            case .NorthNorthEast: rowCol.row -= 1; rowCol.col += 1
            default: break
            }
        
        default:
            return nil
        }
        
        return rowCol
    }
}
