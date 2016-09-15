//
//  TimelineModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/07/25.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

protocol TimelineModelDelegate {
    func updateTimelineFromUserstream(_ timelineModel: TimelineModel)
}

class TimelineModel: NSObject {
    //=============================================
    //  instance variables
    //=============================================
    let tweetCount = Int(50)
    fileprivate var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    
    var sinceId: String?
    var userstreamApiClient: UserstreamAPIClient?
    
    var delegate: TimelineModelDelegate!
    
    // class methods
    class func selectMoreIdCell(_ tweetData: NSDictionary)-> Bool {
        if tweetData.object(forKey: "moreID") != nil && tweetData.object(forKey: "moreID") as! String != "moreID" {
            return true
        } else {
            return false
        }
    }
    
    
    convenience init(initSinceId: String?, initTimeline: Array<AnyObject>?) {
        self.init()
        self.sinceId = initSinceId
        
        if initTimeline != nil {
            for tweet in initTimeline! {
                self.currentTimeline.insert(tweet, at: 0)
            }
            if let moreID = self.currentTimeline.last?.object(forKey: "id_str") as? String {
                let readMoreDictionary = NSMutableDictionary(dictionary: [
                    "moreID" : moreID,
                    "sinceID" : "sinceID"
                    ])
                self.currentTimeline.insert(readMoreDictionary, at: self.currentTimeline.count)
            }
        }
    }


    
    func count()-> Int {
        return self.currentTimeline.count
    }
    
    func getTweetAtIndex(_ index: Int)-> [AnyHashable: Any]? {
        if let body = self.currentTimeline[index].value(forKey: "text") as? String {
            TagsList.sharedClient.findAndAddtag(body)
        }
        return self.currentTimeline[index] as? [AnyHashable: Any]
    }
    
    func setTweetAtIndex(_ index: Int, object: [AnyHashable: Any]) {
        self.currentTimeline[index] = object as AnyObject
    }
    
