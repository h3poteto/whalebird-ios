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
import ReachabilitySwift

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
    var whalebirdAPIURL: String = Bundle.main.object(forInfoDictionaryKey: "apiurl") as! String

    
    //===========================================
    //  class methods
    //===========================================
    class func convertLocalTime(_ aUtctime: String) -> String {
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateStyle = DateFormatter.Style.long
        utcDateFormatter.timeStyle = DateFormatter.Style.none
        utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        utcDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let jstDateFormatter =  DateFormatter()
        jstDateFormatter.dateStyle = DateFormatter.Style.long
        jstDateFormatter.timeStyle = DateFormatter.Style.none
        jstDateFormatter.dateFormat = "MM月dd日 HH:mm"
        var jstDate = String()
        
        if let utcDate = utcDateFormatter.date(from: aUtctime) {
            let userDefault = UserDefaults.standard
            if (userDefault.object(forKey: "displayTimeType") != nil && userDefault.integer(forKey: "displayTimeType") == 2) {
                let current = Date(timeIntervalSinceNow: 0)
                let timeInterval = current.timeIntervalSince(utcDate)
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
                jstDate = jstDateFormatter.string(from: utcDate)
            }
        }
        return jstDate
    }
    
    class func escapeString(_ aString: String) -> String {
        var escapeStr = String()
        
        escapeStr = aString.replacingOccurrences(of: "&gt;", with: ">", options: [], range: nil)
        escapeStr = escapeStr.replacingOccurrences(of: "&lt;", with: "<", options: [], range: nil)
        escapeStr = escapeStr.replacingOccurrences(of: "&amp;", with: "&", options: [], range: nil)
        escapeStr = escapeStr.replacingOccurrences(of: "&quot;", with: "\"", options: [], range: nil)
        
        return escapeStr
    }
    
    class func encodeClipboardURL() {
        let pasteboard = UIPasteboard.general
        if let clipboardText = pasteboard.value(forPasteboardType: "public.text") as? String {
            if clipboardText.hasPrefix("http://") || clipboardText.hasPrefix("https://") {
                if let encodedURL = clipboardText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    pasteboard.setValue(encodedURL, forPasteboardType: "public.text")
                    let shortener = UrlShortener()
                    shortener.shortenUrl(encodedURL, with: UrlShortenerServiceIsgd, completion: { (shortUrl) -> Void in
                        if (shortUrl?.hasPrefix("http://"))! || (shortUrl?.hasPrefix("https://"))! {
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
    
    func cleanDictionary(_ dict: NSDictionary)->NSMutableDictionary {
        let mutableDict: NSMutableDictionary = NSMutableDictionary(dictionary: dict)
        mutableDict.enumerateKeysAndObjects(
            options: NSEnumerationOptions.concurrent) { (key, obj, stop) in
            if ((obj as AnyObject).isKind(of: NSNull.classForCoder())) {
                if let safeKey = key as? NSString {
                    mutableDict.setObject("", forKey: safeKey)
                }
            } else if ((obj as AnyObject).isKind(of: NSDictionary.classForCoder())) {
                if let safeObject = obj as? NSDictionary, let safeKey = key as? NSString {
                    mutableDict.setObject(self.cleanDictionary(safeObject), forKey: (safeKey))
                }
            }
        }
        // 未読フラグは保存時には削除する
        if mutableDict.object(forKey: "unread") as? Bool != nil {
            mutableDict.removeObject(forKey: "unread")
        }
        return mutableDict
    }
    
    func initAPISession(_ success:@escaping () -> Void, failure:@escaping (NSError) -> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.sessionManager = AFHTTPRequestOperationManager()
        self.sessionManager.requestSerializer.setValue(ApplicationSecrets.Secret(), forHTTPHeaderField: "Whalebird-Key")
        let requestURL = self.whalebirdAPIURL + "users/apis.json"
        self.sessionManager.get(requestURL, parameters: nil, success: { (operation, responseObject) -> Void in
            print(responseObject)
            self.saveCookie()
            let userDefault = UserDefaults.standard
            userDefault.set((responseObject as! [String: Any])["screen_name"], forKey: "username")
            success()
        }) { (operation, error) -> Void in
            print(error)
            self.displayErrorMessage(operation!, error: error as! NSError)
            SVProgressHUD.dismiss()
            failure(error as! NSError)
        }
        
    }
    
    func getArrayAPI(_ path: String, displayError: Bool, params: Dictionary<String, AnyObject>, completed: @escaping ([NSDictionary]) ->Void, failed: @escaping () -> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            let requestURL = self.whalebirdAPIURL + path
            self.sessionManager.get(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if let object = responseObject as? NSArray {
                    completed(object.reverseObjectEnumerator().allObjects as! [NSDictionary])
                } else {
                    print("blank response")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                if displayError {
                    self.displayErrorMessage(operation!, error: error as! NSError)
                }
                failed()
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func getDictionaryAPI(_ path: String, params: Dictionary<String, AnyObject>, callback: @escaping (NSDictionary) ->Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            let requestURL = self.whalebirdAPIURL + path
            self.sessionManager.get(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if let object = responseObject as? NSDictionary {
                    callback(object)
                } else {
                    print("blank response")
                    let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Request Error", message: "情報がありません")
                    notice?.alpha = 0.8
                    notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                    notice?.show()
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.displayErrorMessage(operation!, error: error as! NSError)
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func postAnyObjectAPI(_ path: String, params: Dictionary<String, AnyObject>, callback: @escaping (AnyObject) ->Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            let requestURL = self.whalebirdAPIURL + path
            self.sessionManager.post(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback(operation!)
                } else {
                    print("blank response")
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.displayErrorMessage(operation!, error: error as! NSError)
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func postImage(_ image: UIImage, progress: @escaping (Float) -> Void, complete: @escaping (NSDictionary) -> Void, failed: @escaping (NSError?)-> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            self.sessionManager.responseSerializer = AFHTTPResponseSerializer()
            do {
                let request = try self.sessionManager.requestSerializer.multipartFormRequest(withMethod: "POST",
                    urlString: self.whalebirdAPIURL + "users/apis/upload.json",
                    parameters: [:],
                    constructingBodyWith: { (formData: AFMultipartFormData?) -> Void in
                        formData?.appendPart(
                            withFileData: NSData(data: UIImagePNGRepresentation(image)!) as Data,
                            name: "media",
                            fileName: "test.png",
                            mimeType: "image/png")
                    
                    }, error:())
                
                let operation = self.sessionManager.httpRequestOperation(with: request as URLRequest!, success: { (operation, responseObject) -> Void in
                    if (responseObject != nil) {
                        print(responseObject)
                        if let object = responseObject as? Data {
                            do {
                                let jsonData = try JSONSerialization.jsonObject(with: object, options: JSONSerialization.ReadingOptions.allowFragments)
                                complete(jsonData as! NSDictionary)
                            } catch {
                                failed(nil)
                            }
                        }
                    }
                    }) { (operation, error) -> Void in
                        print(error)
                        self.displayErrorMessage(operation!, error: error as! NSError)
                        failed(error as NSError?)
                }
                
                operation?.setUploadProgressBlock { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                    let written = Float(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                    progress(written)
                }
                
                self.sessionManager.operationQueue.addOperation(operation!)
            } catch {
                failed(nil)
            }
        } else {
            self.regenerateSession()
        }
    }
    
    func syncPushSettings(_ callback: @escaping (AnyObject) ->Void) {
        let userDefault = UserDefaults.standard
        var notificationBackgroundFlag = true
        if userDefault.object(forKey: "notificationBackgroundFlag") != nil {
            notificationBackgroundFlag = userDefault.bool(forKey: "notificationBackgroundFlag")
        }
        var notificationReplyFlag = true
        if userDefault.object(forKey: "notificationReplyFlag") != nil {
            notificationReplyFlag = userDefault.bool(forKey: "notificationReplyFlag")
        }
        var notificationRTFlag = true
        if userDefault.object(forKey: "notificationRTFlag") != nil {
            notificationRTFlag = userDefault.bool(forKey: "notificationRTFlag")
        }
        var notificationFavFlag = true
        if userDefault.object(forKey: "notificationFavFlag") != nil {
            notificationFavFlag = userDefault.bool(forKey: "notificationFavFlag")
        }
        var notificationDMFlag = true
        if userDefault.object(forKey: "notificationDMFlag") != nil {
            notificationDMFlag = userDefault.bool(forKey: "notificationDMFlag")
        }
        var params: Dictionary<String, AnyObject> = [
            "notification" : notificationBackgroundFlag as AnyObject,
            "reply" : notificationReplyFlag as AnyObject,
            "retweet" : notificationRTFlag as AnyObject,
            "favorite" : notificationFavFlag as AnyObject,
            "direct_message" : notificationDMFlag as AnyObject
        ]
        if let deviceToken = userDefault.string(forKey: "deviceToken") {
            params["device_token"] = deviceToken as AnyObject?
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/update_settings.json", params: cParameter) { (operation) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                callback(operation)
            })
        }
    }
    
    func deleteSsessionAPI(_ path: String, params: Dictionary<String, AnyObject>,callback: @escaping (AnyObject) -> Void) {
        if !self.confirmConnectedNetwork() {
            SVProgressHUD.dismiss()
            return
        }
        self.loadCookie()
        if (self.sessionManager != nil) {
            let requestURL = self.whalebirdAPIURL + path
            self.sessionManager.delete(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback(operation!)
                } else {
                    print("blank response")
                    callback(operation!)
                }
            }, failure: { (operation, error) -> Void in
                print(error)
                self.displayErrorMessage(operation!, error: error as! NSError)
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
        let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
        notice?.alpha = 0.8
        notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
        notice?.show()
        SVProgressHUD.dismiss()
    }
    
    func loadCookie() {
        if let cookiesData = UserDefaults.standard.object(forKey: "cookiesKey") as? Data {
            if let cookies = NSKeyedUnarchiver.unarchiveObject(with: cookiesData) as? NSArray {
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie as! HTTPCookie)
                }
                self.sessionManager = AFHTTPRequestOperationManager()
                self.sessionManager.requestSerializer.setValue(ApplicationSecrets.Secret(), forHTTPHeaderField: "Whalebird-Key")
            }
        }
    }
    
    func saveCookie() {
        let cookiesData = NSKeyedArchiver.archivedData(withRootObject: HTTPCookieStorage.shared.cookies!)
        UserDefaults.standard.set(cookiesData, forKey: "cookiesKey")
    }
    
    func removeSession() {
        self.sessionManager = nil
        UserDefaults.standard.set(nil, forKey: "cookiesKey")
    }
    
    func displayErrorMessage(_ operation: AFHTTPRequestOperation, error: NSError) {
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
            do {
                let jsonData = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.allowFragments)
                if (jsonData as AnyObject).object(forKey: "errors") as? String != nil {
                    errorMessage = (jsonData as AnyObject).object(forKey: "errors") as! String
                }
            } catch {
            }
        } else {
            errorMessage = "Status Code: " + String(operation.response.statusCode)
        }

        let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Server Error", message: errorMessage)
        notice?.alpha = 0.8
        notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
        notice?.show()
    }
    
    func confirmConnectedNetwork() ->Bool {
        if !(Reachability()?.isReachable)! {
            let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Network Error", message: "ネットワークに接続できません")
            notice?.alpha = 0.8
            notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
            notice?.show()
            return false
        }
        return true
    }
}
