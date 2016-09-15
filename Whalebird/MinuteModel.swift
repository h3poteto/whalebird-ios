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
        let userDefault = UserDefaults.standard
        if let readMinutesArray = userDefault.object(forKey: "minutesArray") as? Array<NSDictionary> {
            self.minutesArray = readMinutesArray
        }
    }
    
    func count()-> Int {
        return self.minutesArray.count
    }
    
    func getMinuteAtIndex(_ index: Int)-> NSDictionary? {
        return self.minutesArray[index]
    }
    
    func removeAtIndexAndSaveList(_ index: Int) {
        let userDefault = UserDefaults.standard
        self.minutesArray.remove(at: index)
        userDefault.set(self.minutesArray, forKey: "minutesArray")
    }
    
    func addMinuteAtFirst(_ body: String!, replyToID: String?) {
        let minuteDictionary = NSMutableDictionary(dictionary: ["text" : body])
        if (replyToID != nil) {
            minuteDictionary.setValue(replyToID!, forKey: "replyToID")
        }
        self.minutesArray.insert(minuteDictionary, at: 0)
        let userDefault = UserDefaults.standard
        userDefault.set(self.minutesArray, forKey: "minutesArray")
    }
    
    func deleteMinuteAtIndex(_ index: Int!) {
        self.minutesArray.remove(at: index)
        let userDefault = UserDefaults.standard
        userDefault.set(self.minutesArray, forKey: "minutesArray")
    }
}
