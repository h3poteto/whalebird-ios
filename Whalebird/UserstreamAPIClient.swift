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
    var timelineTable: TimelineTableViewController?
    
    //=======================================
    //  class methods
    //=======================================
    // localeの設定をしないと，実機で落ちる
    class func convertUTCTime(aSrctime: String) -> String {
        var dstDate = String()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZ yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.locale = NSLocale(localeIdentifier: "UTC")
        if var srcDate = dateFormatter.dateFromString(aSrctime as String) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dstDate = dateFormatter.stringFromDate(srcDate)
        }
        return dstDate
    }
    
    class func convertRetweet(aDictionary: NSMutableDictionary) -> NSMutableDictionary {
        var mutableDictionary = aDictionary.mutableCopy() as! NSMutableDictionary
        let cOriginalText = mutableDictionary.objectForKey("retweeted_status")?.objectForKey("text") as! String
        let cOriginalCreatedAt = UserstreamAPIClient.convertUTCTime(mutableDictionary.objectForKey("retweeted_status")?.objectForKey("created_at") as! String)
        let cOriginalName = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as! NSDictionary).objectForKey("name") as! String
        let cOriginalScreenName = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as! NSDictionary).objectForKey("screen_name") as! String
        let cOriginalProfileImageURL = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as! NSDictionary).objectForKey("profile_image_url") as! String
        let cPostName = mutableDictionary.objectForKey("user")?.objectForKey("name") as! String
        let cPostScreenName = mutableDictionary.objectForKey("user")?.objectForKey("screen_name") as! String
        let cPostProfileImageURL = mutableDictionary.objectForKey("user")?.objectForKey("profile_image_url") as! String
        
        mutableDictionary.setValue(cOriginalText, forKey: "text")
        mutableDictionary.setValue(cOriginalCreatedAt, forKey: "created_at")
    
        var userDictionay = NSMutableDictionary(dictionary: [
            "name" : cOriginalName,
            "screen_name" : cOriginalScreenName,
            "profile_image_url" : cOriginalProfileImageURL,
            "protected?" : false
        ])
        mutableDictionary.setValue(userDictionay, forKey: "user")
        
        var retweetedDictionary = NSMutableDictionary(dictionary: [
            "name" : cPostName,
            "screen_name" : cPostScreenName,
            "profile_image_url" : cPostProfileImageURL
        ])
        mutableDictionary.setValue(retweetedDictionary, forKey: "retweeted")
        
        
        return mutableDictionary
    }
    
    class func convertMedia(aDictionary: NSMutableDictionary) -> NSMutableDictionary {
        var mutableDictionary = aDictionary.mutableCopy() as! NSMutableDictionary
        var cOriginalMedia = mutableDictionary.objectForKey("entities")?.objectForKey("media") as! NSArray
        var mediaURLArray = NSMutableArray()
        for media in cOriginalMedia {
            mediaURLArray.addObject(media.objectForKey("media_url")!)
        }
        mutableDictionary.setValue(mediaURLArray, forKey: "media")
        return mutableDictionary
    }
    
    //=======================================
    //  instance methods
    //=======================================
    
    func startStreaming(aTargetStream: NSURL, params: Dictionary<String,String>, callback:(ACAccount)->Void) {
        var request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: aTargetStream, parameters: params)
        if var twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter) {
            var twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
            if (twitterAccounts.count > 0) {
                var userDefault = NSUserDefaults.standardUserDefaults()
                let cUsername = userDefault.stringForKey("username")
                var selectedAccount: ACAccount?
                for aclist in twitterAccounts {
                    if (cUsername == aclist.username) {
                        selectedAccount = aclist as? ACAccount
                    }
                }
                if (selectedAccount == nil) {
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
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
        println(response)
    }
    
    func connection(connection: NSURLConnection,didReceiveData data: NSData){
        var jsonError:NSError?
        if var jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) {
            var object: NSMutableDictionary = jsonObject.mutableCopy() as! NSMutableDictionary
            if (object.objectForKey("text") != nil) {
                // datetimeをサーバー側のデータに合わせて加工しておく
                object.setValue(UserstreamAPIClient.convertUTCTime(object.objectForKey("created_at") as! String), forKey: "created_at")
                println(object.objectForKey("user")?.objectForKey("screen_name"))
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
                self.timelineTable?.currentTimeline.insert(object, atIndex: 0)
                self.timelineTable?.sinceId = object.objectForKey("id_str") as? String
                self.timelineTable?.tableView.reloadData()
            }
        }
    }
    
}
