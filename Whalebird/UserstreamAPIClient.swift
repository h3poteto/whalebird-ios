//
//  UserstreamAPIClient.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/28.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Social
import Accounts
import NoticeView
import IJReachability

class UserstreamAPIClient: NSURLConnection, NSURLConnectionDataDelegate {

    // シングルトンにするよ
    class var sharedClient: UserstreamAPIClient {
    struct sharedStruct {
        static let _sharedClient = UserstreamAPIClient()
        }
        return sharedStruct._sharedClient
    }
    
    //=============================================
    //  instance variables
    //=============================================
    var account: ACAccount!
    var accountStore = ACAccountStore()
    var connection: NSURLConnection?
    var timeline: TimelineModel!
    
    //=======================================
    //  class methods
    //=======================================
    // localeの設定をしないと，実機で落ちる
    class func convertUTCTime(aSrctime: String) -> String {
        var dstDate = String()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZ yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.locale = NSLocale(localeIdentifier: "UTC")
        if let srcDate = dateFormatter.dateFromString(aSrctime as String) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dstDate = dateFormatter.stringFromDate(srcDate)
        }
        return dstDate
    }
    
    class func convertRetweet(aDictionary: NSMutableDictionary) -> NSMutableDictionary {
        let mutableDictionary = aDictionary.mutableCopy() as! NSMutableDictionary
        let cOriginalText = mutableDictionary.objectForKey("retweeted_status")?.objectForKey("text") as! String
        let cOriginalCreatedAt = UserstreamAPIClient.convertUTCTime(mutableDictionary.objectForKey("retweeted_status")?.objectForKey("created_at") as! String)
        let cOriginalName = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as! NSDictionary).objectForKey("name") as! String
        let cOriginalScreenName = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as! NSDictionary).objectForKey("screen_name") as! String
        let cOriginalProfileImageURL = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as! NSDictionary).objectForKey("profile_image_url_https") as! String
        let cPostName = mutableDictionary.objectForKey("user")?.objectForKey("name") as! String
        let cPostScreenName = mutableDictionary.objectForKey("user")?.objectForKey("screen_name") as! String
        let cPostProfileImageURL = mutableDictionary.objectForKey("user")?.objectForKey("profile_image_url_https") as! String
        
        mutableDictionary.setValue(cOriginalText, forKey: "text")
        mutableDictionary.setValue(cOriginalCreatedAt, forKey: "created_at")
    
        let userDictionay = NSMutableDictionary(dictionary: [
            "name" : cOriginalName,
            "screen_name" : cOriginalScreenName,
            "profile_image_url" : cOriginalProfileImageURL,
            "protected?" : false
        ])
        mutableDictionary.setValue(userDictionay, forKey: "user")
        
        let retweetedDictionary = NSMutableDictionary(dictionary: [
            "name" : cPostName,
            "screen_name" : cPostScreenName,
            "profile_image_url" : cPostProfileImageURL
        ])
        mutableDictionary.setValue(retweetedDictionary, forKey: "retweeted")
        
        
        return mutableDictionary
    }
    
    class func convertMedia(aDictionary: NSMutableDictionary) -> NSMutableDictionary {
        let mutableDictionary = aDictionary.mutableCopy() as! NSMutableDictionary
        let cOriginalMedia = mutableDictionary.objectForKey("entities")?.objectForKey("media") as! NSArray
        let mediaURLArray = NSMutableArray()
        for media in cOriginalMedia {
            mediaURLArray.addObject(media.objectForKey("media_url_https")!)
        }
        mutableDictionary.setValue(mediaURLArray, forKey: "media")
        
        // video
        let videoURLArray = NSMutableArray()
        let cOriginalVideo = mutableDictionary.objectForKey("extended_entities")?.objectForKey("media") as! NSArray
        for anime in cOriginalVideo {
            if anime.objectForKey("type") as! String == "animated_gif" {
                var video: String! = ""
                if let variants = anime.objectForKey("video_info")?.objectForKey("variants") as? NSArray {
                    video = (variants.objectAtIndex(0) as! NSDictionary).objectForKey(("url")) as? String ?? ""
                }
                videoURLArray.addObject(video)
            } else {
                videoURLArray.addObject("")
            }
        }
        mutableDictionary.setValue(videoURLArray, forKey: "video")
        return mutableDictionary
    }
    
    //=======================================
    //  instance methods
    //=======================================
    
    func startStreaming(aTargetStream: NSURL, params: Dictionary<String,String>, callback:(ACAccount)->Void) {
        if !self.confirmConnectedNetwork() {
            return
        }
        let request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: aTargetStream, parameters: params)
        if let twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter) {
            let twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
            if (twitterAccounts.count > 0) {
                let userDefault = NSUserDefaults.standardUserDefaults()
                let cUsername = userDefault.stringForKey("username")
                var selectedAccount: ACAccount?
                for aclist in twitterAccounts {
                    if (cUsername == aclist.username) {
                        selectedAccount = aclist as? ACAccount
                    }
                }
                if (selectedAccount == nil) {
                    let notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                    notice.show()
                } else {
                    self.account = selectedAccount
                    request.account = self.account
                    self.connection = NSURLConnection(request: request.preparedURLRequest(), delegate: self)
                    self.connection?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
                    self.connection?.start()
                    callback(self.account)
                }
            }
        }
    }
    
    func stopStreaming(callback:()->Void) {
        if (self.connection != nil) {
            self.connection?.cancel()
            self.connection = nil
            callback()
        }
    }
    
    func livingStream() -> Bool {
        if (self.connection != nil) {
            return true
        } else {
            return false
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        print(response)
    }
    
    func connection(connection: NSURLConnection,didReceiveData data: NSData){
        var jsonError:NSError?
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            var object: NSMutableDictionary = jsonObject.mutableCopy() as! NSMutableDictionary
            if (object.objectForKey("text") != nil) {
                // datetimeをサーバー側のデータに合わせて加工しておく
                object.setValue(UserstreamAPIClient.convertUTCTime(object.objectForKey("created_at") as! String), forKey: "created_at")
                print(object.objectForKey("user")?.objectForKey("screen_name"))
                object.setValue(object.objectForKey("favorited") as! Int, forKey: "favorited?")
                if (object.objectForKey("retweeted_status") == nil) {
                    object.setValue(nil, forKey: "retweeted")
                } else {
                    object = UserstreamAPIClient.convertRetweet(object) as NSMutableDictionary
                }
                if (object.objectForKey("entities")?.objectForKey("media") == nil) {
                    object.setValue(nil, forKey: "media")
                } else {
                    object = UserstreamAPIClient.convertMedia(object) as NSMutableDictionary
                }
                self.timeline.realtimeUpdate(object)
            }
        } catch let error as NSError {
            jsonError = error
        }
    }
    func confirmConnectedNetwork() ->Bool {
        if !IJReachability.isConnectedToNetwork() {
            let notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Network Error", message: "ネットワークに接続できません")
            notice.alpha = 0.8
            notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
            notice.show()
            return false
        }
        return true
    }
}
