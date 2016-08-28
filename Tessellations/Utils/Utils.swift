//
//  Utils.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import Foundation
import Darwin // needed to get M_PI
import SpriteKit

extension UInt8 {
    func forEachBit(callback: (bit: UInt, flag: Bool) -> Void) {
        for i: UInt in 0..<8 {
            callback(bit: i, flag: self & UInt8(1 << i) != 0)
        }
    }
}

struct RowCol: Hashable, Equatable {
    var row: Int
    var col: Int
    
    var hashValue: Int {
        get {
            return row.hashValue &* 31 &+ col.hashValue
        }
    }
}

func ==(lhs: RowCol, rhs: RowCol) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

struct Duplet<A: Hashable, B: Hashable>: Hashable {
    let one: A
    let two: B
    
    var hashValue: Int {
        return one.hashValue ^ two.hashValue
    }
    
    init(_ one: A, _ two: B) {
        self.one = one
        self.two = two
    }
}

func ==<A, B> (lhs: Duplet<A, B>, rhs: Duplet<A, B>) -> Bool {
    return lhs.one == rhs.one && lhs.two == rhs.two
}


extension Double {
    public var degrees: Double { return self * M_PI / 180 }
    public var radians: Double { return self * 180 / M_PI }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    subscript(i: UInt) -> Element {
        get {
            return self[Int(i)]
        } set(from) {
            self[Int(i)] = from
        }  
    }
}

class UnionFind {
    var parent: UnionFind?
    
    func addToSet(set: UnionFind) {
        if self.parent == nil {
            self.parent = set
        } else {
            self.parent?.addToSet(set)
        }
    }
    
    func root() -> UnionFind {
        if self.parent == nil {
            return self
        } else {
            return self.parent!.root()
        }
    }
    
    class func areEqualSets(one one: UnionFind, two: UnionFind) -> Bool {
        return ObjectIdentifier(one.root()) == ObjectIdentifier(two.root())
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

class Pool<T> {
    var thePool: Array<T> = []
    
    func getItem() -> T? {
        if thePool.count > 0 {
            return thePool.popLast()!
        }
        return nil
    }
    
    func giveItem(item: T) {
        thePool.append(item)
    }
}