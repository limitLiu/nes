//
//  CPU.swift
//  nes
//
//  Created by limit on 2022/11/4.
//

import Foundation

class CPU {
    var a: UInt8 = 0
    var x: UInt8 = 0
    var y: UInt8 = 0
    var status: Flag = Flag(rawValue: 0b0010_0100)
    var sp: UInt8 = 0
    var pc: UInt16 = 0
}

extension CPU {
    func interpret(program: [UInt8]) {
        pc = 0
        while true {
            let code = program[Int(pc)]
            pc += 1
            switch code {
            case 0x00:
                return
            case 0xa9:
                let param = program[Int(pc)]
                pc += 1
                a = param
                status.set(other: .Z, condition: a == 0)
                status.set(other: .N, condition: a >> 7 == 1)
            default:
                break
            }
        }
    }
}

extension CPU {
    func reset() {
        a = 0
        x = 0
        y = 0
        status = Flag(rawValue: 0b0010_0100)
        sp = 0
        pc = 0
    }
}
