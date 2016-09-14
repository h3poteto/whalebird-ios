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
import NoticeView
import ReachabilitySwift

class UserstreamAPIClient: NSURLConnection, NSURLConnectionDataDelegate {

    // シングルトンにするよ
    class var sharedClient: UserstreamAPIClient {
    struct sharedStruct {
        static let _sharedClient = UserstreamAPIClient()
        }
        return sharedStruct._sharedClient
    }
    
    //=============================================
    //  instance variables
    //=============================================
    var account: ACAccount!
    var accountStore = ACAccountStore()
    var connection: NSURLConnection?
    var timeline: TimelineModel!
    
    //=======================================
    //  class methods
    //=======================================
    // localeの設定をしないと，実機で落ちる
    class func convertUTCTime(_ aSrctime: String) -> String {
        var dstDate = String()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZ yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "UTC")
        if let srcDate = dateFormatter.date(from: aSrctime as String) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dstDate = dateFormatter.string(from: srcDate)
        }
        return dstDate
    }
    
    class func convertRetweet(_ aDictionary: NSMutableDictionary) -> NSMutableDictionary {
        let mutableDictionary = aDictionary.mutableCopy() as! NSMutableDictionary
        let cOriginalText = (mutableDictionary.object(forKey: "retweeted_status") as AnyObject).object(forKey: "text") as! String
        let cOriginalCreatedAt = UserstreamAPIClient.convertUTCTime((mutableDictionary.object(forKey: "retweeted_status") as AnyObject).object(forKey: "created_at") as! String)
        let cOriginalName = ((mutableDictionary.object(forKey: "retweeted_status") as AnyObject).object(forKey: "user") as! NSDictionary).object(forKey: "name") as! String
        let cOriginalScreenName = ((mutableDictionary.object(forKey: "retweeted_status") as AnyObject).object(forKey: "user") as! NSDictionary).object(forKey: "screen_name") as! String
        let cOriginalProfileImageURL = ((mutableDictionary.object(forKey: "retweeted_status") as AnyObject).object(forKey: "user") as! NSDictionary).object(forKey: "profile_image_url_https") as! String
        let cPostName = (mutableDictionary.object(forKey: "user") as AnyObject).object(forKey: "name") as! String
        let cPostScreenName = (mutableDictionary.object(forKey: "user") as AnyObject).object(forKey: "screen_name") as! String
        let cPostProfileImageURL = (mutableDictionary.object(forKey: "user") as AnyObject).object(forKey: "profile_image_url_https") as! String
        
        mutableDictionary.setValue(cOriginalText, forKey: "text")
        mutableDictionary.setValue(cOriginalCreatedAt, forKey: "created_at")
    
        let userDictionay = NSMutableDictionary(dictionary: [
            "name" : cOriginalName,
            "screen_name" : cOriginalScreenName,
            "profile_image_url" : cOriginalProfileImageURL,
            "protected?" : false
        ])
        mutableDictionary.setValue(userDictionay, forKey: "user")
        
        let retweetedDictionary = NSMutableDictionary(dictionary: [
            "name" : cPostName,
            "screen_name" : cPostScreenName,
            "profile_image_url" : cPostProfileImageURL
        ])
        mutableDictionary.setValue(retweetedDictionary, forKey: "retweeted")
        
        
        return mutableDictionary
    }
    
    class func convertMedia(_ aDictionary: NSMutableDictionary) -> NSMutableDictionary {
        let mutableDictionary = aDictionary.mutableCopy() as! NSMutableDictionary
        let cOriginalMedia = (mutableDictionary.object(forKey: "entities") as AnyObject).object(forKey: "media") as! NSArray
        let mediaURLArray = NSMutableArray()
        for media in cOriginalMedia {
            mediaURLArray.add((media as AnyObject).object(forKey: "media_url_https")!)
        }
        mutableDictionary.setValue(mediaURLArray, forKey: "media")
        
        // video
        let videoURLArray = NSMutableArray()
        let cOriginalVideo = (mutableDictionary.object(forKey: "extended_entities") as AnyObject).object(forKey: "media") as! NSArray
        for anime in cOriginalVideo {
            if (anime as AnyObject).object(forKey: "type") as! String == "animated_gif" {
                var video: String! = ""
                if let variants = ((anime as AnyObject).object(forKey: "video_info") as AnyObject).object(forKey: "variants") as? NSArray {
                    video = (variants.object(at: 0) as! NSDictionary).object(forKey: ("url")) as? String ?? ""
                }
                videoURLArray.add(video)
            } else {
                videoURLArray.add("")
            }
        }
        mutableDictionary.setValue(videoURLArray, forKey: "video")
        return mutableDictionary
    }
    
    //=======================================
    //  instance methods
    //=======================================
    
    func startStreaming(_ aTargetStream: URL, params: Dictionary<String,String>, callback:(ACAccount)->Void) {
        if !self.confirmConnectedNetwork() {
            return
        }
        let request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, url: aTargetStream, parameters: params)
        if let twitterAccountType: ACAccountType = self.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter) {
            let twitterAccounts = self.accountStore.accounts(with: twitterAccountType)!
            if (twitterAccounts.count > 0) {
                let userDefault = UserDefaults.standard
                let cUsername = userDefault.string(forKey: "username")
                var selectedAccount: ACAccount?
                for aclist in twitterAccounts {
                    if (cUsername == (aclist as AnyObject).username) {
                        selectedAccount = aclist as? ACAccount
                    }
                }
                if (selectedAccount == nil) {
                    let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
                    notice?.alpha = 0.8
                    notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                    notice?.show()
                } else {
                    self.account = selectedAccount
                    request.account = self.account
                    self.connection = NSURLConnection(request: request.preparedURLRequest(), delegate: self)
                    self.connection?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                    self.connection?.start()
                    callback(self.account)
                }
            }
        }
    }
    
    func stopStreaming(_ callback:()->Void) {
        if (self.connection != nil) {
            self.connection?.cancel()
            self.connection = nil
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
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        print(response)
    }
    
    func connection(_ connection: NSURLConnection,didReceive data: Data){
        var jsonError:NSError?
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            var object: NSMutableDictionary = jsonObject?.mutableCopy() as! NSMutableDictionary
            if (object.object(forKey: "text") != nil) {
                // datetimeをサーバー側のデータに合わせて加工しておく
                object.setValue(UserstreamAPIClient.convertUTCTime(object.object(forKey: "created_at") as! String), forKey: "created_at")
                print((object.object(forKey: "user") as AnyObject).object(forKey: "screen_name"))
                object.setValue(object.object(forKey: "favorited") as! Int, forKey: "favorited?")
                if (object.object(forKey: "retweeted_status") == nil) {
                    object.setValue(nil, forKey: "retweeted")
                } else {
                    object = UserstreamAPIClient.convertRetweet(object) as NSMutableDictionary
                }
                if ((object.object(forKey: "entities") as AnyObject).object(forKey: "media") == nil) {
                    object.setValue(nil, forKey: "media")
                } else {
                    object = UserstreamAPIClient.convertMedia(object) as NSMutableDictionary
                }
                self.timeline.realtimeUpdate(object)
            }
        } catch let error as NSError {
            jsonError = error
        }
    }
    func confirmConnectedNetwork() ->Bool {
        if !Reachability()!.isReachable {
            let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Network Error", message: "ネットワークに接続できません")
            notice?.alpha = 0.8
            notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
            notice?.show()
            return false
        }
        return true
    }
}
