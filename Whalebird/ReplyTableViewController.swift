//
//  ReplyTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ReplyTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var newTimeline = NSArray()
    var currentTimeline = NSMutableArray()
    var timelineCell = NSMutableArray()
    
    var refreshTimeline: UIRefreshControl!
    var newTweetButton: UIBarButtonItem!
    
    var sinceId: String?
    
    //========================================
    //  instance method
    //========================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "通知"
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
                self.currentTimeline.insertObject(tweet, atIndex: 0)
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
        self.timelineCell.insertObject(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        cell!.configureCell(self.currentTimeline.objectAtIndex(indexPath.row) as NSDictionary)

        return cell!
    }
    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweetData = self.currentTimeline.objectAtIndex(indexPath.row) as NSDictionary
        var detail_view = TweetDetailViewController(
            TweetID: tweetData.objectForKey("id_str") as NSString,
            TweetBody: tweetData.objectForKey("text") as NSString,
            ScreenName: tweetData.objectForKey("user")?.objectForKey("screen_name") as NSString,
            UserName: tweetData.objectForKey("user")?.objectForKey("name") as NSString,
            ProfileImage: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as NSString,
            PostDetail: tweetData.objectForKey("created_at") as NSString)
        self.navigationController!.pushViewController(detail_view, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
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
                    self.currentTimeline.insertObject(new_tweet, atIndex: 0)
                    self.sinceId = (new_tweet as NSDictionary).objectForKey("id_str") as String?
                }
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Reply Updated")
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
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    deinit {
        destroy()
    }
    
    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        for timeline in self.currentTimeline {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as NSMutableDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: "replyTimeline")
        userDefaults.setObject(self.sinceId, forKey: "replyTimelineSinceId")
    }
}

