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
    case Hexagon
    case SquareN30
    case Dodecagon
    case Hexagon30
    
    func description() -> String {
        let names: [PieceType: String] = [.Octagon: "Oct", .Square45: "Sq45", .TriangleUp: "TriUp",
                                          .TriangleDown: "TriDown", .TriangleLeft: "TriLeft",
                                          .TriangleRight: "TriRight", .Square: "Sq", .Square30: "Sq30",
                                          .Hexagon: "Hex", .SquareN30: "SqN30", .Dodecagon: "Dodec",
                                          .Hexagon30: "Hex30"]
        return names[self]!
    }
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

protocol AbstractGameBoardProtocol: class {
    func piecePipeDidChangeState(piece: Piece, logicalDir: Direction, fromOldState oldState: PipeState)
    func pieceDidRotate(piece: Piece)
    func boardDidClear()
    func gameWon()
}

class Piece: NSObject {
    var row: Int
    var col: Int
    var type: PieceType
    var pipes: [PipeState]
    var absAngle: Int
    var angleStep: Int
    var legalDirections: [Direction]
    var enabling: Bool = false
    
    init(row: Int, col: Int, type: PieceType) {
        self.row = row
        self.col = col
        self.type = type
        self.pipes = Array<PipeState>(count: 16, repeatedValue: .None)
        self.absAngle = 0
        
        switch type {
        case .Octagon:
            legalDirections = [.North, .NorthEast, .East, .SouthEast, .South, .SouthWest, .West, .NorthWest]
            angleStep = 45
        case .Square45:
            legalDirections = [.NorthEast, .SouthEast, .SouthWest, .NorthWest]
            angleStep = 90
        case .Hexagon:
            legalDirections = [.North, .NorthEastEast, .SouthEastEast, .South, .SouthWestWest, .NorthWestWest]
            angleStep = 60
        case .Square:
            legalDirections = [.North, .East, .South, .West]
            angleStep = 90
        case .TriangleUp:
            legalDirections = [.South, .NorthEastEast, .NorthWestWest]
            angleStep = 120
        case .TriangleDown:
            legalDirections = [.North, .SouthEastEast, .SouthWestWest]
            angleStep = 120
        case .TriangleLeft:
            legalDirections = [.East, .SouthSouthWest, .NorthNorthWest]
            angleStep = 120
        case .TriangleRight:
            legalDirections = [.West, .SouthSouthEast, .NorthNorthEast]
            angleStep = 120
        case .Square30:
            legalDirections = [.NorthNorthWest, .NorthEastEast, .SouthSouthEast, .SouthWestWest]
            angleStep = 90
        case .SquareN30:
            legalDirections = [.NorthNorthEast, .NorthWestWest, .SouthSouthWest, .SouthEastEast]
            angleStep = 90
        case .Dodecagon:
            legalDirections = [.North, .NorthNorthEast, .NorthEastEast, .East, .SouthEastEast, .SouthSouthEast,
                                .South, .SouthSouthWest, .SouthWestWest, .West, .NorthWestWest, .NorthNorthWest]
            angleStep = 30
        case .Hexagon30:
            legalDirections = [.NorthNorthEast, .East, .SouthSouthEast, .SouthSouthWest, .West, .NorthNorthWest]
            angleStep = 60
            
            
//        default:
//            legalDirections = []
//            angleStep = 0
        }
    }
    
    func trueDirForLogicalDir(dir: Direction) -> Direction {
        return Direction(rawValue: (dir.rawValue + absAngle) % 360)!
    }
    
