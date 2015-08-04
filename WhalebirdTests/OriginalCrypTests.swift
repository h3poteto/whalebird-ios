//
//  OriginalCrypTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import XCTest
import RNCryptor

class OriginalCrypTests: XCTestCase {
    func testEncryptData() {
        let ApplicationPlain = WHALEBIRD_APPLICATION_KEY as NSString
        var plainData = ApplicationPlain.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error = NSError?()
        var encodeBase: NSData?

        if let encryptData = RNEncryptor.encryptData(plainData, password: "whalebird", error: &error) {
            encodeBase = encryptData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.allZeros)
            XCTAssertNotNil(encodeBase, "encodeBase should not nil")
        } else {
            XCTFail("encryptData should not nil")
        }
    }
}
