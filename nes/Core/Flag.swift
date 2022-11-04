//
//  Flag.swift
//  nes
//
//  Created by limit on 2022/11/4.
//

import Foundation

struct Flag: OptionSet {
    static let C = Flag(rawValue: 0b0000_0001) // 1 << 0
    static let Z = Flag(rawValue: 0b0000_0010) // 1 << 1
    static let I = Flag(rawValue: 0b0000_0100) // 1 << 2
    static let D = Flag(rawValue: 0b0000_1000) // 1 << 3
    static let B = Flag(rawValue: 0b0001_0000) // 1 << 4
    static let U = Flag(rawValue: 0b0010_0000) // 1 << 5
    static let V = Flag(rawValue: 0b0100_0000) // 1 << 6
    static let N = Flag(rawValue: 0b1000_0000) // 1 << 7
    
    internal var rawValue: UInt8 = 0
    
    init(rawValue flag: UInt8) {
        rawValue = flag
    }
    
    func bits() -> UInt8 {
        rawValue
    }
}

extension Flag {
    mutating func insert(other: Flag) {
        rawValue |= other.bits()
    }
    
    mutating func remove(other: Flag) {
        rawValue &= (~other.bits())
    }
    
    mutating func set(other: Flag, condition: Bool) {
        if condition {
            insert(other)
        } else {
            remove(other)
        }
    }
}
