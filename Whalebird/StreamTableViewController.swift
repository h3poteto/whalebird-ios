//
//  StreamTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class StreamTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var streamElement: ListTableViewController.Stream!
    var currentTimeline = NSMutableArray()
    var newTimeline = NSArray()
    var timelineCell = NSMutableArray()
    var pageControl: UIPageControl!
    var pageIndex: Int!
    var parentController: ListTableViewController!
    var refreshTimeline: UIRefreshControl!
    var newTweetButton: UIBarButtonItem!
    var sinceId: String?
    
    let pageControlViewHeight = CGFloat(20)
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
    }
    
    init(StreamElement: ListTableViewController.Stream, PageIndex: Int, ParentController: ListTableViewController) {
        super.init()
        self.streamElement = StreamElement
        self.pageIndex = PageIndex
        self.parentController = ParentController
        self.title = self.streamElement.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let windowSize = UIScreen.mainScreen().bounds
        
    
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        
        self.pageControl = UIPageControl(frame: CGRectMake(
            0,
            windowSize.size.height - self.tabBarController!.tabBar.frame.height - self.pageControlViewHeight - self.navigationController!.navigationBar.frame.size.height - UIApplication.sharedApplication().statusBarFrame.size.height,
            windowSize.size.width,
            self.pageControlViewHeight))
        self.pageControl.backgroundColor = UIColor(red: 0.529, green: 0.808, blue: 0.980, alpha: 1.0)
        self.pageControl.numberOfPages = self.parentController.streamList.count
        self.pageControl.currentPage = self.pageIndex
        self.tableView.addSubview(self.pageControl)
        
        var leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "hundleLeftSwipe:")
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipeRecognizer)
        
        var rightSwipteRecognizer = UISwipeGestureRecognizer(target: self, action: "hundleRightSwipe:")
        rightSwipteRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipteRecognizer)
        
        
        self.refreshTimeline = UIRefreshControl()
        self.refreshTimeline.addTarget(self, action: "onRefresh:", forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshTimeline)
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        self.sinceId = userDefaults.stringForKey(self.streamElement.name + "SinceId") as String?
        
        var streamTimeline = userDefaults.arrayForKey(self.streamElement.name) as Array?
        if (streamTimeline != nil) {
            for tweet in streamTimeline! {
                self.currentTimeline.insertObject(tweet, atIndex: 0)
            }
        }
    }

    
    override func viewWillDisappear(animated: Bool) {
        // delegateを消してやらないとオブジェクト消失に時にスクロールイベントが呼ばれて落ちる
        // だけどpush遷移のときにこれ呼ばれるの困る
        if(self.navigationController != nil) {
            if(!(self.navigationController!.viewControllers as NSArray).containsObject(self)) {
                self.tableView.delegate = nil
            }
        }
        
        destroy()
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

    
    //---------------------------------------------------
    // スクロールイベント時にpageControlのViewの位置を調節
    // してやらないと下部に固定されない
    //---------------------------------------------------
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let windowSize = UIScreen.mainScreen().bounds
        let scrollOffset = scrollView.contentOffset.y as CGFloat
        
        if (self.tabBarController != nil) {
            self.pageControl.frame = CGRectMake(
                0,
                scrollOffset + windowSize.size.height - self.tabBarController!.tabBar.frame.height - self.pageControlViewHeight,
                windowSize.size.width,
                self.pageControlViewHeight)
            self.navigationController?.view.bringSubviewToFront(self.pageControl)
        }
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

    
    
    func updateTimeline(since_id: String?) {
        var url: NSURL!
        var params: Dictionary<String, String>!
        switch self.streamElement.type {
        case "statuses":
            url = NSURL.URLWithString("https://api.twitter.com/1.1" + self.streamElement.uri + ".json")
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
            break
        case "list":
            url = NSURL.URLWithString("https://api.twitter.com/1.1/lists/statuses.json")
            if (since_id != nil) {
                params = [
                    "list_id" : self.streamElement.id as String!,
                    "count" : "20",
                    "since_id" : since_id as String!
                ]
            } else {
                params = [
                    "list_id" : self.streamElement.id as String!,
                    "count" : "20"
                ]
            }
            break
        default:
            break
        }
        
        TwitterAPIClient.sharedClient.getTimeline(url, params: params, callback: {new_timeline in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                for new_tweet in self.newTimeline {
                    self.currentTimeline.insertObject(new_tweet, atIndex: 0)
                    self.sinceId = (new_tweet as NSDictionary).objectForKey("id_str") as String?
                }
                
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: self.title! + "Updated")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
            })
        })
        
    }

    func hundleLeftSwipe(sender: AnyObject) {
        if (self.pageControl.currentPage + 1 < self.pageControl.numberOfPages) {
            self.pageControl.currentPage += 1
            var rightView = StreamTableViewController(StreamElement: self.parentController.streamList[self.pageControl.currentPage], PageIndex: self.pageControl.currentPage, ParentController: self.parentController)
            self.navigationController!.pushViewController(rightView, animated: true)
        }
    }
    
    func hundleRightSwipe(sender: AnyObject) {
        if (self.pageControl.currentPage > 0) {
            
            // pushの逆向きアニメーション生成
            var transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            
            self.pageControl.currentPage -= 1
            var rightView = StreamTableViewController(StreamElement: self.parentController.streamList[self.pageControl.currentPage], PageIndex: self.pageControl.currentPage, ParentController: self.parentController)
            self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
            self.navigationController!.pushViewController(rightView, animated: false)
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
    
    
    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        for timeline in self.currentTimeline {
            var dic = TwitterAPIClient.sharedClient.cleanDictionary(timeline as NSMutableDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: self.streamElement.name)
        userDefaults.setObject(self.sinceId, forKey: self.streamElement.name + "SinceId")
    }
}