    func updateTimeline(_ APIPath: String, aSinceID: String?, aMoreIndex: Int?, streamElement: StreamList.Stream? ,completed: @escaping (Int, Int?)-> Void, noUpdated: @escaping ()-> Void, failed: @escaping ()-> Void) {

        var apiURL = APIPath
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        if (aSinceID != nil) {
            params["since_id"] = aSinceID as String!
        }
        if (aMoreIndex != nil) {
            if let strMoreID = (self.currentTimeline[aMoreIndex!] as! NSDictionary).object(forKey: "moreID") as? String {
                // max_idは「以下」という判定になるので自身を含めない
                // iPhone5以下は32bitなので，Intで扱える範囲を超える
                params["max_id"] = BigInteger(string: strMoreID).decrement()
            }
        }
        var requestParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        
        // リストのと場合だけパラメータを上書きする必要がある
        if streamElement != nil {
            apiURL = "users/apis/list_timeline.json"
            switch streamElement!.type {
            case "list":
                params["list_id"] = streamElement!.id as String!
                break
            case "myself":
                apiURL = streamElement!.uri
                break
            case "search":
                apiURL = streamElement!.uri
                break
            default:
                break
            }
            
            let userDefault = UserDefaults.standard
            requestParameter["settings"] = params as AnyObject?
            requestParameter["screen_name"] = userDefault.object(forKey: "username") as! String as AnyObject?
            requestParameter["q"] = streamElement!.name as AnyObject?
        }
        WhalebirdAPIClient.sharedClient.getArrayAPI(apiURL, displayError: true, params: requestParameter,
            completed: {aNewTimeline in
                let q_main = DispatchQueue.main
                q_main.async(execute: {()->Void in
                    self.newTimeline = []
                    for timeline in aNewTimeline{
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    if aMoreIndex == nil {
                        // 未読フラグの削除
                        for i in 0 ..< self.currentTimeline.count {
                            if (self.currentTimeline[i] as? NSDictionary)?.object(forKey: "unread") as? Bool != nil {
                                (self.currentTimeline[i] as? NSMutableDictionary)?.removeObject(forKey: "unread")
                            }
                        }
                    }

                    var currentRowIndex: Int?
                    if (self.newTimeline.count > 0) {
                        if (aMoreIndex == nil) {
                            // refreshによる更新
                            // index位置固定は保留
                            if (self.newTimeline.count >= self.tweetCount) {
                                let moreID = self.newTimeline.first?.object(forKey: "id_str") as! String
                                var readMoreDictionary = NSMutableDictionary()
                                if (self.currentTimeline.count > 0) {
                                    let sinceID = self.currentTimeline.first?.object(forKey: "id_str") as! String
                                    readMoreDictionary = NSMutableDictionary(dictionary: [
                                        "moreID" : moreID,
                                        "sinceID" : sinceID
                                        ])
                                } else {
                                    readMoreDictionary = NSMutableDictionary(dictionary: [
                                        "moreID" : moreID,
                                        "sinceID" : "sinceID"
                                        ])
                                }
                                self.newTimeline.insert(readMoreDictionary, at: 0)
                            }
                            if (self.currentTimeline.count > 0) {
                                currentRowIndex = self.newTimeline.count
                            }
                            for newTweet in self.newTimeline {
                                if let tweetObject = newTweet as? NSMutableDictionary {
                                    // 未読フラグの追加
                                    tweetObject.setObject(true, forKey: "unread" as NSCopying)
                                    self.currentTimeline.insert(tweetObject, at: 0)
                                    self.sinceId = tweetObject.object(forKey: "id_str") as? String
                                }
                            }
                        } else {
                            // readMoreを押した場合
                            // tableの途中なのかbottomなのかの判定
                            if (aMoreIndex == self.currentTimeline.count - 1) {
                                // bottom
                                let moreID = self.newTimeline.first?.object(forKey: "id_str") as! String
                                let readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : "sinceID"
                                    ])
                                self.newTimeline.insert(readMoreDictionary, at: 0)
                                self.currentTimeline.removeLast()
                                self.currentTimeline += Array(self.newTimeline.reversed())
                            } else {
                                // 途中
                                if (self.newTimeline.count >= self.tweetCount) {
                                    let moreID = self.newTimeline.first?.object(forKey: "id_str") as! String
                                    let sinceID = (self.currentTimeline[aMoreIndex! + 1] as! NSDictionary).object(forKey: "id_str") as! String
                                    let readMoreDictionary = NSMutableDictionary(dictionary: [
                                        "moreID" : moreID,
                                        "sinceID" : sinceID
                                        ])
                                    self.newTimeline.insert(readMoreDictionary, at: 0)
                                }
                                self.currentTimeline.remove(at: aMoreIndex!)
                                for newTweet in self.newTimeline {
                                    self.currentTimeline.insert(newTweet, at: aMoreIndex!)
                                }
                                
                            }
                        }
                        completed(aNewTimeline.count, currentRowIndex)
                    } else {
                        noUpdated()
                    }
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    
    func updateTimelineWithoutMoreCell(_ APIPath: String, requestParameter: Dictionary<String, AnyObject>, moreIndex: Int?, completed: @escaping (Int, Int?)-> Void, noUpdated: ()-> Void, failed: @escaping ()-> Void) {
        WhalebirdAPIClient.sharedClient.getArrayAPI(APIPath, displayError: true, params: requestParameter,
            completed: { [unowned self] (aNewTimeline) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: {()->Void in
                    self.newTimeline = []
                    for timeline in aNewTimeline {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    if (moreIndex == nil) {
                        for newTweet in self.newTimeline {
                            self.currentTimeline.insert(newTweet, at: 0)
                        }
                    } else {
                        for newTweet in Array(self.newTimeline.reversed()) {
                            self.currentTimeline.append(newTweet)
                        }
                    }
                    
                    completed(aNewTimeline.count, nil)
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    func updateTimelineWitoutMoreAndSince(_ APIPath: String, requestParameter: Dictionary<String, AnyObject>, completed: @escaping (Int, Int?)-> Void, noUpdated: @escaping ()-> Void, failed: @escaping ()-> Void) {
        WhalebirdAPIClient.sharedClient.getArrayAPI(APIPath, displayError: true, params: requestParameter,
            completed: { (aNewResult) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: { () -> Void in
                    self.newTimeline = []
                    for timeline in aNewResult {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    if (self.newTimeline.count > 0) {
                        for newResult in self.newTimeline {
                            self.currentTimeline.insert(newResult, at: 0)
                        }
                        completed(aNewResult.count, nil)
                    } else {
                        noUpdated()
                    }
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    func updateTimelineOnlyNew(_ APIPath: String, requestParameter: Dictionary<String, AnyObject>, completed: @escaping (Int, Int?)-> Void, noUpdated: @escaping ()-> Void, failed: @escaping ()-> Void) {
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/conversations.json", displayError: true, params: requestParameter,
            completed: { (aNewTimeline) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: { () -> Void in
                    for timeline in aNewTimeline {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.insert(mutableTimeline, at: 0)
                        }
                    }
                    if self.newTimeline.count > 0 {
                        self.currentTimeline = self.newTimeline
                        completed(aNewTimeline.count, nil)
                    } else{
                        noUpdated()
                    }
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    func clearData() {
        self.currentTimeline = []
        self.newTimeline = []
        self.sinceId = nil
    }
    
    func saveCurrentTimeline(_ timelineKey: String, sinceIdKey: String) {
        let userDefaults = UserDefaults.standard
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        let cTimelineMin = min(self.currentTimeline.count, self.tweetCount)
        if (cTimelineMin < 1) {
            return
        }
        for timeline in self.currentTimeline[0...(cTimelineMin - 1)] {
            let dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as! NSDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.set(Array(cleanTimelineArray.reversed()), forKey: timelineKey)
        userDefaults.set(self.sinceId, forKey: sinceIdKey)
    }
    
    func addFavorite(_ index: Int) {
        if var object = self.getTweetAtIndex(index) {
            object["favorited?"] = 1
            self.setTweetAtIndex(index, object: object)
        }
    }
    
    func deleteFavorite(_ index: Int) {
        if var object = self.getTweetAtIndex(index) {
            object["favorited?"] = 0
            self.setTweetAtIndex(index, object: object)
        }
    }
    
    //----------------------------------------------
    // userstream用
    //----------------------------------------------
    func prepareUserstream() {
        let userDefault = UserDefaults.standard
        if (userDefault.bool(forKey: "userstreamFlag") && !UserstreamAPIClient.sharedClient.livingStream()) {
            let cStreamURL = URL(string: "https://userstream.twitter.com/1.1/user.json")
            let cParams: Dictionary<String,String> = [
                "with" : "followings"
            ]
            UserstreamAPIClient.sharedClient.timeline = self
            UserstreamAPIClient.sharedClient.startStreaming(cStreamURL!, params: cParams, callback: {data in
            })
        }
    }
    
    func realtimeUpdate(_ object: NSMutableDictionary) {
        self.currentTimeline.insert(object, at: 0)
        self.sinceId = object.object(forKey: "id_str") as? String
        // hometimelineの更新
        self.delegate.updateTimelineFromUserstream(self)
    }
    
    func stopUserstream() {
        UserstreamAPIClient.sharedClient.stopStreaming { () -> Void in
        }
    }
    //------------------------------------------------
}
