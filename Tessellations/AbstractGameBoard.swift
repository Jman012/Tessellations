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
    case Square45
    case TriangleUp
    case TriangleDown
    case TriangleLeft
    case TriangleRight
    case Square
    case Square30
}

enum Direction: Int {
    case North          = 0
    case NorthNorthEast = 30
    case NorthEast      = 45
    case NorthEastEast  = 60
    case East           = 90
    case SouthEastEast  = 120
    case SouthEast      = 135
    case SouthSouthEast = 150
    case South          = 180
    case SouthSouthWest = 210
    case SouthWest      = 225
    case SouthWestWest  = 240
    case West           = 270
    case NorthWestWest  = 300
    case NorthWest      = 315
    case NorthNorthWest = 330
    
    func opposite() -> Direction {
        return Direction(rawValue: (self.rawValue + 180) % 360)!
    }
    
    func withOffsetAngle(angle: Int) -> Direction {
        return Direction(rawValue: (Int(self.rawValue) + angle + 360) % 360)!
    }
    
    func toIndex() -> Int {
        let translation: [Direction: Int] = [.North: 0, .NorthNorthEast: 1, .NorthEast: 2, .NorthEastEast: 3, .East: 4,
                           .SouthEastEast: 5, .SouthEast: 6, .SouthSouthEast: 7, .South: 8,
                           .SouthSouthWest: 9, .SouthWest: 10, .SouthWestWest: 11, .West: 12,
                           .NorthWestWest: 13, .NorthWest: 14, .NorthNorthWest: 15]
        return translation[self]!
    }
}

enum PipeState: UInt {
    case None     = 0
    case Disabled = 1
    case Source   = 2
    case Branch   = 3
}

protocol OctSquareBoardProtocol {
    func pieceDidChange(piece: Piece)
    func pieceDidRotate(piece: Piece)
    func boardDidClear()
    func gameWon()
}

class Piece: NSObject {
    var row: Int
    var col: Int
    var type: PieceType
    var pipes: [PipeState]
    var absLogicalAngle: Int
    var angleStep: Int
    var legalDirections: [Direction]
    
    init(row: Int, col: Int, type: PieceType) {
        self.row = row
        self.col = col
        self.type = type
        self.pipes = Array<PipeState>(count: 16, repeatedValue: .None)
        self.absLogicalAngle = 0
        
        switch type {
        case .Octagon:
            legalDirections = [.North, .NorthEast, .East, .SouthEast, .South, .SouthWest, .West, .NorthWest]
            angleStep = 45
        case .Square:
            legalDirections = [.NorthEast, .SouthEast, .SouthWest, .NorthWest]
            angleStep = 90
        default:
            legalDirections = []
            angleStep = 0
        }
    }
    
    func trueDirForLogicalDir(dir: Direction) -> Direction {
        return Direction(rawValue: (dir.rawValue + absLogicalAngle) % 360)!
    }
    
    func logicalDirForTrueDir(dir: Direction) -> Direction {
        return Direction(rawValue: (dir.rawValue - absLogicalAngle + 360) % 360)!
    }
    
    func pipeState(forTrueDir trueDir: Direction) -> PipeState? {
        let logDir = self.logicalDirForTrueDir(trueDir)
        if legalDirections.contains(logDir) {
            return pipes[logDir.toIndex()]
        } else {
            return nil
        }
    }
    
    func forEachPipeState(callback: (trueDir: Direction, state: PipeState) -> Void) {
        for legalLogDir in legalDirections {
            callback(trueDir: self.trueDirForLogicalDir(legalLogDir), state: pipes[legalLogDir.toIndex()])
        }
    }
    
    func setPipeState(state: PipeState, forTrueDir trueDir: Direction) -> Bool {
        let logDir = self.logicalDirForTrueDir(trueDir)
        if legalDirections.contains(logDir) {
            pipes[logDir.toIndex()] = state
            return true
        }
        return false
    }
    
