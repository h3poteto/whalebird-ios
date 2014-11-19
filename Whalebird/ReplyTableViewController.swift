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
        
        //updateTimeline(0)
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("replyTimelineSinceId") as String?
        self.sinceId = getSinceId
        
        var replyTimeline = userDefaults.arrayForKey("replyTimeline") as Array?
        if (replyTimeline != nil) {
            for tweet in replyTimeline! {
                self.currentTimeline.insert(tweet, atIndex: 0)
            }
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
        var detailView = TweetDetailViewController(
            tweet_id: tweetData.objectForKey("id_str") as String,
            tweet_body: tweetData.objectForKey("text") as String,
            screen_name: tweetData.objectForKey("user")?.objectForKey("screen_name") as String,
            user_name: tweetData.objectForKey("user")?.objectForKey("name") as String,
            profile_image: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as String,
            post_detail: tweetData.objectForKey("created_at") as String,
            retweeted_name: nil,
            retweeted_profile_image: nil
        )
        self.navigationController!.pushViewController(detailView, animated: true)
    }


    
    func updateTimeline(since_id: String?) {
        var params: Dictionary<String, String>
        if (since_id != nil) {
            params = [
                "count" : "20",
                "since_id" : since_id as String!
            ]
        } else {
            params = [
                "count" : "20"
            ]
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/mentions.json", params: parameter) { (new_timeline) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                for new_tweet in self.newTimeline {
                    self.currentTimeline.insert(new_tweet, atIndex: 0)
                    self.sinceId = (new_tweet as NSDictionary).objectForKey("id_str") as String?
                }
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(self.newTimeline.count) + "件更新")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.sinceId)
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
        for timeline in self.currentTimeline[0...(timelineMin - 1)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as NSMutableDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: "replyTimeline")
        userDefaults.setObject(self.sinceId, forKey: "replyTimelineSinceId")
    }
}

