//
//  UserstreamAPIClientTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import XCTest

class UserstreamAPIClientTests: XCTestCase {
    func testConvertUTCTime() {
        let streamDateString = "Tue Feb 24 18:49:01 +0000 2015"
        let utcDateString = UserstreamAPIClient.convertUTCTime(streamDateString)
        XCTAssertEqual(utcDateString, "2015-02-24 18:49", "userstream time convert should success")
    }
    
    func testConvertMedia() {
        var mediaDictionary = NSDictionary(dictionary: ["media_url" : "http://whalebird.org"])
        var mediaArray = NSArray(array: [mediaDictionary])
        var entitiesDictionary = NSDictionary(dictionary: ["media" : mediaArray])
        var streamDictionary = NSMutableDictionary(dictionary: ["entities" : entitiesDictionary])
        var resultMediaArray = NSArray(array: ["http://whalebird.org"])
        
        let convertMedia = UserstreamAPIClient.convertMedia(streamDictionary)
        XCTAssertEqual(convertMedia.objectForKey("media") as! NSArray, resultMediaArray, "media url should fixed")
    }
    
    func testConvertRetweet() {
        var originalUserDictionary = NSDictionary(dictionary: [
            "name" : "test name",
            "screen_name" : "test_screen_name",
            "profile_image_url" : "http://whalebird.org/original"
            ])
        var originalDictionary = NSDictionary(dictionary: [
            "text" : "test text",
            "created_at" : "Tue Feb 24 18:49:01 +0000 2015",
            "user" : originalUserDictionary
            ])
        var retweetUserDictionary = NSDictionary(dictionary: [
            "name" : "retweet name",
            "screen_name" : "retweet_screen_name",
            "profile_image_url" : "http://whalebird.org/retweet"
            ])
        var retweetDictionary = NSMutableDictionary(dictionary: [
            "text" : "RT test text",
            "created_at" : "Wed Feb 25 18:49:01 +0000 2015",
            "user" : retweetUserDictionary,
            "retweeted_status" : originalDictionary
            ])
        
        let convertRetweet = UserstreamAPIClient.convertRetweet(retweetDictionary)
        XCTAssertEqual(convertRetweet.objectForKey("text") as! String, "test text", "retweeted original text should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("created_at") as! String, "2015-02-24 18:49", "retweeted original created_at should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("user")?.objectForKey("name") as! String, "test name", "retweeted original name should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("user")?.objectForKey("screen_name") as! String, "test_screen_name", "retweeted original screen_name should should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("user")?.objectForKey("profile_image_url") as! String, "http://whalebird.org/original", "retweeted original profile image should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("retweeted")?.objectForKey("name") as! String, "retweet name", "retweeted name should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("retweeted")?.objectForKey("screen_name") as! String, "retweet_screen_name", "retweeted screen_name should fixed")
        XCTAssertEqual(convertRetweet.objectForKey("retweeted")?.objectForKey("profile_image_url") as! String, "http://whalebird.org/retweet", "retweeted profile image should fixed")
    }
}
