//
//  WhalebirdAPIClientTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import XCTest
@testable import Whalebird

class WhalebirdAPIClientTests: XCTestCase {
    
    func testConvertLocalTime() {
        let utcTimeString = "2015-02-24 18:11"
        let jstTimeString = WhalebirdAPIClient.convertLocalTime(utcTimeString)
        XCTAssertEqual(jstTimeString, "02月25日 03:11", "convert local time should success")
    }
    
    func testEscapeString() {
        let specialString = "5&gt;1&amp;&amp;109&lt;290&quot;"
        let escapedString = WhalebirdAPIClient.escapeString(specialString)
        XCTAssertEqual(escapedString, "5>1&&109<290\"", "escape special string should success")
    }
    
    func testCleanDictionary() {
        let nullDictionary = NSMutableDictionary(dictionary: [
            "nullObject" : NSNull(),
            "intObject" : 1
            ])
        let nullChildDictionary = NSMutableDictionary(dictionary: [
            "intObject" : 2,
            "nullObject" : NSNull()
            ])
        nullDictionary.setValue(nullChildDictionary, forKey: "childDictionary")
        
        let notNullDictionary = WhalebirdAPIClient.sharedClient.cleanDictionary(nullDictionary)
        
        XCTAssertEqual(notNullDictionary.objectForKey("intObject") as? Int, 1, "int object should not touch")
        XCTAssertEqual(notNullDictionary.objectForKey("nullObject") as? String, "", "null objecct should convert string")
        XCTAssertEqual(notNullDictionary.objectForKey("childDictionary")?.objectForKey("intObject") as? Int, 2, "int object should not touch")
        XCTAssertEqual(notNullDictionary.objectForKey("childDictionary")?.objectForKey("nullObject") as? String, "", "null object should convert string")
        
    }
    
    func testEncodeClipboardURL() {
        let urlString = "http://ja.wikipedia.org/wiki/阿澄佳奈"
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.setValue(urlString, forPasteboardType: "public.text")
        WhalebirdAPIClient.encodeClipboardURL()
        XCTAssertNotNil(pasteboard.valueForPasteboardType("public.text"), "pasteboard shoud not empty")
        if let encodedURL = pasteboard.valueForPasteboardType("public.text") as? String {
            XCTAssertEqual(encodedURL, "http://ja.wikipedia.org/wiki/%E9%98%BF%E6%BE%84%E4%BD%B3%E5%A5%88", "japanese url should encode and store pasteboard")
        }
        
    }

}
