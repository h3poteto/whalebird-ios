//
//  MinuteModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/07/27.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class MinuteModel: NSObject {
    var minutesArray: Array<AnyObject> = []
    
    override init() {
        super.init()
        var userDefault = NSUserDefaults.standardUserDefaults()
        if var readMinutesArray = userDefault.objectForKey("minutesArray") as? Array<AnyObject> {
            self.minutesArray = readMinutesArray
        }
    }
    
    func count()-> Int {
        return self.minutesArray.count
    }
    
    func getMinuteAtIndex(index: Int)-> NSDictionary? {
        return self.minutesArray[index] as? NSDictionary
    }
    
    func saveMinuteAtIndex(index: Int) {
        var userDefault = NSUserDefaults.standardUserDefaults()
        self.minutesArray.removeAtIndex(index)
        userDefault.setObject(self.minutesArray, forKey: "minutesArray")
    }
    
    func addMinuteAtFirst(body: String!, replyToID: String?) {
        var minuteDictionary = NSMutableDictionary(dictionary: ["text" : body])
        if (replyToID != nil) {
            minuteDictionary.setValue(replyToID!, forKey: "replyToID")
        }
        self.minutesArray.insert(minuteDictionary, atIndex: 0)
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(self.minutesArray, forKey: "minutesArray")
    }
}
