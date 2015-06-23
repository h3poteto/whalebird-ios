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
    var friendsList: Array<Int>?
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override init() {
        super.init()
    }
    
    func saveFirendsInCache() {
        if let screen_name = self.userDefaults.stringForKey("username") {
            let params: Dictionary<String, AnyObject> = [
                "screen_name" : screen_name,
                "count" : 5000
            ]
            let parameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/friend_ids.json", params: parameter) { (aFollows) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    if let ids = aFollows["ids"] as? Array<Int> {
                        self.friendsList = ids
                        self.userDefaults.setObject(self.friendsList, forKey: "friend_ids")
                    }
                })
            }
        }
    }
    
    func getFriendsFromCache() -> Array<Int>? {
        if let friends = self.friendsList {
            return friends
        } else {
            if let friends = self.userDefaults.arrayForKey("friend_ids") as? Array<Int> {
                return friends
            }
            return nil
        }
    }
}
