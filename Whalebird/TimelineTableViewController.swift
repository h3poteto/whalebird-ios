
//
//  TimelineTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Accounts
import Social

class TimelineTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var accountStore: ACAccountStore = ACAccountStore()
    var account: ACAccount = ACAccount()
    var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    
    var timelineCell: Array<AnyObject> = []
    var refreshTimeline: UIRefreshControl!
    
    var newTweetButton: UIBarButtonItem!
    var sinceId: String?
    
    //=========================================
    //  instance method
    //=========================================
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "タイムライン"
        self.tabBarItem.image = UIImage(named: "Home.png")
    }
    
    override init() {
        super.init()
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    

    // TODO: 下方向への更新，未読分を実装
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshTimeline = UIRefreshControl()
        self.refreshTimeline.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshTimeline)
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")

        // updateTimeline(0)
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("homeTimelineSinceId") as String?
        self.sinceId = getSinceId
        
        var homeTimeline = userDefaults.arrayForKey("homeTimeline") as Array?
        if (homeTimeline != nil) {
            for tweet in homeTimeline! {
                self.currentTimeline.insert(tweet, atIndex: 0)
            }
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Home用のUserstream
        var userDefault = NSUserDefaults.standardUserDefaults()
        if (userDefault.boolForKey("userstreamFlag")) {
            let stream_url = NSURL(string: "https://userstream.twitter.com/1.1/user.json")
            let params: Dictionary<String,String> = [
                "with" : "followings"
            ]
            UserstreamAPIClient.sharedClient.timelineTable = self
            UserstreamAPIClient.sharedClient.startStreaming(stream_url!, params: params, callback: {data in
            })
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
        
        self.timelineCell.insert(cell!, atIndex: indexPath.row)

        cell!.cleanCell()
        cell!.configureCell(self.currentTimeline[indexPath.row] as NSDictionary)

        return cell!
    }
    
/*
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.timelineCell.count > 0 && indexPath.row < self.timelineCell.count) {
            var cell: TimelineViewCell  = self.timelineCell.objectAtIndex(indexPath.row) as TimelineViewCell
            height = cell.cellHeight()
        } else {
            height = 60.0
        }
        return height
    }

*/
    // TODO: 遷移して戻ってきた時に上手くestimateできないため位置がずれる
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.timelineCell.count > 0 && indexPath.row < self.timelineCell.count) {
            var cell: TimelineViewCell  = self.timelineCell[indexPath.row] as TimelineViewCell
            height = cell.cellHeight()
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
            retweeted_name: tweetData.objectForKey("retweeted")?.objectForKey("screen_name") as? String,
            retweeted_profile_image: tweetData.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String
        )
        self.navigationController!.pushViewController(detailView, animated: true)
    }


    
    func updateTimeline(since_id: String?) {
        var params: Dictionary<String, String>
        if (since_id != nil) {
            params = [
                "contributor_details" : "true",
                "trim_user" : "0",
                "count" : "20",
                "since_id" : since_id as String!
            ]
        } else {
            params = [
                "contributor_details" : "true",
                "trim_user" : "0",
                "count" : "20"
            ]
        }
        var parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/home_timeline.json", params: parameter, callback: {new_timeline in
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
        })
        
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
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: "homeTimeline")
        userDefaults.setObject(self.sinceId, forKey: "homeTimelineSinceId")
    }
}
