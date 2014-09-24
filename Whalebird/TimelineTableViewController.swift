
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
    var newTimeline: NSArray = NSArray()
    var currentTimeline: NSMutableArray = NSMutableArray()
    
    var timelineCell: NSMutableArray = NSMutableArray()
    var refreshTimeline: UIRefreshControl!
    
    var newTweetButton: UIBarButtonItem!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshTimeline = UIRefreshControl()
        self.refreshTimeline.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshTimeline)
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")

        updateTimeline(0)
        
        let stream_url = NSURL.URLWithString("https://userstream.twitter.com/1.1/user.json")
        let params: Dictionary<String,String> = [
            "with" : "user"
        ]
        UserstreamAPIClient.sharedClient.startStreaming(stream_url, params: params, callback: {data in
        })
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        
        self.timelineCell.insertObject(cell!, atIndex: indexPath.row)
        
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
            PostDetail: TwitterAPIClient.createdAtToString(tweetData.objectForKey("created_at") as NSString))
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

    
    func updateTimeline(since_id: Int) {
        var url = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/home_timeline.json")
        var params: Dictionary<String, String> = [
            "contributor_details" : "true",
            "trim_user" : "0",
            "count" : "10"
        ]
        TwitterAPIClient.sharedClient.getTimeline(url, params: params, callback: {new_timeline in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                for new_tweet in self.newTimeline {
                    self.currentTimeline.insertObject(new_tweet, atIndex: 0)
                }
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Timeline Updated")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
            })
        })
        
    }
    
    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(0)
        self.refreshTimeline.endRefreshing()
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }

}
