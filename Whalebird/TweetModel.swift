//
//  TweetModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/08/05.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class TweetModel: NSObject {
    var tweetID: String!
    var tweetBody: String!
    var screenName: String!
    var userName: String!
    var postDetail: String!
    var profileImage: String!
    var retweetedName: String?
    var retweetedProfileImage: String?
    var fFavorited: Bool!
    var media: Array<String>?
    var fProtected: Bool!
    
    
    init(dict: NSDictionary) {
        super.init()
        self.tweetID = dict.objectForKey("id_str") as! String
        self.tweetBody = dict.objectForKey("text")as! String
        self.screenName = dict.objectForKey("user")?.objectForKey("screen_name") as! String
        self.userName = dict.objectForKey("user")?.objectForKey("name") as! String
        self.profileImage = dict.objectForKey("user")?.objectForKey("profile_image_url") as! String
        self.postDetail = dict.objectForKey("created_at") as! String
        self.retweetedName = dict.objectForKey("retweeted")?.objectForKey("screen_name") as? String
        self.retweetedProfileImage = dict.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String
        self.fFavorited = optionalToBool(dict.objectForKey("favorited?") as? Bool)
        self.media = dict.objectForKey("media") as? Array<String>
        self.fProtected = optionalToBool(dict.objectForKey("user")?.objectForKey("protected?") as? Bool)
    }
    
    init (notificationDict: [NSObject : AnyObject]) {
        super.init()
        self.tweetID = notificationDict["id"] as! String
        self.tweetBody = notificationDict["text"] as! String
        self.screenName = notificationDict["screen_name"] as! String
        self.userName = notificationDict["name"] as! String
        self.profileImage = notificationDict["profile_image_url"] as! String
        self.postDetail = notificationDict["created_at"] as! String
        self.fFavorited = optionalToBool(notificationDict["favorited"] as? Bool)
        self.media = notificationDict["media"] as? Array<String>
        self.fProtected = optionalToBool(notificationDict["protected"] as? Bool)
    }
    
    func optionalToBool(flag: Bool?) -> Bool {
        if flag != nil {
            return flag!
        } else {
            return false
        }
    }
    
}
