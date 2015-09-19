//
//  TagsListTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/19.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

class TagsListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        TagsList.sharedClient.getTagsList()
        TagsList.sharedClient.tagsList = []
        TagsList.sharedClient.saveTagsListInCache()
        TagsList.sharedClient.tagsList = [
            "akirafukushima",
            "akira"
        ]
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindAndAddTag() {
        var rawText = "あすみんぺろぺろ #asumiss"
        TagsList.sharedClient.findAndAddtag(rawText)
        XCTAssertNotNil(TagsList.sharedClient.tagsList)
        XCTAssertEqual(TagsList.sharedClient.tagsList!, ["akirafukushima", "akira", "asumiss"], "tag should extract and find")
        rawText = "#阿澄病　あすみん！"
        TagsList.sharedClient.findAndAddtag(rawText)
        XCTAssertEqual(TagsList.sharedClient.tagsList!, ["akirafukushima", "akira", "asumiss", "阿澄病"], "japanese tag should extract and find")
    }
    
    func testSaveTagsListInCache() {
        TagsList.sharedClient.tagsList?.append("akira")
        TagsList.sharedClient.saveTagsListInCache()
        XCTAssertEqual(TagsList.sharedClient.loadTagsListFromCache(), ["akirafukushima", "akira"], "duplicate tag should uniqueness and save in cache")
    }
    
    func testSearchTags() {
        TagsList.sharedClient.searchTags("a") { (tags) -> Void in
            XCTAssertEqual(tags, ["akirafukushima", "akira"], "search result should be right")
        }
        TagsList.sharedClient.searchTags("akiraf") { (tags) -> Void in
            XCTAssertEqual(tags, ["akirafukushima"], "search result should be right")
        }
    }
}
