//
//  OriginalCrypTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
import RNCryptor
@testable import Whalebird

class ApplicationSecretsTests: XCTestCase {
    func testEncryptData() {
        let ApplicationPlain = ApplicationSecrets.ApplicationPlain
        let plainData = ApplicationPlain.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        var encodeBase: Data?

        do {
            let encryptData = try RNEncryptor.encryptData(plainData, password: "whalebird")
            encodeBase = encryptData.base64EncodedData(options: .endLineWithLineFeed)
            XCTAssertNotNil(encodeBase, "encodeBase should not nil")
        } catch {
            XCTFail("encryptData should not nil")
        }
    }
}
