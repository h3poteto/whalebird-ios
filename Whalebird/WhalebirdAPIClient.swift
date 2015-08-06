//
//  WhalebirdAPIClient.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/30.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import AFNetworking
import UrlShortener
import SVProgressHUD
import NoticeView
import IJReachability

class WhalebirdAPIClient: NSObject {

    // シングルトンにするよ
    class var sharedClient: WhalebirdAPIClient {
        struct sharedStruct {
            static let _sharedClient = WhalebirdAPIClient()
        }
        return sharedStruct._sharedClient
    }
    
    //=============================================
    //  instance variables
    //=============================================
    var sessionManager: AFHTTPRequestOperationManager!
    var whalebirdAPIURL: String = NSBundle.mainBundle().objectForInfoDictionaryKey("apiurl") as! String

    
    //===========================================
    //  class methods
    //===========================================
    class func convertLocalTime(aUtctime: String) -> String {
        var utcDateFormatter = NSDateFormatter()
        utcDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        utcDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        utcDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        var jstDateFormatter =  NSDateFormatter()
        jstDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        jstDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        jstDateFormatter.dateFormat = "MM月dd日 HH:mm"
        var jstDate = String()
        
        if var utcDate = utcDateFormatter.dateFromString(aUtctime) {
            var userDefault = NSUserDefaults.standardUserDefaults()
            if (userDefault.objectForKey("displayTimeType") != nil && userDefault.integerForKey("displayTimeType") == 2) {
                var current = NSDate(timeIntervalSinceNow: 0)
                var timeInterval = current.timeIntervalSinceDate(utcDate)
                if (timeInterval < 60) {
                    jstDate = "1分以内"
                } else if(timeInterval < 3600) {
                    jstDate = String(Int(timeInterval / 60.0)) + "分前"
                } else if(timeInterval < 3600 * 24) {
                    jstDate = String(Int(timeInterval / 3600.0)) + "時間前"
                } else {
                    jstDate = String(Int(timeInterval / (3600.0 * 24.0))) + "日前"
                }
            } else {
                jstDate = jstDateFormatter.stringFromDate(utcDate)
            }
        }
        return jstDate
    }
    
    class func escapeString(aString: String) -> String {
        var escapeStr = String()
        
