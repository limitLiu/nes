//
//  nesTests.swift
//  nesTests
//
//  Created by limit on 2022/11/4.
//

import XCTest
@testable import nes

final class nesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLDA() throws {
        let cpu = CPU()
        cpu.interpret(program: [0xa9, 0x00, 0x00])
        assert(cpu.status.bits() & 0b0000_0010 == 0b10)
        cpu.reset()
        cpu.interpret(program: [0xa9, 0x05, 0x00])
        assert(cpu.a == 0x05)
        assert(cpu.status.bits() & 0b0000_0010 == 0)
        assert(cpu.status.bits() & 0b1000_0000 == 0)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
