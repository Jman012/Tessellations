//
//  Globals.swift
//  Tessellations
//
//  Created by James Linnell on 8/24/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

let sceneClassStrings: [String] = [
    NSStringFromClass(TriangleScene.self),
    NSStringFromClass(SquareScene.self),
    NSStringFromClass(HexagonScene.self),
    NSStringFromClass(OctagonSquareScene.self),
    NSStringFromClass(SquareTriangleCrazyScene.self),
    NSStringFromClass(HexagonTriangleScene.self),
    NSStringFromClass(HexagonSquareTriangleScene.self),
    NSStringFromClass(DodecagonHexagonSquareScene.self)
]
enum SceneIndex: Int {
    case Triangle = 0
    case Square = 1
    case Hexagon = 2
    case OctagonSquare = 3
    case SquareTriangle = 4
    case HexagonTriangle = 5
    case HexagonSquareTriangle = 6
    case DodecagonHexagonSquare = 7
}

var thumbnailImages: [String: UIImage] = [:]