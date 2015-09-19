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
@testable import Whalebird

class ApplicationSecretsTests: XCTestCase {
    func testEncryptData() {
        let ApplicationPlain = ApplicationSecrets.ApplicationPlain
        let plainData = ApplicationPlain.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var encodeBase: NSData?

        do {
            let encryptData = try RNEncryptor.encryptData(plainData, password: "whalebird")
            encodeBase = encryptData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions())
            XCTAssertNotNil(encodeBase, "encodeBase should not nil")
        } catch {
            XCTFail("encryptData should not nil")
        }
    }
}
