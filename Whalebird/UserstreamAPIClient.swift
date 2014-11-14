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
                // TODO: created_atだけ修正
                self.timelineTable?.currentTimeline.insertObject(object, atIndex: 0)
                self.timelineTable?.sinceId = object.objectForKey("id_str") as String?
                self.timelineTable?.tableView.reloadData()
            }
        }
    }
    
}
