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
    
    class func createdAtToString(dateStr: NSString) -> NSString{
        var input_format = NSDateFormatter()
        input_format.dateStyle = NSDateFormatterStyle.LongStyle
        input_format.timeStyle = NSDateFormatterStyle.NoStyle
        input_format.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        input_format.locale = NSLocale(localeIdentifier: "en_US")
        var date: NSDate = input_format.dateFromString(dateStr)!
        
        var output_format = NSDateFormatter()
        output_format.dateStyle = NSDateFormatterStyle.LongStyle
        output_format.timeStyle = NSDateFormatterStyle.NoStyle
        output_format.dateFormat = "HH:mm:ss"
        output_format.locale = NSLocale(localeIdentifier: "ja_JP")
        return output_format.stringFromDate(date)
    }
    
    
    //=======================================
    //  instance method
    //=======================================

    //---------------------------------------
    //  コンストラクタ
    //---------------------------------------
    override init() {
        super.init()

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
                            // できればAlertControllerで遷移させたい
                            // 表示先のViewが確定しない上に，親のtabBarControllerが取得できないので手詰まり
                            var alert = UIAlertView()
                            alert.title = "Account Select"
                            alert.message = "Please select your account"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                            
                            
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
                                        var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Network Erro", message: ("Status Code:" + String(urlResponse.statusCode)))
                                        notice.alpha = 0.8
                                        notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                                        notice.show()
                                    }
                                } else {
                                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Network Erro", message: "Can not recieve response")
                                    notice.alpha = 0.8
                                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                                    notice.show()
                                }
                            })
                        }
                    } else {
                        var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Account Not Found", message: "Please register your account in iPhone")
                        notice.alpha = 0.8
                        notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                        notice.show()
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
    func getTimeline(target_timeline: NSURL, params: Dictionary<String, String>, callback:(NSArray)->Void) {
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: target_timeline, parameters: params)
        if (self.account == nil){
            login({() in
                self.getAction(request, callback: callback)
            })
        } else {
            self.getAction(request, callback: callback)
        }
    }
    
    func getAction(request: SLRequest, callback:(NSArray)->Void) {
        //var new_timeline = NSMutableArray()
        
        request.account = self.account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if (responseData != nil) {
                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                    var jsonError: NSError?
                    var new_timeline = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSArray
                    callback(new_timeline.reverseObjectEnumerator().allObjects)
                }
            }
        })
    }
    
    //------------------------------------------
    //  指定のPOSTアクション
    //------------------------------------------
    func postTweetData(target_url: NSURL, params: Dictionary<String, String>, callback:(NSData?, Int, NSError?)->Void) {
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: target_url, parameters: params)
        
        if (self.account == nil) {
            login({() in
                self.postAction(request, callback: callback)
            })
        } else {
            self.postAction(request, callback: callback)
        }
    }
    
    func postAction(request: SLRequest, callback:(NSData?, Int, NSError?)->Void) {
        var result = NSMutableArray()
        request.account = self.account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if (responseData != nil) {
                callback(responseData, urlResponse.statusCode, error)
            } else {
                callback(nil, 400, error)
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
                    callback(NSDictionary())
                }
            } else {
                callback(NSDictionary())
            }
        })
    }
}


