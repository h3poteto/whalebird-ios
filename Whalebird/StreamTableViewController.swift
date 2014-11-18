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
    var currentTimeline: Array<AnyObject> = []
    var newTimeline: Array<AnyObject> = []
    var timelineCell: Array<AnyObject> = []
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
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
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
                self.currentTimeline.insert(tweet, atIndex: 0)
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
        var params: Dictionary<String, String>!
        switch self.streamElement.type {
        case "list":
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
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/list_timeline.json", params: parameter) { (new_timeline) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                for new_tweet in self.newTimeline {
                    self.currentTimeline.insert(new_tweet, atIndex: 0)
                    self.sinceId = (new_tweet as NSDictionary).objectForKey("id_str") as String?
                }
                
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: self.title! + String(self.newTimeline.count) + "件更新")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }
        
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
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    
    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        let timelineMin = min(self.currentTimeline.count, 20)
        for timeline in self.currentTimeline[0...(timelineMin - 1)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as NSMutableDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: self.streamElement.name)
        userDefaults.setObject(self.sinceId, forKey: self.streamElement.name + "SinceId")
    }
}
