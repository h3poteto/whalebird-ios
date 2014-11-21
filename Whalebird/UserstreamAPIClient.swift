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
    
    var account: ACAccount!
    var accountStore = ACAccountStore()
    var connection: NSURLConnection!
    var timelineTable: TimelineTableViewController?
    
    //=======================================
    //  class method
    //=======================================
    class func convertUTCTime(srctime: String) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        var srcDate = dateFormatter.dateFromString(srctime)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var dstDate = dateFormatter.stringFromDate(srcDate!)
        return dstDate
    }
    
    class func convertRetweet(src_dict: NSMutableDictionary) -> NSMutableDictionary {
        var mutableDictionary = src_dict.mutableCopy() as NSMutableDictionary
        let originalText = mutableDictionary.objectForKey("retweeted_status")?.objectForKey("text") as String
        let originalCreatedAt = UserstreamAPIClient.convertUTCTime(mutableDictionary.objectForKey("retweeted_status")?.objectForKey("created_at") as String)
        let originalName = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as NSDictionary).objectForKey("name") as String
        let originalScreenName = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as NSDictionary).objectForKey("screen_name") as String
        let originalProfileImageURL = (mutableDictionary.objectForKey("retweeted_status")?.objectForKey("user") as NSDictionary).objectForKey("profile_image_url") as String
        let postName = mutableDictionary.objectForKey("user")?.objectForKey("name") as String
        let postScreenName = mutableDictionary.objectForKey("user")?.objectForKey("screen_name") as String
        let postProfileImageURL = mutableDictionary.objectForKey("user")?.objectForKey("profile_image_url") as String
        
        mutableDictionary.setValue(originalText, forKey: "text")
        mutableDictionary.setValue(originalCreatedAt, forKey: "created_at")
    
        var userDictionay = NSMutableDictionary(dictionary: [
            "name" : originalName,
            "screen_name" : originalScreenName,
            "profile_image_url" : originalProfileImageURL
        ])
        mutableDictionary.setValue(userDictionay, forKey: "user")
        
        var retweetedDictionary = NSMutableDictionary(dictionary: [
            "name" : postName,
            "screen_name" : postScreenName,
            "profile_image_url" : postProfileImageURL
        ])
        mutableDictionary.setValue(retweetedDictionary, forKey: "retweeted")
        
        
        return mutableDictionary
    }
    
    //=======================================
    //  instance method
    //=======================================
    
    func startStreaming(target_stream: NSURL, params: Dictionary<String,String>, callback:(ACAccount)->Void) {
        var request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: target_stream, parameters: params)
        var twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)!
        var twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
        if (twitterAccounts.count > 0) {
            let user_default = NSUserDefaults.standardUserDefaults()
            let username = user_default.stringForKey("username")
            var selected_account: ACAccount!
            for aclist in twitterAccounts {
                if (username == aclist.username) {
                    selected_account = aclist as ACAccount
                }
            }
            if (selected_account == nil) {
                //
            } else {
                self.account = selected_account
                request.account = self.account
                self.connection = NSURLConnection(request: request.preparedURLRequest(), delegate: self)
                self.connection.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
                self.connection.start()
                callback(self.account)
            }
         }
    }
    
    func stopStreaming(callback:()->Void) {
        if (self.connection != nil) {
            self.connection.cancel()
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
    
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        println(response)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        var jsonError:NSError?
        var jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
        
        if (jsonObject != nil) {
            var object: NSMutableDictionary! = (jsonObject as NSMutableDictionary).mutableCopy() as NSMutableDictionary
            if (object.objectForKey("text") != nil) {
                // datetimeをサーバー側のデータに合わせて加工しておく
                object.setValue(UserstreamAPIClient.convertUTCTime(object.objectForKey("created_at") as String), forKey: "created_at")
                println(object.objectForKey("user")?.objectForKey("screen_name"))
                if (object.objectForKey("retweeted_status") == nil) {
                    object.setValue(nil, forKey: "retweeted")
                } else {
                    object = UserstreamAPIClient.convertRetweet(object) as NSMutableDictionary
                }
                self.timelineTable?.currentTimeline.insert(object, atIndex: 0)
                self.timelineTable?.sinceId = object.objectForKey("id_str") as String?
                self.timelineTable?.tableView.reloadData()
            }
        }
    }
    
}
