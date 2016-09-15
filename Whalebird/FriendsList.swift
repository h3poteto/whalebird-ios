//
//  FirendsList.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/06/23.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class FriendsList: NSObject {
    
    // シングルトンにするよ
    // 取得した直後に保存できているわけではないのでシングルトンにして，fridensListを永続化させる．クラス初期化のコストが無駄．
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
    var userDefaults: UserDefaults = UserDefaults.standard
    var utcDateFormatter = DateFormatter()
    
    override init() {
        super.init()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        self.utcDateFormatter.calendar = calendar
        self.utcDateFormatter.dateStyle = DateFormatter.Style.long
        self.utcDateFormatter.timeStyle = DateFormatter.Style.none
        self.utcDateFormatter.dateFormat = "yyyyMMdd"
        self.utcDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.friendsList = self.loadFriendsFromCache()
    }
    
    func loadFriendsFromCache() -> Array<String> {
        if let friends = self.userDefaults.array(forKey: "friend_screen_names") as? Array<String> {
            return friends
        } else {
            return []
        }
    }
    
    // requestする必要があればtrueを返す
    func checkRequestResult() -> Bool {
        let current = Date(timeIntervalSinceNow: 0)
        // 和暦の場合は強制的に西暦に治す
        let today = self.utcDateFormatter.string(from: current)
        
        if let _ = self.userDefaults.string(forKey: "failed_date") {
            return true
        } else {
            if let successDateStr = self.userDefaults.string(forKey: "success_date") {
                // successから1週間経っていればリトライさせたい
                if Int(today)! - Int(successDateStr)! > 7 {
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
        let current = Date(timeIntervalSinceNow: 0)
        let today = self.utcDateFormatter.string(from: current)
        self.userDefaults.set(today, forKey: "failed_date")
        self.userDefaults.removeObject(forKey: "success_date")
    }
    
    func setSuccessRequestCache() {
        let current = Date(timeIntervalSinceNow: 0)
        let today = self.utcDateFormatter.string(from: current)
        self.userDefaults.set(today, forKey: "success_date")
        self.userDefaults.removeObject(forKey: "failed_date")
    }
    
    func requestFriends() {
        // check cache
        if !self.checkRequestResult() {
            return
        }
        if let screen_name = self.userDefaults.string(forKey: "username") {
            let params: Dictionary<String, AnyObject> = [
                "screen_name" : screen_name as AnyObject,
                "count" : 5000 as AnyObject
            ]
            let parameter: Dictionary<String, AnyObject> = [
                "settings" : params as AnyObject
            ]
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/friend_screen_names.json", displayError: false, params: parameter, completed: { (aFollows) -> Void in
                let screen_names = aFollows as Array<AnyObject>
                self.friendsList = []
                for name in screen_names {
                    self.friendsList?.append((name.object(forKey: "screen_name") as! String))
                }
                self.saveFriendsInCache()
                self.setSuccessRequestCache()
            }, failed: { () -> Void in
                self.setFailedRequestCache()
            })
        }
    }
    
    func saveFriendsInCache() {
        self.userDefaults.set(self.friendsList, forKey: "friend_screen_names")
    }
    
    func searchFriends(_ screen_name: String, callback:(Array<String>) -> Void) {
        if screen_name.characters.count > 0 {
            if let list = self.friendsList {
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
