//
//  FirendsList.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/06/23.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import Foundation

class FriendsList: NSObject {
    
    // シングルトンにするよ
    class var sharedClient: FriendsList {
        struct sharedStruct {
            static let _sharedClient = FriendsList()
        }
        return sharedStruct._sharedClient
    }
    
    //====================================
    //  instance variables
    //====================================
    var friendsList: Array<String>?
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var utcDateFormatter = NSDateFormatter()
    
    override init() {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        self.utcDateFormatter.calendar = calendar
        self.utcDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        self.utcDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.utcDateFormatter.dateFormat = "yyyyMMdd"
        self.utcDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    }
    
    // requestする必要があればtrueを返す
    func checkRequestResult() -> Bool {
        var current = NSDate(timeIntervalSinceNow: 0)
        // 和暦の場合は強制的に西暦に治す
        var today = self.utcDateFormatter.stringFromDate(current)
        
        if let failedDateStr = self.userDefaults.stringForKey("failed_date") {
            return true
        } else {
            if let successDateStr = self.userDefaults.stringForKey("success_date") {
                // successから1週間経っていればリトライさせたい
                if today.toInt()! - successDateStr.toInt()! > 7 {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }
    }
    
    func setFailedRequestCache() {
        var current = NSDate(timeIntervalSinceNow: 0)
        var today = self.utcDateFormatter.stringFromDate(current)
        self.userDefaults.setObject(today, forKey: "failed_date")
        self.userDefaults.removeObjectForKey("success_date")
    }
    
    func setSuccessRequestCache() {
        var current = NSDate(timeIntervalSinceNow: 0)
        var today = self.utcDateFormatter.stringFromDate(current)
        self.userDefaults.setObject(today, forKey: "success_date")
        self.userDefaults.removeObjectForKey("failed_date")
    }
    
    func saveFirendsInCache() {
        // check cache
        if !self.checkRequestResult() {
            return
        }
        if let screen_name = self.userDefaults.stringForKey("username") {
            let params: Dictionary<String, AnyObject> = [
                "screen_name" : screen_name,
                "count" : 5000
            ]
            let parameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/friend_screen_names.json", displayError: false, params: parameter, completed: { (aFollows) -> Void in
                if let screen_names = aFollows as? Array<AnyObject> {
                    self.friendsList = []
                    for name in screen_names {
                        self.friendsList?.append((name.objectForKey("screen_name") as! String))
                    }
                    self.userDefaults.setObject(self.friendsList, forKey: "friend_screen_names")
                }
                self.setSuccessRequestCache()
            }, failed: { () -> Void in
                self.setFailedRequestCache()
            })
        }
    }
    
    func getFriendsFromCache() -> Array<String>? {
        if let friends = self.friendsList {
            return friends
        } else {
            if let friends = self.userDefaults.arrayForKey("friend_screen_names") as? Array<String> {
                return friends
            }
            return nil
        }
    }
    
    func searchFriends(screen_name: String, callback:(Array<String>) -> Void) {
        if count(screen_name) > 0 {
            if let list = self.getFriendsFromCache() {
                var matchFriends:Array<String> = []
                for name in list {
                    if name.hasPrefix(screen_name) {
                        matchFriends.append(name)
                    }
                }
                callback(matchFriends)
            } else {
                callback([])
            }
        }
    }
}
