//
//  WhalebirdAPIClient.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/30.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class WhalebirdAPIClient: NSObject {
    
    var sessionManager: AFHTTPRequestOperationManager!
    var whalebirdAPIURL: String = NSBundle.mainBundle().objectForInfoDictionaryKey("apiurl") as String
    
    // シングルトンにするよ
    class var sharedClient: WhalebirdAPIClient {
        struct sharedStruct {
            static let _sharedClient = WhalebirdAPIClient()
        }
        return sharedStruct._sharedClient
    }
    
    //========================================
    //  class method
    //========================================
    //===========================================
    //  instance method
    //===========================================
    
    func cleanDictionary(dict: NSMutableDictionary)->NSMutableDictionary {
        var mutableDict: NSMutableDictionary = dict.mutableCopy() as NSMutableDictionary
        mutableDict.enumerateKeysAndObjectsUsingBlock { (key, obj, stop) -> Void in
            if (obj.isKindOfClass(NSNull.classForCoder())) {
                mutableDict.setObject("", forKey: (key as NSString))
            } else if (obj.isKindOfClass(NSDictionary.classForCoder())) {
                mutableDict.setObject(self.cleanDictionary(obj as NSMutableDictionary), forKey: (key as NSString))
            }
        }
        return mutableDict
    }
    
    func initAPISession() {
        self.sessionManager = AFHTTPRequestOperationManager()
        var requestURL = self.whalebirdAPIURL + "users/apis.json"
        self.sessionManager.GET(requestURL, parameters: nil, success: { (operation, responseObject) -> Void in
            println(responseObject)
        }) { (operation, error) -> Void in
            println(error)
            var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Erro", message: ("Status Code:" + String(operation.response.statusCode)))
            notice.alpha = 0.8
            notice.originY = UIApplication.sharedApplication().statusBarFrame.height
            notice.show()
        }
        
    }
    
    func getArrayAPI(path: String, params: Dictionary<String, AnyObject>, callback: (NSArray) ->Void) {
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.GET(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback((responseObject as NSArray).reverseObjectEnumerator().allObjects)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Erro", message: ("Status Code:" + String(operation.response.statusCode)))
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            })
        } else {
            
        }
    }
    
    func getDictionaryAPI(path: String, params: Dictionary<String, AnyObject>, callback: (NSDictionary) ->Void) {
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.GET(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback(responseObject as NSDictionary)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Erro", message: ("Status Code:" + String(operation.response.statusCode)))
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            })
        }
    }
    
    func postAnyObjectAPI(path: String, params: Dictionary<String, AnyObject>, callback: (AnyObject) ->Void) {
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.POST(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    var jsonError: NSError?
                    callback(operation)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Post Erro", message: ("Status Code:" + String(operation.response.statusCode)))
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            })
        }
    }
}
