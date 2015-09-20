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
        TagsList.sharedClient.loadTagsListFromCache()
        TagsList.sharedClient.tagsList = []
        TagsList.sharedClient.saveTagsListInCache()
        TagsList.sharedClient.tagsList = [
            "akirafukushima",
            "akira",
            "あきら",
            "阿澄病"
        ]
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindTagRange() {
        let newTweetModel = NewTweetModel()
        newTweetModel.findTagRange(
            "",
            text: "#",
            range: NSRange(location: 0, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'#' should not call finish")
            
            }, completeFindText: { (tags) -> Void in
                XCTFail("'#' should not find tags")
                
        })
        newTweetModel.findTagRange(
            "#",
            text: "a",
            range: NSRange(location: 1, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'a' should not call finish")
            }, completeFindText: { (tags) -> Void in
                XCTAssertEqual(tags, ["akirafukushima", "akira"], "should find right tags")
        })
        newTweetModel.findTagRange(
            "#a",
            text: "k",
            range: NSRange(location: 2, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'k' should not call finish")
            }) { (tags) -> Void in
                XCTAssertEqual(tags, ["akirafukushima", "akira"], "should find right tags")
        }
        newTweetModel.findTagRange(
            "#ak",
            text: " ",
            range: NSRange(location: 3, length: 0),
            finishSelect: { () -> Void in
                // ここは呼ばれてOK
            }) { (tags) -> Void in
                XCTFail("space should not call complete")
        }
        
    }
    
    func testFindTagRangeWithJapanese() {
        let newTweetModel = NewTweetModel()
        newTweetModel.findTagRange(
            "",
            text: "#",
            range: NSRange(location: 0, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'#' should not call finish")
                
            }, completeFindText: { (tags) -> Void in
                XCTFail("'#' should not find tags")
                
        })
        newTweetModel.findTagRange(
            "#",
            text: "あ",
            range: NSRange(location: 1, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'a' should not call finish")
            }, completeFindText: { (tags) -> Void in
                XCTAssertEqual(tags, ["あきら"], "should find right tags")
        })
        newTweetModel.findTagRange(
            "#",
            text: "あす",
            range: NSRange(location: 1, length: 1),
            finishSelect: { () -> Void in
                XCTFail("'k' should not call finish")
            }) { (tags) -> Void in
                XCTAssertEqual(tags, [], "should find right tags")
        }
        newTweetModel.findTagRange(
            "#",
            text: "阿澄",
            range: NSRange(location: 1, length: 1),
            finishSelect: { () -> Void in
                XCTFail("'k' should not call finish")
            }) { (tags) -> Void in
                XCTAssertEqual(tags, ["阿澄病"], "should find right tags")
        }
        newTweetModel.findTagRange(
            "#",
            text: "　",
            range: NSRange(location: 3, length: 0),
            finishSelect: { () -> Void in
                // ここは呼ばれてOK
            }) { (tags) -> Void in
                XCTFail("space should not call complete")
        }
    }
    
    func testFindScreenNameRange() {
        let newTweetModel = NewTweetModel()
        newTweetModel.findScreenNameRange(
            "",
            text: "@",
            range: NSRange(location: 0, length: 0),
            finishSelect: { () -> Void in
                XCTFail("'@' should not call finish")
            }) { (screenNames) -> Void in
                XCTFail("'@' should not find screen names")
        }
    }
    
}
