
//
//  TimelineTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    //=============================================
    //  instance variables
    //=============================================
    let tweetCount = Int(50)
    var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    
    var refreshTimeline: ODRefreshControl!
    
    var newTweetButton: UIBarButtonItem!
    var sinceId: String?
    
    //=========================================
    //  instance methods
    //=========================================
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "タイムライン"
        self.tabBarItem.image = UIImage(named: "assets/Home.png")
    }
    
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshTimeline = ODRefreshControl(inScrollView: self.tableView)
        self.refreshTimeline.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "tappedNewTweet")
        self.navigationItem.rightBarButtonItem = self.newTweetButton

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")

        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("homeTimelineSinceId") as String?
        self.sinceId = getSinceId
        
        if var homeTimeline = userDefaults.arrayForKey("homeTimeline") as Array? {
            for tweet in homeTimeline {
                self.currentTimeline.insert(tweet, atIndex: 0)
            }
            if var moreID = self.currentTimeline.last?.objectForKey("id_str") as? String {
                var readMoreDictionary = NSMutableDictionary(dictionary: [
                    "moreID" : moreID,
                    "sinceID" : "sinceID"
                    ])
                self.currentTimeline.insert(readMoreDictionary, atIndex: self.currentTimeline.count)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Home用のUserstream
        self.prepareUserstream()
    }
    
    func prepareUserstream() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        if (userDefault.boolForKey("userstreamFlag") && !UserstreamAPIClient.sharedClient.livingStream()) {
            let cStreamURL = NSURL(string: "https://userstream.twitter.com/1.1/user.json")
            let cParams: Dictionary<String,String> = [
                "with" : "followings"
            ]
            UserstreamAPIClient.sharedClient.timelineTable = self
            UserstreamAPIClient.sharedClient.startStreaming(cStreamURL!, params: cParams, callback: {data in
            })
        }
    }
    
    func appDidBecomeActive(notification: NSNotification) {
        self.prepareUserstream()
    }
    
    func appWillResignActive(notification: NSNotification) {
        UserstreamAPIClient.sharedClient.stopStreaming { () -> Void in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.currentTimeline.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }

        cell!.cleanCell()
        if let targetTimeline = self.currentTimeline[indexPath.row] as? NSDictionary {
            cell!.configureCell(targetTimeline)
        }

        return cell!
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.currentTimeline[indexPath.row] as? NSDictionary {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.currentTimeline[indexPath.row] as? NSDictionary {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.currentTimeline[indexPath.row] as? NSDictionary {
            if (cTweetData.objectForKey("moreID") != nil && cTweetData.objectForKey("moreID") as! String != "moreID") {
                var sinceID = cTweetData.objectForKey("sinceID") as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateTimeline(sinceID, aMoreIndex: indexPath.row)
            } else {
                var detailView = TweetDetailViewController(
                    aTweetID: cTweetData.objectForKey("id_str") as! String,
                    aTweetBody: cTweetData.objectForKey("text")as! String,
                    aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as! String,
                    aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as! String,
                    aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as! String,
                    aPostDetail: cTweetData.objectForKey("created_at") as! String,
                    aRetweetedName: cTweetData.objectForKey("retweeted")?.objectForKey("screen_name") as? String,
                    aRetweetedProfileImage: cTweetData.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String,
                    aFavorited: cTweetData.objectForKey("favorited?") as? Bool,
                    aMedia: cTweetData.objectForKey("media") as? NSArray,
                    aParentArray: &self.currentTimeline,
                    aParentIndex: indexPath.row,
                    aProtected: cTweetData.objectForKey("user")?.objectForKey("protected?") as? Bool
                )
                self.navigationController?.pushViewController(detailView, animated: true)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }


    
    func updateTimeline(aSinceID: String?, aMoreIndex: Int?) {
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        if (aSinceID != nil) {
            params["since_id"] = aSinceID as String!
        }
        if (aMoreIndex != nil) {
            if var strMoreID = (self.currentTimeline[aMoreIndex!] as! NSDictionary).objectForKey("moreID") as? String {
                // max_idは「以下」という判定になるので自身を含めない
                // iPhone5以下は32bitなので，Intで扱える範囲を超える
                params["max_id"] = BigInteger(string: strMoreID).decrement()
            }
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/home_timeline.json", params: cParameter, callback: {aNewTimeline in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = []
                for timeline in aNewTimeline {
                    if var mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                        self.newTimeline.append(mutableTimeline)
                    }
                }
                var currentRowIndex: Int?
                if (self.newTimeline.count > 0) {
                    if (aMoreIndex == nil) {
                        // refreshによる更新
                        // index位置固定は保留
                        if (self.newTimeline.count >= self.tweetCount) {
                            var moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                            var readMoreDictionary = NSMutableDictionary()
                            if (self.currentTimeline.count > 0) {
                                var sinceID = self.currentTimeline.first?.objectForKey("id_str") as! String
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
                            self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                        }
                        if (self.currentTimeline.count > 0) {
                            currentRowIndex = self.newTimeline.count
                        }
                        for newTweet in self.newTimeline {
                            self.currentTimeline.insert(newTweet, atIndex: 0)
                            self.sinceId = (newTweet as! NSDictionary).objectForKey("id_str") as? String
                        }
                    } else {
                        // readMoreを押した場合
                        // tableの途中なのかbottomなのかの判定
                        if (aMoreIndex == self.currentTimeline.count - 1) {
                            // bottom
                            var moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                            var readMoreDictionary = NSMutableDictionary(dictionary: [
                                "moreID" : moreID,
                                "sinceID" : "sinceID"
                                ])
                            self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                            self.currentTimeline.removeLast()
                            self.currentTimeline += self.newTimeline.reverse()
                        } else {
                            // 途中
                            if (self.newTimeline.count >= self.tweetCount) {
                                var moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                var sinceID = (self.currentTimeline[aMoreIndex! + 1] as! NSDictionary).objectForKey("id_str") as! String
                                var readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : sinceID
                                    ])
                                self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                            }
                            self.currentTimeline.removeAtIndex(aMoreIndex!)
                            for newTweet in self.newTimeline {
                                self.currentTimeline.insert(newTweet, atIndex: aMoreIndex!)
                            }
                            
                        }
                    }
                
                    self.tableView.reloadData()
                    var userDefault = NSUserDefaults.standardUserDefaults()
                    if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                        var indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    }

                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(aNewTimeline.count) + "件更新")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                    notice.show()
                } else {
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "新着なし")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                    notice.show()
                }
            })
        })
        
    }
    
    func onRefresh() {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    func tappedNewTweet() {
        var newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }

    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        let cTimelineMin = min(self.currentTimeline.count, self.tweetCount)
        if (cTimelineMin < 1) {
            return
        }
        for timeline in self.currentTimeline[0...(cTimelineMin - 1)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as! NSDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: "homeTimeline")
        userDefaults.setObject(self.sinceId, forKey: "homeTimelineSinceId")
    }
    
    func clearData() {
        self.currentTimeline = []
        self.newTimeline = []
        self.sinceId = nil
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "homeTimelineSinceID")
        userDefaults.setObject(nil, forKey: "homeTimeline")
        self.tableView.reloadData()
    }
}
