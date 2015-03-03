//
//  BigIntegerTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//
import UIKit
import XCTest

class BigIntegerTests: XCTestCase {
    func testDecrement() {
        let zeroNum: String = "572673378139545600"
        let nextZeroID: String = BigInteger(string: zeroNum).decrement()
        XCTAssertEqual(nextZeroID, "572673378139545599", "decrement success")
        
        let normalNum: String = "572673378139545605"
        let nextNormalID: String = BigInteger(string: normalNum).decrement()
        XCTAssertEqual(nextNormalID, "572673378139545604", "decrement success")
    }

}