    func hasPipes() -> Bool {
        var has = false
        self.forEachPipeState {
            trueDir, state in
            if state != .None {
                has = true
            }
        }
        return has
    }
}

class AbstractGameBoard: NSObject {
    
    var boardWidth: Int
    var boardHeight: Int
    
    var board: [[Piece?]] = []
    
    // Which piece is the main source
    var sourceRow: Int = 0
    var sourceCol: Int = 0
    
    var delegate: OctSquareBoardProtocol?
    
    init(octagonsWide boardWidth: Int, octagonsTall boardHeight: Int) {
        
        guard boardWidth >= 1 && boardHeight >= 1 else {
            exit(1)
        }
        
        self.boardWidth = boardWidth
        self.boardHeight = boardHeight
        
        super.init()
        
        self.initPieces()
    }
    
    func initPieces() {
        print("initPieces not implemented")
    }
    
    func getPiece(row row: Int, col: Int) -> Piece? {
        guard row >= 0 && row < self.boardHeight
            && col >= 0 && col < self.boardWidth else {
            return nil
        }
        return self.board[row][col]
        
    }
    
    func pieceIsRoot(piece: Piece) -> Bool {
        return piece.row == self.sourceRow && piece.col == self.sourceCol
    }
    
    func adjacentPieceDisplacement(piece piece: Piece, direction: Direction) -> RowCol? {
        print("adjacentPieceDisplacement not implemented")
        return nil
    }
    
    func getPiece(inDir trueDir: Direction, ofPiece piece: Piece) -> Piece? {
        var row = piece.row, col = piece.col
        
        if let displacement = self.adjacentPieceDisplacement(piece: piece, direction: trueDir) {
            row += displacement.row
            col += displacement.col
        
            return self.getPiece(row: row, col: col)
        } else {
            return nil
        }
    }
    
    func setPipeState(state: PipeState, ofPiece piece: Piece, inTrueDir trueDir: Direction) -> Bool {
        
        if piece.setPipeState(state, forTrueDir: trueDir) {
            if let del = self.delegate {
                del.pieceDidChange(piece)
            }
            
            // Return new piece
            return true
        }
        
        return false
    }
    
    func boardComplete() -> Bool {
        var good = true
        self.forAllPieces {
            piece in
            
            piece.forEachPipeState {
                trueDir, state in
                
                guard state == .Branch || state == .Source else {
                    if state == .Disabled {
                        good = false
                    }
                    return
                }
                
                if let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) {
                    
                    let adjState = adjPiece.pipeState(forTrueDir: trueDir.opposite())
                    
                    if adjState == .None || adjState == .Disabled {
                        good = false
                    }
                } else {
                    good = false
                }
            }
        }
        