        escapeStr = aString.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil)
        escapeStr = escapeStr.stringByReplacingOccurrencesOfString("&lt;", withString: "<", options: nil, range: nil)
        escapeStr = escapeStr.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: nil, range: nil)
        escapeStr = escapeStr.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: nil, range: nil)
        
        return escapeStr
    }
    
    class func encodeClipboardURL() {
        var pasteboard = UIPasteboard.generalPasteboard()
        if let clipboardText = pasteboard.valueForPasteboardType("public.text") as? String {
            if clipboardText.hasPrefix("http://") || clipboardText.hasPrefix("https://") {
                if let encodedURL = clipboardText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                    pasteboard.setValue(encodedURL, forPasteboardType: "public.text")
                    var shortener = UrlShortener()
                    shortener.shortenUrl(encodedURL, withService: UrlShortenerServiceIsgd, completion: { (shortUrl) -> Void in
                        if shortUrl.hasPrefix("http://") || shortUrl.hasPrefix("https://") {
                            pasteboard.setValue(shortUrl, forPasteboardType: "public.text")
                        }
                    }, error: { (error) -> Void in
                        pasteboard.setValue(encodedURL, forPasteboardType: "public.text")
                    })
                }
            }
        }
    }
    
    //===========================================
    //  instance methods
    //===========================================
    
    func cleanDictionary(dict: NSDictionary)->NSMutableDictionary {
        var mutableDict: NSMutableDictionary = NSMutableDictionary(dictionary: dict)
        mutableDict.enumerateKeysAndObjectsUsingBlock { (key, obj, stop) -> Void in
            if (obj.isKindOfClass(NSNull.classForCoder())) {
                if let safeKey = key as? NSString {
                    mutableDict.setObject("", forKey: safeKey)
                }
            } else if (obj.isKindOfClass(NSDictionary.classForCoder())) {
                if let safeObject = obj as? NSDictionary, let safeKey = key as? NSString {
                    mutableDict.setObject(self.cleanDictionary(safeObject), forKey: (safeKey))
                }
            }
        }
        return mutableDict
    }
    
    func initAPISession(success:() -> Void, failure:(NSError) -> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.sessionManager = AFHTTPRequestOperationManager()
        self.sessionManager.requestSerializer.setValue(ApplicationSecrets.Secret(), forHTTPHeaderField: "Whalebird-Key")
        var requestURL = self.whalebirdAPIURL + "users/apis.json"
        self.sessionManager.GET(requestURL, parameters: nil, success: { (operation, responseObject) -> Void in
            println(responseObject)
            self.saveCookie()
            var userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setObject(responseObject["screen_name"], forKey: "username")
            success()
        }) { (operation, error) -> Void in
            println(error)
            self.displayErrorMessage(operation, error: error)
            SVProgressHUD.dismiss()
            failure(error)
        }
        
    }
    
    func getArrayAPI(path: String, displayError: Bool, params: Dictionary<String, AnyObject>, completed: (NSArray) ->Void, failed: () -> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.GET(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if let object = responseObject as? NSArray {
                    completed(object.reverseObjectEnumerator().allObjects)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                if displayError {
                    self.displayErrorMessage(operation, error: error)
                }
                failed()
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func getDictionaryAPI(path: String, params: Dictionary<String, AnyObject>, callback: (NSDictionary) ->Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.GET(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if let object = responseObject as? NSDictionary {
                    callback(object)
                } else {
                    println("blank response")
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Request Error", message: "情報がありません")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                    notice.show()
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                self.displayErrorMessage(operation, error: error)
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func postAnyObjectAPI(path: String, params: Dictionary<String, AnyObject>, callback: (AnyObject) ->Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.POST(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback(operation)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                self.displayErrorMessage(operation, error: error)
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func postImage(image: UIImage, progress: (Float) -> Void, complete: (NSDictionary) -> Void, failed: (NSError)-> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            self.sessionManager.responseSerializer = AFHTTPResponseSerializer()
            var request = self.sessionManager.requestSerializer.multipartFormRequestWithMethod("POST",
                URLString: self.whalebirdAPIURL + "users/apis/upload.json",
                parameters: nil,
                constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                    formData.appendPartWithFileData(
                        NSData(data: UIImagePNGRepresentation(image)),
                        name: "media",
                        fileName: "test.png",
                        mimeType: "image/png")
                    
                }, error: nil)
            
            
            var operation = self.sessionManager.HTTPRequestOperationWithRequest(request, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    println(responseObject)
                    var jsonError: NSError?
                    if let object = responseObject as? NSData, var jsonData = NSJSONSerialization.JSONObjectWithData(object, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? NSDictionary {
                        complete(jsonData)
                    }
                }
                }) { (operation, error) -> Void in
                    println(error)
                    self.displayErrorMessage(operation, error: error)
                    failed(error)
            }
            
            operation.setUploadProgressBlock { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                var written = Float(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                progress(written)
            }
            
            self.sessionManager.operationQueue.addOperation(operation)
        } else {
            self.regenerateSession()
        }
    }
    
    func syncPushSettings(callback: (AnyObject) ->Void) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        var notificationBackgroundFlag = true
        if userDefault.objectForKey("notificationBackgroundFlag") != nil {
            notificationBackgroundFlag = userDefault.boolForKey("notificationBackgroundFlag")
        }
        var notificationReplyFlag = true
        if userDefault.objectForKey("notificationReplyFlag") != nil {
            notificationReplyFlag = userDefault.boolForKey("notificationReplyFlag")
        }
        var notificationRTFlag = true
        if userDefault.objectForKey("notificationRTFlag") != nil {
            notificationRTFlag = userDefault.boolForKey("notificationRTFlag")
        }
        var notificationFavFlag = true
        if userDefault.objectForKey("notificationFavFlag") != nil {
            notificationFavFlag = userDefault.boolForKey("notificationFavFlag")
        }
        var notificationDMFlag = true
        if userDefault.objectForKey("notificationDMFlag") != nil {
            notificationDMFlag = userDefault.boolForKey("notificationDMFlag")
        }
        var params: Dictionary<String, AnyObject> = [
            "notification" : notificationBackgroundFlag,
            "reply" : notificationReplyFlag,
            "retweet" : notificationRTFlag,
            "favorite" : notificationFavFlag,
            "direct_message" : notificationDMFlag
        ]
        if let deviceToken = userDefault.stringForKey("deviceToken") {
            params["device_token"] = deviceToken
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/update_settings.json", params: cParameter) { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                callback(operation)
            })
        }
    }
    
    func deleteSsessionAPI(path: String, params: Dictionary<String, AnyObject>,callback: (AnyObject) -> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.DELETE(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback(operation)
                } else {
                    println("blank response")
                    callback(operation)
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                self.displayErrorMessage(operation, error: error)
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }

    func cancelRequest() {
        if (self.sessionManager != nil) {
            self.sessionManager.operationQueue.cancelAllOperations()
        }
    }
    
    func regenerateSession() {
        var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
        notice.alpha = 0.8
        notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
        notice.show()
        SVProgressHUD.dismiss()
    }
    
    func loadCookie() {
        if var cookiesData = NSUserDefaults.standardUserDefaults().objectForKey("cookiesKey") as? NSData {
            if var cookies = NSKeyedUnarchiver.unarchiveObjectWithData(cookiesData) as? NSArray {
                for cookie in cookies {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie as! NSHTTPCookie)
                }
                self.sessionManager = AFHTTPRequestOperationManager()
                self.sessionManager.requestSerializer.setValue(ApplicationSecrets.Secret(), forHTTPHeaderField: "Whalebird-Key")
            }
        }
    }
    
    func saveCookie() {
        var cookiesData = NSKeyedArchiver.archivedDataWithRootObject(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
        NSUserDefaults.standardUserDefaults().setObject(cookiesData, forKey: "cookiesKey")
    }
    
    func removeSession() {
        self.sessionManager = nil
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "cookiesKey")
    }
    
    func displayErrorMessage(operation: AFHTTPRequestOperation, error: NSError) {
        var errorMessage = String()
        if (operation.response == nil) {
            if (error.code != NSURLErrorCancelled) {
                errorMessage = String(error.localizedDescription)
            } else {
                return
            }
        } else if (operation.response.statusCode == 401) {
            errorMessage = "ログインしなおしてください"
        } else if (operation.response.statusCode == 200) {
            errorMessage = "予期しないエラーが発生しました"
        } else if (operation.response.statusCode == 499) {
            errorMessage = "Status Code: " + String(operation.response.statusCode)
            if let jsonData = NSJSONSerialization.JSONObjectWithData(operation.responseData, options: nil, error: nil) as? NSDictionary {
                if jsonData.objectForKey("errors") as? String != nil {
                    errorMessage = jsonData.objectForKey("errors") as! String
                }
            }
        } else {
            errorMessage = "Status Code: " + String(operation.response.statusCode)
        }

        var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Error", message: errorMessage)
        notice.alpha = 0.8
        notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
        notice.show()
    }
    
    func confirmConnectedNetwork() ->Bool {
        if !IJReachability.isConnectedToNetwork() {
            var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Network Error", message: "ネットワークに接続できません")
            notice.alpha = 0.8
            notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
            notice.show()
            return false
        }
        return true
    }
}
