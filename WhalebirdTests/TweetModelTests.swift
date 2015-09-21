//
//  TweetModelTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/21.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

class TweetModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCheckScreenName() {
        XCTAssertTrue(TweetModel.checkScreenName("_"), "should judge '_' as screen name")
        XCTAssertTrue(TweetModel.checkScreenName("h"), "should judge 'h' as screen name")
        XCTAssertFalse(TweetModel.checkScreenName("@"), "should not judge '@' as screen name")
        XCTAssertFalse(TweetModel.checkScreenName("#"), "should not judge '#' as screen name")
        
    }

    func testListUpSentence() {
        // screen name
        XCTAssertEqual(TweetModel.listUpSentence("@h3_poteto 阿澄病なう", startCharacter: "@", fScreenName: true), ["@h3_poteto"], "should pick up a screen name")
        XCTAssertEqual(TweetModel.listUpSentence("いぇっす！！@h3_poteto @poteto_szbht", startCharacter: "@", fScreenName: true), ["@h3_poteto", "@poteto_szbht"], "should pick up two screen names")
        
        // tag
        XCTAssertEqual(TweetModel.listUpSentence("@h3_poteto あすみんぺろぺろ #阿澄病", startCharacter: "#", fScreenName: false), ["#阿澄病"], "should pick up a tag")
        XCTAssertEqual(TweetModel.listUpSentence("あすみす! #あすみん #阿澄病", startCharacter: "#", fScreenName: false), ["#あすみん", "#阿澄病"], "should pick up two tags")
    }
    
    func testMediaIsGif() {
        XCTAssertTrue(TweetModel.mediaIsGif("asumiss.mp4"))
        XCTAssertFalse(TweetModel.mediaIsGif("asumiss.png"))
    }
    
    func testReplyList() {
        let notificationDict = [
            "id" : "1234567",
            "text" : "@h3_poteto @poteto_szbh あすみんぺろぺろ!",
            "screen_name" : "asumi_syndrome",
            "name" : "阿澄病なう",
            "profile_image_url" : "https://excample.com/sample.png",
            "created_at" : "2015-02-24 18:11"
        ]
        let tweetModel = TweetModel(notificationDict: notificationDict)
        XCTAssertEqual(tweetModel.replyList("h3_poteto"), "@asumi_syndrome @h3_poteto @poteto_szbh ", "should generate reply screen name list string")
        
    }
    
}