        return good
    }
    
    func rotatePiece(row row: Int, col: Int) -> Bool {

        guard let piece = self.getPiece(row: row, col: col) else {
            return false
        }
        
        self.disablePipesFrom(piece)
    
        piece.absLogicalAngle = (piece.absLogicalAngle + piece.angleStep) % 360
        
        if let del = self.delegate {
            del.pieceDidRotate(piece)
        }
        
        // After the rotation, try re-enabling any pipes
        self.enablePipesFrom(piece)
        
        if let del = self.delegate where self.boardComplete() {
            del.gameWon()
        }
        
        return true
    }
    
    func disablePipesFrom(piece: Piece) {
        piece.forEachPipeState {
            trueDir, state in
            
            if (state == .Source || state == .Branch) && !self.pieceIsRoot(piece) {
                self.setPipeState(.Disabled, ofPiece: piece, inTrueDir: trueDir)
            }
            
            if state == .Branch {
                if let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece)
                    where adjPiece.pipeState(forTrueDir: trueDir.opposite()) == .Source {
                    
                    self.disablePipesFrom(adjPiece)
                }
            }
        }
    }
    
    @objc func enablePipesFrom(piece: Piece) {

        if self.pieceIsRoot(piece) {
            piece.forEachPipeState {
                trueDir, state in
                
                // Source piece, find our branches and recur from there
                if state == .Branch {
                    if let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) {
                        self.enablePipesFrom(adjPiece)
                    }
                }
            }
            
        } else {
            
            // Find any Sources after the rotation
            var sourceSet = false
            piece.forEachPipeState {
                trueDir, state in
                
                if state == .Disabled {
                    if let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece)
                        where adjPiece.pipeState(forTrueDir: trueDir.opposite()) == .Branch {
                                                
                        // If a Disabled pipe is touching an adjacent Branch pipe,
                        // then turn our Disabled to a Source
                        
                        self.setPipeState(.Source, ofPiece: piece, inTrueDir: trueDir)
                        sourceSet = true
                    }
                }
            }
            
            if sourceSet {
                piece.forEachPipeState {
                    trueDir, state in
                    
                    if state == .Disabled {
                        self.setPipeState(.Branch, ofPiece: piece, inTrueDir: trueDir)
                        
                        if let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) {
                            self.enablePipesFrom(adjPiece)
                        }
                    }
                }
            }
        }
    }
    
    func forAllPieces(callback: (piece: Piece) -> Void) {
        
        for row in 0..<self.boardHeight {
            for col in 0..<self.boardWidth {
                if let piece = self.getPiece(row: row, col: col) {
                    callback(piece: piece)
                }
                
            }
        }
    }
    
    func clearBoard() {
        self.initPieces()
        
        if let del = self.delegate {
            del.boardDidClear()
        }
    }
    
    func randomizeBoard() {
        self.forAllPieces {
            piece in
            
            let numRots = Int(arc4random() % 8)
            for _ in 0..<numRots {
                self.rotatePiece(row: piece.row, col: piece.col)
            }
        }
    }
    
    func randomPiece() -> Piece {
        var piece = self.getPiece(row: Int(arc4random()) % self.boardHeight, col: Int(arc4random()) % self.boardWidth)
        while piece == nil {
            piece = self.getPiece(row: Int(arc4random()) % self.boardHeight, col: Int(arc4random()) % self.boardWidth)
        }
        return piece!
    }
    
    // Maze generaton variables
    var mazeRow: Int = 0
    var mazeCol: Int = 0
    var mazeRunning: Bool = false
    
    // Kruskal Data Structures
    var kruOctSets: [[UnionFind]] = []
    var kruSquareSets: [[UnionFind]] = []
    var kruEdges: [(RowCol, RowCol)] = []
    
    // Prim data structures
    var visited: Set<RowCol> = []
    var frontier: Set<RowCol> = []
}

