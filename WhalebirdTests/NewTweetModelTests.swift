//
//  NewTweetModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/19.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

class NewTweetModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindTagRange() {
        let newTweetModel = NewTweetModel()
        // 先にtagリストを登録しておく必要がある
        newTweetModel.findTagRange(
            "",
            text: "#",
            range: NSRange(location: 0, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'#' should not call select")
            
            }, completeFindText: { (tags) -> Void in
                XCTFail("'#' should not find tags")
                
        })
        newTweetModel.findTagRange("#", text: "a", range: NSRange(location: 1, length: 0), finishSelect: { () -> Void in
                XCTFail("'a' should not call select")
            }, completeFindText: { (tags) -> Void in
                
        })
        
    }
    
}
