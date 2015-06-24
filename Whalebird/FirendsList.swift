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
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/friend_screen_names.json", params: parameter) { (aFollows) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    if let screen_names = aFollows as? Array<AnyObject> {
                        for name in screen_names {
                            self.friendsList?.append((name.objectForKey("screen_name") as! String))
                        }
                        self.userDefaults.setObject(self.friendsList, forKey: "friend_screen_names")
                    }
                })
            }
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
}
