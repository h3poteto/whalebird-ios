//
//  ReplyTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ReplyTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    //=============================================
    //  instance variables
    //=============================================
    var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    
    var refreshTimeline: ODRefreshControl!
    var newTweetButton: UIBarButtonItem!
    
    var sinceId: String?
    let tweetCount = Int(50)
    
    //=============================================
    //  instance methods
    //=============================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リプライ"
        self.tabBarItem.image = UIImage(named: "assets/Speaking-Line.png")
    }
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.refreshTimeline = ODRefreshControl(inScrollView: self.tableView)
        self.refreshTimeline.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("replyTimelineSinceId") as String?
        self.sinceId = getSinceId
        
        var replyTimeline = userDefaults.arrayForKey("replyTimeline") as Array?
        if (replyTimeline != nil) {
            for tweet in replyTimeline! {
                self.currentTimeline.insert(tweet, atIndex: 0)
            }
            var moreID = self.currentTimeline.last?.objectForKey("id_str") as! String
            var readMoreDictionary = NSMutableDictionary(dictionary: [
                "moreID" : moreID,
                "sinceID" : "sinceID"
                ])
            self.currentTimeline.insert(readMoreDictionary, atIndex: self.currentTimeline.count)
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
            cell = TimelineViewCell(style: .Default, reuseIdentifier: "TimelineViewCell")
        }
        cell!.cleanCell()
        cell!.configureCell(self.currentTimeline[indexPath.row] as! NSDictionary)

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        height = TimelineViewCell.estimateCellHeight(self.currentTimeline[indexPath.row] as! NSDictionary)
        return height
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        height = TimelineViewCell.estimateCellHeight(self.currentTimeline[indexPath.row] as! NSDictionary)
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cTweetData = self.currentTimeline[indexPath.row] as! NSDictionary
        if (cTweetData.objectForKey("moreID") != nil && cTweetData.objectForKey("moreID") as! String != "moreID") {
            var sinceID = cTweetData.objectForKey("sinceID") as? String
            if (sinceID == "sinceID") {
                sinceID = nil
            }
            self.updateTimeline(sinceID, aMoreIndex: indexPath.row)
        } else {
            var detailView = TweetDetailViewController(
                aTweetID: cTweetData.objectForKey("id_str") as! String,
                aTweetBody: cTweetData.objectForKey("text") as! String,
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
            self.navigationController!.pushViewController(detailView, animated: true)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


    
    func updateTimeline(aSinceID: String?, aMoreIndex: Int?) {
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        if (aSinceID != nil) {
            params["since_id"] = aSinceID as String!
        }
        if (aMoreIndex != nil) {
            var strMoreID = (self.currentTimeline[aMoreIndex!] as! NSDictionary).objectForKey("moreID") as! String
            // max_idは「以下」という判定になるので自身を含めない
            params["max_id"] = BigInteger(string: strMoreID).decrement()
        }
        var parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/mentions.json", params: parameter, callback: {aNewTimeline in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = []
                for timeline in aNewTimeline {
                    var mutableTimeline = timeline.mutableCopy() as! NSMutableDictionary
                    self.newTimeline.append(mutableTimeline)
                }
                var currentRowIndex: Int?
                if (self.newTimeline.count > 0) {
                    if (aMoreIndex == nil) {
                        // refreshによる更新
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
    
    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }
    
    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        let cTimelineMin = min(self.currentTimeline.count, self.tweetCount)
        if (cTimelineMin <= 0) {
            return
        }
        for timeline in self.currentTimeline[0...(cTimelineMin - 2)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as! NSDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: "replyTimeline")
        userDefaults.setObject(self.sinceId, forKey: "replyTimelineSinceId")
    }
    
    func clearData() {
        self.currentTimeline = []
        self.newTimeline = []
        self.sinceId = nil
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "replyTimelineSinceID")
        userDefaults.setObject(nil, forKey: "replyTimeline")
        self.tableView.reloadData()
    }
}

