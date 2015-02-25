//
//  OriginalCrypTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import XCTest

class OriginalCrypTests: XCTestCase {
    func testEncryptData() {
        let ApplicationPlain = WHALEBIRD_APPLICATION_KEY as NSString
        var plainData = ApplicationPlain.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error = NSError?()
        var encryptData: NSData?
        var encodeBase: NSData?
        encryptData = OriginalCryp.encryptData(plainData, password: "whalebird", error: &error)
        XCTAssertNotNil(encryptData, "encryptData not nil")
        if (encryptData != nil) {
            encodeBase = encryptData!.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.allZeros)
            XCTAssertNotNil(encodeBase, "encodeBase not nil")
        } else {
            XCTFail("cannot encryptData")
        }

        
    }
}
