//
//  TimelineModelTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/21.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

class TimelineModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TagsList.sharedClient.getTagsList()
        TagsList.sharedClient.tagsList = []
        TagsList.sharedClient.saveTagsListInCache()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let firstTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234545"])
        let secondTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234567"])
        let array = [
            firstTweetDictionary,
            secondTweetDictionary
        ]
        let timelineModel = TimelineModel(initSinceId: "345678", initTimeline: array)
        XCTAssertEqual(timelineModel.sinceId, "345678", "sinceID should be stored")
        let moreDictionary = NSDictionary(dictionary: ["moreID" : "234545", "sinceID" : "sinceID"])
        XCTAssertEqual(timelineModel.currentTimeline.last as? NSDictionary, moreDictionary, "should insert more dictionary at last")
    }
    
    func testGetTweetAtIndex() {
        let firstTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234545", "text" : "あすみんぺろぺろ"])
        let secondTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234567", "text" : "いぇす！あすみす！ #阿澄病"])
        let array = [
            firstTweetDictionary,
            secondTweetDictionary
        ]
        let timelineModel = TimelineModel()
        timelineModel.currentTimeline = array
        let firstTweet = timelineModel.getTweetAtIndex(0)
        XCTAssertEqual(firstTweet!["id_str"] as? String, "234545", "should get tweet")
        XCTAssertEqual(TagsList.sharedClient.tagsList!, [], "tags list should empty array")
        
        let secondTweet = timelineModel.getTweetAtIndex(1)
        XCTAssertEqual(secondTweet!["id_str"] as? String, "234567", "should get tweet")
        XCTAssertEqual(TagsList.sharedClient.tagsList!, ["阿澄病"], "tags list should have 阿澄病")
        
    }
    
    func testSaveCurrentTimeline() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("timeline")
        userDefaults.removeObjectForKey("sinceID")
        let firstTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234545", "text" : "あすみんぺろぺろ"])
        let secondTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234567", "text" : "いぇす！あすみす！ #阿澄病"])
        let array = [
            firstTweetDictionary,
            secondTweetDictionary
        ]
        let timelineModel = TimelineModel()
        timelineModel.currentTimeline = array
        timelineModel.sinceId = "234567"
        timelineModel.saveCurrentTimeline("timeline", sinceIdKey: "sinceID")
        let timeline = userDefaults.objectForKey("timeline") as? Array<NSMutableDictionary>
        XCTAssertEqual(userDefaults.stringForKey("sinceID"), "234567", "should save sinceID")
        XCTAssertEqual(timeline!, array.reverse(), "should save timeline")
    }
    
    func testFavorite() {
        let firstTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234545", "text" : "あすみんぺろぺろ", "favorited?" : 0])
        let secondTweetDictionary = NSMutableDictionary(dictionary: ["id_str" : "234567", "text" : "いぇす！あすみす！ #阿澄病", "favorited?" : 0])
        let array = [
            firstTweetDictionary,
            secondTweetDictionary
        ]
        let timelineModel = TimelineModel()
        timelineModel.currentTimeline = array
        timelineModel.addFavorite(0)
        XCTAssertEqual(timelineModel.currentTimeline[0].objectForKey("favorited?") as? Int, 1, "favorited flag should change")
        timelineModel.deleteFavorite(0)
        XCTAssertEqual(timelineModel.currentTimeline[0].objectForKey("favorited?") as? Int, 0, "favorited flag should change")
    }
}
