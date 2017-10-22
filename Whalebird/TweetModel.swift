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
    var video: Array<String>?
    var fProtected: Bool!
    
    
    // twitter独自のscreen name判定
    // _ はscreen nameと判定．他の文字は半角英数字のみ許可
    class func checkScreenName(_ aCharacter: Character) -> Bool {
        if (aCharacter == "_") {
            return true
        } else {
            // 半角全角判定
            let str = String(aCharacter)
            if (str.data(using: String.Encoding.ascii, allowLossyConversion: false) == nil) {
                return false
            } else {
                let charSet = CharacterSet.alphanumerics
                if let aScanner = Scanner.localizedScanner(with: str) as? Scanner {
                    aScanner.charactersToBeSkipped = nil
                    aScanner.scanCharacters(from: charSet, into: nil)
                    return aScanner.isAtEnd
                } else {
                    return false
                }
            }
        }
    }
    
    class func listUpSentence(_ rawString: String, startCharacter: Character, fScreenName: Bool) -> Array<String> {
        var targetStringList: Array<String> = []
        var tTargetString = ""
        var fFindString = false
        for char in rawString.characters {
            if (fFindString) {
                if (char == " " || char == "　" || (fScreenName && !TweetModel.checkScreenName(char))) {
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
    
    // http://qiita.com/riocampos/items/c804dc7b14a1041383da
    class func mediaIsGif(_ media: String) -> Bool {
        if media.hasSuffix(".mp4") || media.hasSuffix(".webm") || media.hasSuffix(".m3u8") {
            return true
        }
        return false
    }
    
    
    init(dict: [AnyHashable: Any]) {
        super.init()
        self.tweetID = dict["id_str"] as! String
        self.tweetBody = dict["text"] as! String
        self.screenName = (dict["user"] as! [AnyHashable: Any])["screen_name"] as! String
        self.userName = (dict["user"] as! [AnyHashable: Any])["name"] as! String
        self.profileImage = (dict["user"] as! [AnyHashable: Any])["profile_image_url"] as! String
        self.postDetail = WhalebirdAPIClient.convertLocalTime(dict["created_at"] as! String)
        self.retweetedName = (dict["retweeted"] as? [AnyHashable: Any])?["screen_name"] as? String
        self.retweetedProfileImage = (dict["retweeted"] as? [AnyHashable: Any])?["profile_image_url"] as? String
        self.fFavorited = optionalToBool(dict["favorited?"] as? Bool)
        self.media = dict["media"] as? Array<String>
        self.video = dict["video"] as? Array<String>
        self.fProtected = optionalToBool((dict["user"] as? [AnyHashable: Any])?["protected?"] as? Bool)
    }
    
    init (notificationDict: [AnyHashable: Any]) {
        super.init()
        self.tweetID = notificationDict["id"] as! String
        self.tweetBody = notificationDict["text"] as! String
        self.screenName = notificationDict["screen_name"] as! String
        self.userName = notificationDict["name"] as! String
        self.profileImage = notificationDict["profile_image_url"] as! String
        self.postDetail = WhalebirdAPIClient.convertLocalTime(notificationDict["created_at"] as! String)
        self.fFavorited = optionalToBool(notificationDict["favorited"] as? Bool)
        self.media = notificationDict["media"] as? Array<String>
        self.video = notificationDict["video"] as? Array<String>
        self.fProtected = optionalToBool(notificationDict["protected"] as? Bool)
    }
    
    func optionalToBool(_ flag: Bool?) -> Bool {
        if flag != nil {
            return flag!
        } else {
            return false
        }
    }
    
    func favoriteTweet(_ favorited: @escaping ()-> Void, unfavorited: @escaping ()-> Void) {
        let params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        if (self.fFavorited == true) {
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/unfavorite.json", params: cParameter) { (operation) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: {()->Void in
                    self.fFavorited = false
                    unfavorited()
                })
            }
            
        } else {
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/favorite.json", params: cParameter) { (operation) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: {()->Void in
                    self.fFavorited = true
                    favorited()
                })
            }
        }
    }
    
    func deleteTweet(_ completed: @escaping ()-> Void) {
        let params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/delete.json", params: cParameter, callback: { (operation) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                completed()
            })
        })
    }
    
    func retweetTweet(_ completed: @escaping ()-> Void) {
        let params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/retweet.json", params: cParameter, callback: { (operation) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                completed()
            })
        })
    }
    
    
    func customAttributedString() -> NSMutableAttributedString {
        let escapedTweetBody = WhalebirdAPIClient.escapeString(self.tweetBody)
        let attributedString = NSMutableAttributedString(string: escapedTweetBody, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        attributedString.setFont(UIFont(name: TimelineViewCell.NormalFont, size: 15))
        
        for screenName in TweetModel.listUpSentence(self.tweetBody, startCharacter: "@", fScreenName: true) {
            let nameRange: NSRange = (escapedTweetBody as NSString).range(of: screenName)
            attributedString.addAttributes([NSAttributedStringKey.link: "at:" + screenName], range: nameRange)
        }
        for tag in TweetModel.listUpSentence(self.tweetBody, startCharacter: "#", fScreenName: false) {
            let tagRange: NSRange = (escapedTweetBody as NSString).range(of: tag)
            let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            attributedString.addAttributes([NSAttributedStringKey.link: "tag:" + encodedTag!], range: tagRange)
        }
        return attributedString
    }
    
    func replyList(_ userScreenName: String) ->String {
        var list: Array<String> = []
        list.append("@" + self.screenName)
        list += TweetModel.listUpSentence(self.tweetBody, startCharacter: "@", fScreenName: true)
        var replyListStr = ""
        for name in list {
            if name != "@" + userScreenName {
                replyListStr += name + " "                
            }
        }
        return replyListStr
    }
}
