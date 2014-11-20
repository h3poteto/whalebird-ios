//
//  ReplyTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ReplyTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    var timelineCell: Array<AnyObject> = []
    
    var refreshTimeline: UIRefreshControl!
    var newTweetButton: UIBarButtonItem!
    
    var sinceId: String?
    
    //========================================
    //  instance method
    //========================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リプライ"
        self.tabBarItem.image = UIImage(named: "Speaking-Line.png")
    }
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init() {
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.refreshTimeline = UIRefreshControl()
        self.refreshTimeline.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshTimeline)

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
            var moreID = self.currentTimeline.last?.objectForKey("id_str") as String
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
        self.timelineCell.insert(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        cell!.configureCell(self.currentTimeline[indexPath.row] as NSDictionary)

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.timelineCell.count > 0 && indexPath.row < self.timelineCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentTimeline[indexPath.row] as NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.timelineCell.count > 0 && indexPath.row < self.timelineCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentTimeline[indexPath.row] as NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweetData = self.currentTimeline[indexPath.row] as NSDictionary
        if (tweetData.objectForKey("moreID") != nil && tweetData.objectForKey("moreID") as String != "moreID") {
            var sinceID = tweetData.objectForKey("sinceID") as? String
            if (sinceID == "sinceID") {
                sinceID = nil
            }
            self.updateTimeline(sinceID, more_index: indexPath.row)
        } else {
            var detailView = TweetDetailViewController(
                tweet_id: tweetData.objectForKey("id_str") as String,
                tweet_body: tweetData.objectForKey("text") as String,
                screen_name: tweetData.objectForKey("user")?.objectForKey("screen_name") as String,
                user_name: tweetData.objectForKey("user")?.objectForKey("name") as String,
                profile_image: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as String,
                post_detail: tweetData.objectForKey("created_at") as String,
                retweeted_name: tweetData.objectForKey("retweeted")?.objectForKey("screen_name") as? String,
                retweeted_profile_image: tweetData.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String
            )
            self.navigationController!.pushViewController(detailView, animated: true)
        }
    }


    
    func updateTimeline(since_id: String?, more_index: Int?) {
        var params: Dictionary<String, String> = [
            "count" : "20"
        ]
        if (since_id != nil) {
            params["since_id"] = since_id as String!
        }
        if (more_index != nil) {
            var strMoreID = (self.currentTimeline[more_index!] as NSDictionary).objectForKey("moreID") as String
            // max_idは「以下」という判定になるので自身を含めない
            var intMoreID = strMoreID.toInt()! - 1
            params["max_id"] = String(intMoreID)
        }
        var parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/mentions.json", params: parameter, callback: {new_timeline in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                if (self.newTimeline.count > 0) {
                    if (more_index == nil) {
                        // refreshによる更新
                        if (self.newTimeline.count >= 20) {
                            var moreID = self.newTimeline.first?.objectForKey("id_str") as String
                            var readMoreDictionary = NSMutableDictionary()
                            if (self.currentTimeline.count > 0) {
                                var sinceID = self.currentTimeline.first?.objectForKey("id_str") as String
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
                        for new_tweet in self.newTimeline {
                            self.currentTimeline.insert(new_tweet, atIndex: 0)
                            self.sinceId = (new_tweet as NSDictionary).objectForKey("id_str") as String?
                        }
                    } else {
                        // readMoreを押した場合
                        // tableの途中なのかbottomなのかの判定
                        if (more_index == self.currentTimeline.count - 1) {
                            // bottom
                            var moreID = self.newTimeline.first?.objectForKey("id_str") as String
                            var readMoreDictionary = NSMutableDictionary(dictionary: [
                                "moreID" : moreID,
                                "sinceID" : "sinceID"
                                ])
                            self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                            self.currentTimeline.removeLast()
                            self.currentTimeline += self.newTimeline.reverse()
                        } else {
                            // 途中
                            if (self.newTimeline.count >= 20) {
                                var moreID = self.newTimeline.first?.objectForKey("id_str") as String
                                var sinceID = (self.currentTimeline[more_index! + 1] as NSDictionary).objectForKey("id_str") as String
                                var readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : sinceID
                                    ])
                                self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                            }
                            self.currentTimeline.removeAtIndex(more_index!)
                            for new_tweet in self.newTimeline {
                                self.currentTimeline.insert(new_tweet, atIndex: more_index!)
                            }
                            
                        }
                    }
                    
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(new_timeline.count) + "件更新")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                    self.tableView.reloadData()
                } else {
                    
                }
                SVProgressHUD.dismiss()
            })
        })

    }
    
    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.sinceId, more_index: nil)
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
        let timelineMin = min(self.currentTimeline.count, 20)
        if (timelineMin <= 0) {
            return
        }
        for timeline in self.currentTimeline[0...(timelineMin - 2)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as NSMutableDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: "replyTimeline")
        userDefaults.setObject(self.sinceId, forKey: "replyTimelineSinceId")
    }
}

