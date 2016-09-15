//
//  StreamListTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/21.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

class StreamListTests: XCTestCase {
    let userDefaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        self.userDefaults.removeObject(forKey: "streamList")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitWithEmptyCache() {
        let streamList = StreamList()
        XCTAssertEqual(streamList.lists[0].name, "送信済みツイート", "initial stream list should contain myself")
        XCTAssertEqual(streamList.lists[1].name, "お気に入り", "initial stream list should contain favorite")
    }
 
    func testSaveStreamList() {
        let streamList = StreamList()
        streamList.addNewStream("", name: "szbh", type: "list", uri: "", id: "")
        
        XCTAssertEqual(streamList.lists[2].name, "szbh", "should add new stream")
        
        streamList.saveStreamList()
        let newStreamList = StreamList()
        XCTAssertEqual(newStreamList.lists[2].name, "szbh", "should save new stream")
    }

    func testMoveStreamAtIndex() {
        let streamList = StreamList()
        streamList.moveStreamAtIndex(0, toIndex: 1)
        XCTAssertEqual(streamList.lists[0].name, "お気に入り", "should exchange stream")
        XCTAssertEqual(streamList.lists[1].name, "送信済みツイート", "should exchange stream")
    }
}
