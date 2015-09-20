//
//  FriendsListTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/20.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

// TODO: 時間関連のテストはTimeCamouflageができてから
class FriendsListTests: XCTestCase {
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func setUp() {
        super.setUp()
        self.userDefaults.removeObjectForKey("failed_date")
        self.userDefaults.removeObjectForKey("success_date")
        FriendsList.sharedClient.friendsList = []
        FriendsList.sharedClient.saveFriendsInCache()
        FriendsList.sharedClient.friendsList = [
            "h3_poteto",
            "poteto_szbh"
        ]
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchFriends() {
        FriendsList.sharedClient.searchFriends("t") { (friends) -> Void in
            XCTAssertEqual(friends, [], "'t' should not match friends list")
        }
        FriendsList.sharedClient.searchFriends("h") { (friends) -> Void in
            XCTAssertEqual(friends, ["h3_poteto"], "'h' should match h3_poteto")
        }
        FriendsList.sharedClient.searchFriends("po") { (friends) -> Void in
            XCTAssertEqual(friends, ["poteto_szbh"], "'po' should match poteto_szbh")
        }
    }
    
    func testSaveAndLoadFriendsInCache() {
        FriendsList.sharedClient.saveFriendsInCache()
        let friends = FriendsList.sharedClient.loadFriendsFromCache()
        XCTAssertEqual(friends, ["h3_poteto", "poteto_szbh"], "should save and load friends list in cache")
    }
}
