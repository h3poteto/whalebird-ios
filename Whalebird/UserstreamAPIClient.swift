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
    // クラス変数が未実装のため構造体で対応
    private struct SharedStruct {
        static var _sharedClient: UserstreamAPIClient!
    }
    
    var account: ACAccount!
    var accountStore = ACAccountStore()
    var connection: NSURLConnection!
    
    //=======================================
    //  class method
    //=======================================
    
    class func sharedClient() -> UserstreamAPIClient {
        if (SharedStruct._sharedClient == nil) {
            SharedStruct._sharedClient = UserstreamAPIClient()
        }
        
        return SharedStruct._sharedClient
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
    
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        println(response)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        var jsonError:NSError?
        var jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
        println(jsonObject)
        
        
        if (jsonObject != nil) {
            let object: NSDictionary! = jsonObject as NSDictionary
            if (object.objectForKey("text") != nil) {
                let message = object.objectForKey("text") as NSString
                let username = NSUserDefaults.standardUserDefaults().stringForKey("username")
                let range: NSRange = message.rangeOfString("@" + username!)
                
                if (range.location != NSNotFound ){
                    // The userInfo dictionary on a UILocalNotification must contain only "plist types".
                    // http://stackoverflow.com/questions/4680137/uilocalnotification-userinfo-not-serializing-nsurl
                    
                    let created_at: String = object.objectForKey("created_at") as String
                    let id: String = object.objectForKey("id_str") as String
                    let text: String = object.objectForKey("text") as String
                    let screen_name: String = (object.objectForKey("user") as NSDictionary).objectForKey("screen_name") as String
                    let name: String = (object.objectForKey("user") as NSDictionary).objectForKey("name") as String
                    let profile_image_url: String = (object.objectForKey("user") as NSDictionary).objectForKey("profile_image_url") as String
                    var userInfoDictionary: Dictionary<String, String> = [
                        "created_at" : created_at,
                        "id" : id,
                        "text" : text,
                        "screen_name" : screen_name,
                        "name" : name,
                        "profile_image_url" : profile_image_url
                    ]
                    var notification = UILocalNotification()
                    notification.fireDate = NSDate()
                    notification.timeZone = NSTimeZone.defaultTimeZone()
                    notification.alertBody = message
                    notification.alertAction = "OK"
                    notification.userInfo = userInfoDictionary
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                    
                }
            }
        }
    }
    
    
}
