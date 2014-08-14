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
    //  アカウントを列挙
    //---------------------------------------
    func pickUpAccount(complete:(NSArray)->Void) {
        var twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: {granted, error in
            if (granted) {
                var twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
                complete(twitterAccounts)
            } else {
                complete(NSArray())
            }
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
                        let user_default = NSUserDefaults.standardUserDefaults()
                        let username = user_default.stringForKey("username")
                        var selected_account: ACAccount!
                        for aclist in twitterAccounts {
                            if (username == aclist.username) {
                                selected_account = aclist as ACAccount
                            }
                        }
                        if (selected_account == nil) {
                            // alert アカウントを設定させる
                            println("please select account")
                        } else {
                            self.account = selected_account
                            request.account = self.account
                            request.performRequestWithHandler({responseData, urlResponse, error in
                                if (responseData != nil) {
                                    if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                                        result = true
                                        complete()
                                    } else {
                                        // status error
                                        println("response status error")
                                    }
                                } else {
                                    println("response data is nil")
                                }
                            })
                        }
                    } else {
                        var alertController = UIAlertController(title: "Account not found", message: "設定からアカウントを登録してください", preferredStyle: UIAlertControllerStyle.Alert)
                        //var destructiveAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        //alertController.addAction(destructiveAction)
                        //self.presentViewController(alertController, animated: true, completion: nil)
                        result = false
                        println("please submit account")
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
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: target_timeline, parameters: params)
        if (self.account == nil){
            login({() in
                self.getAction(request, callback: callback)
            })
        } else {
            self.getAction(request, callback: callback)
        }
    }
    
    func getAction(request: SLRequest, callback:(NSMutableArray)->Void) {
        var new_timeline = NSMutableArray()
        
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
    }
    
    //------------------------------------------
    //  指定のPOSTアクション
    //------------------------------------------
    func postTweetData(target_url: NSURL, params: Dictionary<String, String>, callback:(Int)->Void) {
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: target_url, parameters: params)
        
        if (self.account == nil) {
            login({() in
                self.postAction(request, callback: callback)
            })
        } else {
            self.postAction(request, callback: callback)
        }
    }
    
    func postAction(request: SLRequest, callback:(Int)->Void) {
        var result = NSMutableArray()
        request.account = self.account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if (responseData != nil) {
                callback(urlResponse.statusCode)
            }
        })
    }
    
    //---------------------------------------
    //  ユーザー情報の取得
    //---------------------------------------
    func getUserInfo(target_url: NSURL, params: Dictionary<String, String>, callback:(NSDictionary)->Void) {
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: target_url, parameters: params)
        
        if (self.account == nil) {
            login({() in
                self.userInfoAction(request, callback: callback)
            })
        } else {
            self.userInfoAction(request, callback: callback)
        }
    }
    
    func userInfoAction(request: SLRequest, callback:(NSDictionary)->Void) {
        var user_info: NSDictionary!
        request.account = self.account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if (responseData != nil) {
                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300){
                    var jsonError: NSError?
                    user_info = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSDictionary
                    callback(user_info)
                } else {
                    println(urlResponse.statusCode)
                    callback(NSDictionary())
                }
            } else {
                println(responseData)
                callback(NSDictionary())
            }
        })
    }
}