extension AbstractGameBoard {
    
    
    func generatePrim() {
        // Reset and start algorithm
        if mazeRunning == false {
            self.clearBoard()
            let randomPiece = self.randomPiece()
            mazeRow = randomPiece.row
            mazeCol = randomPiece.col
            self.sourceRow = mazeRow
            self.sourceCol = mazeCol
            
            self.visited = [RowCol(row: mazeRow, col: mazeCol)]
            self.addNeighborsToFrontier(rowCol: visited.first!)
            
            mazeRunning = true
        }
        
        if let rowCol = frontier.popFirst() {
            
            let piece = self.getPiece(row: rowCol.row, col: rowCol.col)!
            
            var dirs = piece.legalDirections
            dirs.shuffleInPlace()
            
            for dir in dirs {
                if let adjPiece = self.getPiece(inDir: dir, ofPiece: piece)
                    where self.visited.contains(RowCol(row: adjPiece.row, col: adjPiece.col)) == true {
                    
                    self.setPipeState(.Source, ofPiece: piece, inTrueDir: dir)
                    self.setPipeState(.Branch, ofPiece: adjPiece, inTrueDir: dir.opposite())
                    
                    self.visited.insert(rowCol) // Insert the piece we're on, not the adjPiece. That's already in there
                    self.addNeighborsToFrontier(rowCol: rowCol) // then insert from this piece too
                    
                    break
                }
            }
            
            self.performSelector(#selector(self.generatePrim), withObject: nil, afterDelay: 0.1)
        } else {
            mazeRunning = false
        }
    }
    
    func addNeighborsToFrontier(rowCol rowCol: RowCol) {
        if let piece = self.getPiece(row: rowCol.row, col: rowCol.col) {
            
            let dirs = piece.legalDirections
            
            for dir in dirs {
                
                if let adjPiece = self.getPiece(inDir: dir, ofPiece: piece) {
                    let adjPieceRowCol = RowCol(row: adjPiece.row, col: adjPiece.col)
                    if self.frontier.contains(adjPieceRowCol) == false && self.visited.contains(adjPieceRowCol) == false {
                        self.frontier.insert(adjPieceRowCol)
                    }
                }
            }
        }
    }
    
    
//    func generateKruskal() {
//        // Reset and start algorithm
//        if mazeRunning == false {
//            self.clearBoard()
//            let randomPiece = self.randomPiece()
//            mazeRow = randomPiece.row
//            mazeCol = randomPiece.col
//            self.sourceRow = mazeRow
//            self.sourceCol = mazeCol
//            
//            for pRow: Int in 0..<Int(boardHeight) {
//                kruOctSets.insert([], atIndex: pRow)
//                for pCol: Int in 0..<Int(boardWidth) {
//                    let rowCol = RowCol(row: pRow * 2, col: pCol * 2)
//                    kruOctSets[pRow].insert(UnionFind(), atIndex: pCol)
//                    kruEdges.append((rowCol, RowCol(row: rowCol.row, col: rowCol.col+2)))
//                    kruEdges.append((rowCol, RowCol(row: rowCol.row+1, col: rowCol.col+1)))
//                    kruEdges.append((rowCol, RowCol(row: rowCol.row+2, col: rowCol.col)))
//                    
//                }
//            }
//            for pRow: Int in 0..<Int(boardHeight-1) {
//                kruSquareSets.insert([], atIndex: pRow)
//                for pCol: Int in 0..<Int(boardWidth-1) {
//                    let rowCol = RowCol(row: (pRow * 2) + 1, col: (pCol * 2) + 1)
//                    kruSquareSets[pRow].insert(UnionFind(), atIndex: pCol)
//                    kruEdges.append((rowCol, RowCol(row: rowCol.row-1, col: rowCol.col+1)))
//                    kruEdges.append((rowCol, RowCol(row: rowCol.row+1, col: rowCol.col+1)))
//                    kruEdges.append((rowCol, RowCol(row: rowCol.row+1, col: rowCol.col-1)))
//                }
//            }
//            
//            kruEdges.shuffleInPlace()
//            
//            mazeRunning = true
//        }
//        
//        var pipeAdded = false
//        while let (rowCol1, rowCol2) = kruEdges.popLast() {
//            
//            if let piece1 = self.getPiece(row: rowCol1.row, col: rowCol1.col)
//                , piece2 = self.getPiece(row: rowCol2.row, col: rowCol2.col)
//                where self.rowColInSameSet(rowCol1, rowCol2: rowCol2) == false {
//                
//                
//                let direction = self.directionBetweenRowCols(rowCol1, rowCol2: rowCol2)!
//
//                self.setPipeState(.Disabled, ofPiece: piece1, inTrueDir: direction)
//                self.setPipeState(.Disabled, ofPiece: piece2, inTrueDir: direction.opposite())
//                
//                self.joinRowColSets(rowCol1, rowCol2: rowCol2)
//                self.performSelector(#selector(self.generateKruskal), withObject: nil, afterDelay: 0.1)
//                pipeAdded = true
//                break
//            } else {
//                continue
//            }
//        }
//        
//        if pipeAdded == false {
//            mazeRunning = false
//            
//            // Set all pipes in the source piece to be branches
//            // then traverse the tree and do the right .Source or .Branch's
//            if let piece = self.getPiece(row: self.sourceRow, col: self.sourceCol) {
//                piece.forEachPipeState {
//                    trueDir, state in
//                    
//                    guard state == .Disabled else {
//                        return
//                    }
//                    
//                    guard let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) else {
//                        return
//                    }
//                    
//                    self.setPipeState(.Branch, ofPiece: piece, inTrueDir: trueDir)
//                    self.setPipeState(.Source, ofPiece: adjPiece, inTrueDir: trueDir.opposite())
//                    
//                    self.traverseAndSetPipes(fromRow: adjPiece.row, col: adjPiece.col)
//                }
//            }
//        }
//    }
//    
//    func traverseAndSetPipes(fromRow row: Int, col: Int) {
//        if let piece = self.getPiece(row: row, col: col) {
//            piece.forEachPipeState {
//                trueDir, state in
//                
//                if state == .Disabled {
//                    guard let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) else {
//                        return
//                    }
//                    
//                    self.setPipeState(.Branch, ofPiece: piece, inTrueDir: trueDir)
//                    self.setPipeState(.Source, ofPiece: adjPiece, inTrueDir: trueDir.opposite())
//                    
//                    self.traverseAndSetPipes(fromRow: adjPiece.row, col: adjPiece.col)
//                }
//            }
//        }
//    }
//    
//    func joinRowColSets(rowCol1: RowCol, rowCol2: RowCol) {
//        var set1: UnionFind
//        if let (type, pRow, pCol) = self.logicalRowColToPhysical(row: rowCol1.row, col: rowCol1.col)
//            where self.pRowColIsLegalOfType(type, pRow: pRow, pCol: pCol) {
//            switch type {
//            case .Octagon:
//                set1 = kruOctSets[pRow][pCol]
//            case .Square:
//                set1 = kruSquareSets[pRow][pCol]
//            }
//        } else {
//            return
//        }
//        
//        var set2: UnionFind
//        if let (type, pRow, pCol) = self.logicalRowColToPhysical(row: rowCol2.row, col: rowCol2.col)
//            where self.pRowColIsLegalOfType(type, pRow: pRow, pCol: pCol) {
//            switch type {
//            case .Octagon:
//                set2 = kruOctSets[pRow][pCol]
//            case .Square:
//                set2 = kruSquareSets[pRow][pCol]
//            }
//        } else {
//            return
//        }
//        
//        set2.addToSet(set1)
//    }
//    
//    func directionBetweenRowCols(rowCol1: RowCol, rowCol2: RowCol) -> PipeDir? {
//        let dRow = rowCol1.row - rowCol2.row
//        let dCol = rowCol1.col - rowCol2.col
//        
//        if dRow > 0 && dCol == 0 {
//            return .North
//        } else if dRow > 0 && dCol < 0 {
//            return .NorthEast
//        } else if dRow == 0 && dCol < 0 {
//            return .East
//        } else if dRow < 0 && dCol < 0 {
//            return .SouthEast
//        } else if dRow < 0 && dCol == 0 {
//            return .South
//        } else if dRow < 0 && dCol > 0 {
//            return .SouthWest
//        } else if dRow == 0 && dCol > 0 {
//            return .West
//        } else if dRow > 0 && dCol > 0 {
//            return .NorthWest
//        } else {
//            return nil
//        }
//    }
//    
//    func rowColInSameSet(rowCol1: RowCol, rowCol2: RowCol) -> Bool {
//        
//        var set1: UnionFind
//        if let (type, pRow, pCol) = self.logicalRowColToPhysical(row: rowCol1.row, col: rowCol1.col)
//            where self.pRowColIsLegalOfType(type, pRow: pRow, pCol: pCol) {
//            switch type {
//            case .Octagon:
//                set1 = kruOctSets[pRow][pCol]
//            case .Square:
//                set1 = kruSquareSets[pRow][pCol]
//            }
//        } else {
//            return false
//        }
//        
//        var set2: UnionFind
//        if let (type, pRow, pCol) = self.logicalRowColToPhysical(row: rowCol2.row, col: rowCol2.col)
//            where self.pRowColIsLegalOfType(type, pRow: pRow, pCol: pCol) {
//            switch type {
//            case .Octagon:
//                set2 = kruOctSets[pRow][pCol]
//            case .Square:
//                set2 = kruSquareSets[pRow][pCol]
//            }
//        } else {
//            return false
//        }
//
//        return UnionFind.areEqualSets(one: set1, two: set2)
//    }
    
    

    
    func generateHuntAndKill() {
        // Reset and start algorithm
        if mazeRunning == false {
            self.clearBoard()
            let randomPiece = self.randomPiece()
            mazeRow = randomPiece.row
            mazeCol = randomPiece.col
            self.sourceRow = mazeRow
            self.sourceCol = mazeCol
            mazeRunning = true
        }
        
        if let mazePiece = self.getPiece(row: mazeRow, col: mazeCol) where mazeRunning == true {
            // Run the algorithm
            let neighbors = self.freeNeighbors(row: mazeRow, col: mazeCol)
            
            if neighbors.count > 0 {
                let neighborDir = neighbors.randomItem()
                let neighbor = self.getPiece(inDir: neighborDir, ofPiece: mazePiece)!
                
                self.setPipeState(.Branch, ofPiece: mazePiece, inTrueDir: neighborDir)
                self.setPipeState(.Source, ofPiece: neighbor, inTrueDir: neighborDir.opposite())
                
                mazeRow = neighbor.row
                mazeCol = neighbor.col
                
                self.performSelector(#selector(self.generateHuntAndKill), withObject: nil, afterDelay: 0.1)

            } else if let (row, col) = hunt() {
                let huntedPiece = self.getPiece(row: row, col: col)!
                
                let neighborDir = self.adjacentNeighbors(row: row, col: col).randomItem()
                let neighbor = self.getPiece(inDir: neighborDir, ofPiece: huntedPiece)!
                
                self.setPipeState(.Source, ofPiece: huntedPiece, inTrueDir: neighborDir)
                self.setPipeState(.Branch, ofPiece: neighbor, inTrueDir: neighborDir.opposite())
                
                mazeRow = row
                mazeCol = col
                self.performSelector(#selector(self.generateHuntAndKill), withObject: nil, afterDelay: 0.1)
            } else {
                mazeRunning = false
            }

        } else {
            // Stop the algorithm
            print("Error")
            mazeRunning = false
        }
    }
    
    func adjacentNeighbors(row row: Int, col: Int) -> [Direction] {
        let piece = self.getPiece(row: row, col: col)!
        let dirs = piece.legalDirections
        return dirs.filter {
            if let adjPiece = self.getPiece(inDir: $0, ofPiece: piece) {
                return adjPiece.hasPipes()
            } else {
                return false
            }
        }
    }
    
    func freeNeighbors(row row: Int, col: Int) -> [Direction] {
        let piece = self.getPiece(row: row, col: col)!
        let dirs = piece.legalDirections
        return dirs.filter {
            if let adjPiece = self.getPiece(inDir: $0, ofPiece: piece) {
                return adjPiece.hasPipes() == false // Negative of adjacentNeighbors(:)
            } else {
                return false
            }
        }
    }
    
    func hunt() -> (row: Int, col: Int)? {
        var row: Int = -1
        var col: Int = -1
        self.forAllPieces {
            piece in
            
            if piece.hasPipes() == false && self.adjacentNeighbors(row: piece.row, col: piece.col).count > 0 {
                (row, col) = (piece.row, piece.col)
                return
            }
        }
        
        if row != -1 && col != -1 {
            return (row, col)
        } else {
            return nil
        }
    }

}

