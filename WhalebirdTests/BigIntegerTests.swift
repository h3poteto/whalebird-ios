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
        let tweetID: String = "12345678987654321"
        let nextTweetID: String = BigInteger(string: tweetID).decrement()
        XCTAssertEqual(nextTweetID, "12345678987654320", "decrement success")
    }

}
