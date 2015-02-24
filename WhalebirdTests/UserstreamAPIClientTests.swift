//
//  UserstreamAPIClientTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import XCTest

class UserstreamAPIClientTests: XCTestCase {
    func convertUTCTime() {
        let streamDateString = "Tue Feb 24 18:49:01 +0000 2015"
        var utcDateString = UserstreamAPIClient.convertUTCTime(streamDateString)
        
        XCTAssertEqual(utcDateString, "2015-02-14 18:49", "userstream time convert should success")
    }

}