    func logicalDirForTrueDir(dir: Direction) -> Direction {
        return Direction(rawValue: (dir.rawValue - absAngle + 360) % 360)!
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
    
    weak var delegate: AbstractGameBoardProtocol?
    
    // This is for the disable/enable functions when
    // rotating. Helps with loops
    var piecesToRevisit: [Piece] = []
    
    init(width boardWidth: Int, height boardHeight: Int) {
        
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
    
    func rootPiece() -> Piece? {
        return self.getPiece(row: self.sourceRow, col: self.sourceCol)
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
        let oldState = piece.pipeState(forTrueDir: trueDir)!
        
        if piece.setPipeState(state, forTrueDir: trueDir) {
            if let del = self.delegate {
                del.piecePipeDidChangeState(piece, logicalDir: piece.logicalDirForTrueDir(trueDir), fromOldState: oldState)
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
        
        self.disablePipes()
//        self.disablePipesFrom(piece)
        // TODO: Revisit pieces
    
        piece.absAngle = (piece.absAngle + piece.angleStep) % 360
        
        if let del = self.delegate {
            del.pieceDidRotate(piece)
        }
        
        // After the rotation, try re-enabling any pipes
//        self.enablePipesFrom(piece)
        self.enablePipesFromRoot()
        
        if let del = self.delegate where self.boardComplete() {
            del.gameWon()
        }
        
        return true
    }
    
    func disablePipes() {
        self.forAllPieces {
            piece in
            
            piece.forEachPipeState {
                trueDir, state in
                
                if state != .None {
                    self.setPipeState(.Disabled, ofPiece: piece, inTrueDir: trueDir)
                }
            }
        }
        
        if let root = self.rootPiece() {
            root.forEachPipeState {
                trueDir, state in
                
                if state != .None {
                    self.setPipeState(.Branch, ofPiece: root, inTrueDir: trueDir)
                }
            }
        }
    }
    
    func enablePipesFromRoot() {
        if let root = self.rootPiece() {
            self.enablePipesFrom(root)
        }
    }
    
    func disablePipesFrom(piece: Piece) {
        piece.forEachPipeState {
            trueDir, state in
            
            if (state == .Source || state == .Branch) && !self.pieceIsRoot(piece) {
                self.setPipeState(.Disabled, ofPiece: piece, inTrueDir: trueDir)
            }
            
            if state == .Branch {
                if let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) {
                    let adjState = adjPiece.pipeState(forTrueDir: trueDir.opposite())
                    if adjState == .Source {
                        self.disablePipesFrom(adjPiece)
                    } else if adjState == .Branch {
                        self.piecesToRevisit.append(adjPiece)
                    }
                }
            }
        }
    }
    
    @objc func enablePipesFrom(piece: Piece) {
        
        if piece.enabling {
            return
        }
        piece.enabling = true

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
        
        piece.enabling = false
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
        guard let source = self.getPiece(row: self.sourceRow, col: self.sourceCol) else {
            fatalError("No source?!")
        }
        
        self.disablePipesFrom(source)
        
        self.forAllPieces {
            piece in
            
            let numRots = Int(TessellationsPuzzleGenRand() % 16)
            piece.absAngle = (numRots * piece.angleStep) % 360
        }
        
        // After the rotation, try re-enabling any pipes
        self.enablePipesFrom(source)
        
        if let del = self.delegate {
            self.forAllPieces {
                piece in
                del.pieceDidRotate(piece)
            }
        }
    }
    
    func randomPiece() -> Piece {
        var piece = self.getPiece(row: Int(TessellationsPuzzleGenRand() % UInt(self.boardHeight)),
                                  col: Int(TessellationsPuzzleGenRand() % UInt(self.boardWidth)))
        while piece == nil {
            piece = self.getPiece(row: Int(TessellationsPuzzleGenRand() % UInt(self.boardHeight)),
                                  col: Int(TessellationsPuzzleGenRand() % UInt(self.boardWidth)))
        }
        return piece!
    }
    
    // Maze generaton variables
    var mazeRow: Int = 0
    var mazeCol: Int = 0
    var mazeRunning: Bool = false
    
    // Kruskal Data Structures
    var kruSets: [[UnionFind?]] = []
    var kruEdgesSet: Set<Duplet<RowCol, Direction>> = []
    var kruEdgesList: [Duplet<RowCol, Direction>] = []
    
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
            
//            self.performSelector(#selector(self.generatePrim), withObject: nil, afterDelay: 0.05)
            self.generatePrim()
        } else {
            mazeRunning = false
            self.randomizeBoard()
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
    
    
    func generateKruskal() {
        // Reset and start algorithm
        if mazeRunning == false {
            self.clearBoard()
            let randomPiece = self.randomPiece()
            mazeRow = randomPiece.row
            mazeCol = randomPiece.col
            self.sourceRow = mazeRow
            self.sourceCol = mazeCol
            
            kruSets = Array<Array<UnionFind?>>(count: self.boardHeight, repeatedValue: Array<UnionFind?>(count: self.boardWidth, repeatedValue: nil))
            kruEdgesSet.removeAll()
            
            self.forAllPieces {
                piece in
                
                self.kruSets[piece.row][piece.col] = UnionFind()
                
                for dir in piece.legalDirections {
                    if let _ = self.getPiece(inDir: dir, ofPiece: piece) {
                        self.kruEdgesSet.insert(Duplet<RowCol, Direction>(RowCol(row: piece.row, col: piece.col), dir))
                    }
                }
            }
            
            kruEdgesList = Array(kruEdgesSet)
            kruEdgesList.shuffleInPlace()
            
            mazeRunning = true
        }
        
        var pipeAdded = false
        while let duplet = kruEdgesList.popLast() {
            let rowCol1 = duplet.one
            let direction = duplet.two
        
            if let piece1 = self.getPiece(row: rowCol1.row, col: rowCol1.col)
                , piece2 = self.getPiece(inDir: direction, ofPiece: piece1)
                where self.piecesInSameSet(piece1: piece1, piece2: piece2) == false {
                
                self.setPipeState(.Disabled, ofPiece: piece1, inTrueDir: direction)
                self.setPipeState(.Disabled, ofPiece: piece2, inTrueDir: direction.opposite())
                
                self.joinRowColSets(piece1: piece1, piece2: piece2)
                self.performSelector(#selector(self.generateKruskal), withObject: nil, afterDelay: 0.1)
                pipeAdded = true
                break
            } else {
                continue
            }
        }
        
        if pipeAdded == false {
            mazeRunning = false
            
            // Set all pipes in the source piece to be branches
            // then traverse the tree and do the right .Source or .Branch's
            if let piece = self.getPiece(row: self.sourceRow, col: self.sourceCol) {
                piece.forEachPipeState {
                    trueDir, state in
                    
                    guard state == .Disabled else {
                        return
                    }
                    
                    guard let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) else {
                        return
                    }
                    
                    self.setPipeState(.Branch, ofPiece: piece, inTrueDir: trueDir)
                    self.setPipeState(.Source, ofPiece: adjPiece, inTrueDir: trueDir.opposite())
                    
                    self.traverseAndSetPipes(fromRow: adjPiece.row, col: adjPiece.col)
                }
            }
        }
    }

    func traverseAndSetPipes(fromRow row: Int, col: Int) {
        if let piece = self.getPiece(row: row, col: col) {
            piece.forEachPipeState {
                trueDir, state in
                
                if state == .Disabled {
                    guard let adjPiece = self.getPiece(inDir: trueDir, ofPiece: piece) else {
                        return
                    }
                                        
                    self.setPipeState(.Branch, ofPiece: piece, inTrueDir: trueDir)
                    self.setPipeState(.Source, ofPiece: adjPiece, inTrueDir: trueDir.opposite())
                    
                    self.traverseAndSetPipes(fromRow: adjPiece.row, col: adjPiece.col)
                }
            }
        }
    }
    
    func joinRowColSets(piece1 piece1: Piece, piece2: Piece) {
        if let set1: UnionFind = kruSets[piece1.row][piece1.col],
            let set2: UnionFind = kruSets[piece2.row][piece2.col] {
            
            set2.addToSet(set1)
        } else {
            return
        }
    }
    
    func piecesInSameSet(piece1 piece1: Piece, piece2: Piece) -> Bool {
        if let set1: UnionFind = kruSets[piece1.row][piece1.col],
            let set2: UnionFind = kruSets[piece2.row][piece2.col] {
            
            return UnionFind.areEqualSets(one: set1, two: set2)
        } else {
            return false
        }
    }
    
    

    
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

