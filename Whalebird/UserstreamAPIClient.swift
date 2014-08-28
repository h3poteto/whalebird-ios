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
    
    func startStreaming(target_stream: NSURL, params: Dictionary<String,String>, callback:(NSMutableArray)->Void) {
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
            }
         }
    }
    
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        println(response)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        var jsonError:NSError?
        var jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
        println(jsonObject)
        
        
        if (jsonObject != nil) {
            let object: NSDictionary = jsonObject as NSDictionary
            if (object.objectForKey("text") != nil) {
                let message = object.objectForKey("text") as NSString
                let username = NSUserDefaults.standardUserDefaults().stringForKey("username")
                let range: NSRange = message.rangeOfString("@" + username!)
                
                if (range.location != NSNotFound ){
                    let alert = UIAlertView()
                    alert.title = "Reply"
                    alert.message = message
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
    }
    
    
}
