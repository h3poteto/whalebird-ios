//
//  MinuteModelTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/09/21.
//  Copyright © 2015年 AkiraFukushima. All rights reserved.
//

import XCTest
@testable import Whalebird

class MinuteModelTests: XCTestCase {
    let userDefaults = NSUserDefaults.standardUserDefaults()

    override func setUp() {
        super.setUp()
        self.userDefaults.removeObjectForKey("minutesArray")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let minuteDictionary = NSMutableDictionary(dictionary: ["text" : "阿澄佳奈"])
        var array: Array<NSMutableDictionary> = []
        array.insert(minuteDictionary, atIndex: 0)
        self.userDefaults.setObject(array, forKey: "minutesArray")
        let minuteModel = MinuteModel()
        
        XCTAssertEqual(minuteModel.minutesArray, array, "init should load minutesArray from cache")
    }
    
    func testRemoveAtIndexAndSaveList() {
        let asumiDictionary = NSMutableDictionary(dictionary: ["text" : "阿澄佳奈"])
        var array: Array<NSMutableDictionary> = []
        array.insert(asumiDictionary, atIndex: 0)
        let shintaniDictionary = NSMutableDictionary(dictionary: ["text" : "新谷良子"])
        array.insert(shintaniDictionary, atIndex: 0)
        
        let minuteModel = MinuteModel()
        minuteModel.minutesArray = array
        minuteModel.removeAtIndexAndSaveList(0)

        let newMinuteModel = MinuteModel()
        if let minutes = self.userDefaults.arrayForKey("minutesArray") as? Array<NSDictionary> {
            XCTAssertEqual(minutes, newMinuteModel.minutesArray, "remove and save minute list")
        } else {
            XCTFail("should not fail cast array")
        }
    }

    func testAddMinuteAtFirst() {
        let minuteModel = MinuteModel()
        minuteModel.addMinuteAtFirst("佐倉綾音", replyToID: nil)
        let ayaneruDictionary = NSMutableDictionary(dictionary: ["text" : "佐倉綾音"])
        var array: Array<NSMutableDictionary> = []
        array.insert(ayaneruDictionary, atIndex: 0)
        
        XCTAssertEqual(minuteModel.minutesArray, array, "should add new minute")
        
        minuteModel.addMinuteAtFirst("阿澄佳奈", replyToID: "123456")
        let asumiDictionary = NSMutableDictionary(dictionary: [
            "text" : "阿澄佳奈",
            "replyToID" : "123456"
        ])
        array.insert(asumiDictionary, atIndex: 0)
        
        XCTAssertEqual(minuteModel.minutesArray, array, "should add new minute and replyToID")
    }

    func testDeleteMinuteAtIndex() {
        let minuteModel = MinuteModel()
        minuteModel.addMinuteAtFirst("佐倉綾音", replyToID: nil)
        minuteModel.addMinuteAtFirst("新谷良子", replyToID: "123456")
        let ayaneruDictionary = NSMutableDictionary(dictionary: ["text" : "佐倉綾音"])
        var array: Array<NSMutableDictionary> = []
        array.insert(ayaneruDictionary, atIndex: 0)
        minuteModel.deleteMinuteAtIndex(0)
        
        XCTAssertEqual(minuteModel.minutesArray, array, "should delete minute")
    }
}
