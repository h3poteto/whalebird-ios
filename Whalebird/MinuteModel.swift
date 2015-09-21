//
//  MinuteModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/07/27.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class MinuteModel: NSObject {
    var minutesArray: Array<NSDictionary> = []
    
    override init() {
        super.init()
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let readMinutesArray = userDefault.objectForKey("minutesArray") as? Array<NSDictionary> {
            self.minutesArray = readMinutesArray
        }
    }
    
    func count()-> Int {
        return self.minutesArray.count
    }
    
    func getMinuteAtIndex(index: Int)-> NSDictionary? {
        return self.minutesArray[index]
    }
    
    func removeAtIndexAndSaveList(index: Int) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        self.minutesArray.removeAtIndex(index)
        userDefault.setObject(self.minutesArray, forKey: "minutesArray")
    }
    
    func addMinuteAtFirst(body: String!, replyToID: String?) {
        let minuteDictionary = NSMutableDictionary(dictionary: ["text" : body])
        if (replyToID != nil) {
            minuteDictionary.setValue(replyToID!, forKey: "replyToID")
        }
        self.minutesArray.insert(minuteDictionary, atIndex: 0)
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(self.minutesArray, forKey: "minutesArray")
    }
    
    func deleteMinuteAtIndex(index: Int!) {
        self.minutesArray.removeAtIndex(index)
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(self.minutesArray, forKey: "minutesArray")
    }
}
