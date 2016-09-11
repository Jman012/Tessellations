//
//  Globals.swift
//  Tessellations
//
//  Created by James Linnell on 8/24/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

let kThumbnailImageDidChange = "ThumbnailImageDidChange"
let kPaletteDidChange = "PaletteDidChange"
let kClassString = "ClassString"

let kCameraZoomIn:CGFloat = 0.6
let kCameraZoomOut: CGFloat = 1.0

let sceneClassStrings: [String] = [
    NSStringFromClass(TriangleScene.self),
    NSStringFromClass(SquareScene.self),
    NSStringFromClass(HexagonScene.self),
    NSStringFromClass(OctagonSquareScene.self),
    NSStringFromClass(SquareTriangleScene.self),
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

func setNewThumbnailImage(image: UIImage, forClassString classString: String) {
    thumbnailImages[classString] = image
    NSNotificationCenter.defaultCenter().postNotificationName(kThumbnailImageDidChange, object: nil, userInfo: [kClassString: classString])
}