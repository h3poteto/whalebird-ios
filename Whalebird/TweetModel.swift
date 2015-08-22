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
    
    
    // twitter独自のscreen name判定
    // _ はscreen nameと判定．他の文字は半角英数字のみ許可
    class func checkScreenName(aCharacter: Character) -> Bool {
        if (aCharacter == "_") {
            return true
        } else {
            // 半角全角判定
            var str = String(aCharacter)
            if (str.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false) == nil) {
                return false
            } else {
                var charSet = NSCharacterSet.alphanumericCharacterSet()
                if var aScanner = NSScanner.localizedScannerWithString(str) as? NSScanner {
                    aScanner.charactersToBeSkipped = nil
                    aScanner.scanCharactersFromSet(charSet, intoString: nil)
                    return aScanner.atEnd
                } else {
                    return false
                }
            }
        }
    }
    
    class func listUpSentence(rawString: String, startCharacter: Character) -> Array<String> {
        var targetStringList: Array<String> = []
        var tTargetString = ""
        var fFindString = false
        for char in rawString {
            if (fFindString) {
                if (char == " " || char == "　" || !TweetModel.checkScreenName(char)) {
                    targetStringList.append(tTargetString)
                    tTargetString = ""
                    fFindString = false
                } else {
                    tTargetString.append(char)
                }
            }else if (char == startCharacter) {
                tTargetString.append(char)
                fFindString = true
            }
        }
        // 末尾に入っていた場合の処理
        if fFindString {
            targetStringList.append(tTargetString)
            tTargetString = ""
            fFindString = false
        }
        return targetStringList
    }
    
    
    init(dict: [NSObject : AnyObject]) {
        super.init()
        self.tweetID = dict["id_str"] as! String
        self.tweetBody = dict["text"] as! String
        self.screenName = (dict["user"] as! [NSObject : AnyObject])["screen_name"] as! String
        self.userName = (dict["user"] as! [NSObject : AnyObject])["name"] as! String
        self.profileImage = (dict["user"] as! [NSObject : AnyObject])["profile_image_url"] as! String
        self.postDetail = WhalebirdAPIClient.convertLocalTime(dict["created_at"] as! String)
        self.retweetedName = (dict["retweeted"] as? [NSObject : AnyObject])?["screen_name"] as? String
        self.retweetedProfileImage = (dict["retweeted"] as? [NSObject : AnyObject])?["profile_image_url"] as? String
        self.fFavorited = optionalToBool(dict["favorited?"] as? Bool)
        self.media = dict["media"] as? Array<String>
        self.fProtected = optionalToBool((dict["user"] as? [NSObject : AnyObject])?["protected?"] as? Bool)
    }
    
    init (notificationDict: [NSObject : AnyObject]) {
        super.init()
        self.tweetID = notificationDict["id"] as! String
        self.tweetBody = notificationDict["text"] as! String
        self.screenName = notificationDict["screen_name"] as! String
        self.userName = notificationDict["name"] as! String
        self.profileImage = notificationDict["profile_image_url"] as! String
        self.postDetail = WhalebirdAPIClient.convertLocalTime(notificationDict["created_at"] as! String)
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
    
    func favoriteTweet(favorited: ()-> Void, unfavorited: ()-> Void) {
        var params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        if (self.fFavorited == true) {
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/unfavorite.json", params: cParameter) { (operation) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    self.fFavorited = false
                    unfavorited()
                })
            }
            
        } else {
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/favorite.json", params: cParameter) { (operation) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    self.fFavorited = true
                    favorited()
                })
            }
        }
    }
    
    func deleteTweet(completed: ()-> Void) {
        var params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/delete.json", params: cParameter, callback: { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                completed()
            })
        })
    }
    
    func retweetTweet(completed: ()-> Void) {
        var params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/retweet.json", params: cParameter, callback: { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                completed()
            })
        })
    }
    
    
    func customAttributedString() -> NSMutableAttributedString {
        var escapedTweetBody = WhalebirdAPIClient.escapeString(self.tweetBody)
        var attributedString = NSMutableAttributedString(string: escapedTweetBody, attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
        attributedString.setFont(UIFont(name: TimelineViewCell.NormalFont, size: 15))
        
        for screenName in TweetModel.listUpSentence(self.tweetBody, startCharacter: "@") {
            var nameRange: NSRange = (escapedTweetBody as NSString).rangeOfString(screenName)
            attributedString.addAttributes([NSLinkAttributeName: "at:" + screenName], range: nameRange)
        }
        for tag in TweetModel.listUpSentence(self.tweetBody, startCharacter: "#") {
            var tagRange: NSRange = (escapedTweetBody as NSString).rangeOfString(tag)
            attributedString.addAttributes([NSLinkAttributeName: "tag:" + tag], range: tagRange)
        }
        return attributedString
    }
    
    func replyList(userScreenName: String) ->String {
        var list: Array<String> = []
        var tScreenName = ""
        var fReply = false
        list.append("@" + self.screenName)
        list += TweetModel.listUpSentence(self.tweetBody, startCharacter: "@")
        var replyListStr = ""
        for name in list {
            replyListStr += name + " "
        }
        return replyListStr
    }
}
