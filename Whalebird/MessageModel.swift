//
//  MessageModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/08/07.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class MessageModel: NSObject {
    var messageID: String!
    var messageBody: String!
    var screenName: String!
    var userName: String!
    var profileImage: String!
    var postDetail: String!
    
    init(dict: [NSObject : AnyObject]) {
        super.init()
        self.messageID =  dict["id_str"] as! String
        self.messageBody =  dict["text"] as! String
        self.screenName = (dict["user"] as! [NSObject : AnyObject])["screen_name"] as! String
        self.userName = (dict["user"] as! [NSObject : AnyObject])["name"] as! String
        self.profileImage = (dict["user"] as! [NSObject : AnyObject])["profile_image_url"] as! String
        self.postDetail = WhalebirdAPIClient.convertLocalTime(dict["created_at"] as! String)
    }
    
    init(notificationDict: [NSObject : AnyObject]) {
        super.init()
        self.messageBody = notificationDict["text"] as! String
        self.messageBody = notificationDict["text"] as! String
        self.screenName = notificationDict["screen_name"] as! String
        self.userName = notificationDict["name"] as! String
        self.profileImage = notificationDict["profile_image_url"] as! String
        self.postDetail = WhalebirdAPIClient.convertLocalTime(notificationDict["created_at"] as! String)
    }
}
