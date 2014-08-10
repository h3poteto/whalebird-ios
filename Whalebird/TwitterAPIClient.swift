//
//  TwitterAPIClient.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterAPIClient: NSObject {
    
    // クラス変数が未実装のため構造体で対応
    private struct SharedStruct {
        static var _sharedClient: TwitterAPIClient!
    }
    
    var account: ACAccount!
    var accountStore = ACAccountStore()
    
    //=======================================
    //  class method
    //=======================================
    
    class func sharedClient() -> TwitterAPIClient {
        if (SharedStruct._sharedClient == nil) {
            SharedStruct._sharedClient = TwitterAPIClient()
        }
        
        return SharedStruct._sharedClient
    }
    
    
    //=======================================
    //  instance method
    //=======================================

    //---------------------------------------
    //  コンストラクタ
    //---------------------------------------
    override init() {
        super.init()
        login({() in
        })
    }
    
    //---------------------------------------
    //  ログイン確認
    //  return: bool
    //---------------------------------------
    func login(complete:()->Void) -> Bool {
        var result = false
        
        var flag = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
        // なぜかfalseになるので強制的に実装
        if (true) {
            var twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)!

            self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: {granted, error in
                if (granted) {
                    var twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
                    var url: NSURL = NSURL.URLWithString("https://api.twitter.com/1.1/account/settings.json")
                    var request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
                    var count = twitterAccounts.count
                    if (twitterAccounts.count > 0) {
                        // Lastじゃなくて選択させたい
                        self.account = twitterAccounts.lastObject as ACAccount
                        request.account = self.account
                        request.performRequestWithHandler({responseData, urlResponse, error in
                            if (responseData != nil) {
                                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                                    result = true
                                    complete()
                                }
                            }
                        })
                    } else {
                        var alertController = UIAlertController(title: "Account not found", message: "設定からアカウントを登録してください", preferredStyle: UIAlertControllerStyle.Alert)
                        //var destructiveAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        //alertController.addAction(destructiveAction)
                        //self.presentViewController(alertController, animated: true, completion: nil)
                        result = false
                    }
                }
            }
            )
        }
        return result
    }
    
    //----------------------------------------
    //  指定のタイムラインを更新
    //----------------------------------------
    func getTimeline(target_timeline: NSURL, params: Dictionary<String, String>, callback:(NSMutableArray)->Void) {
        var new_timeline = NSMutableArray()
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: target_timeline, parameters: params)
        
        if (self.account == nil){
            login({() in
                request.account = self.account
                request.performRequestWithHandler({responseData, urlResponse, error in
                    if (responseData != nil) {
                        if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                            var jsonError: NSError?
                            new_timeline = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSMutableArray
                            callback(new_timeline)
                        }
                    }
                })
            })
        }
    }
    
}


