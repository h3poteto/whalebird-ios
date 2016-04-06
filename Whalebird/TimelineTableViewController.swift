
//
//  TimelineTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import ODRefreshControl
import SVProgressHUD
import NoticeView

class TimelineTableViewController: UITableViewController, TimelineModelDelegate {

    //=============================================
    //  instance variables
    //=============================================
    
    var refreshTimeline: ODRefreshControl!
    
    var newTweetButton: UIBarButtonItem!
    
    var timelineModel: TimelineModel!
    
    //=========================================
    //  instance methods
    //=========================================
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "タイムライン"
        self.tabBarItem.image = UIImage(named: "Home")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sinceId = userDefaults.stringForKey("homeTimelineSinceId") as String?
        let homeTimeline = userDefaults.arrayForKey("homeTimeline") as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: homeTimeline)
        self.timelineModel.delegate = self
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshTimeline = ODRefreshControl(inScrollView: self.tableView)
        self.refreshTimeline.addTarget(self, action: #selector(TimelineTableViewController.onRefresh), forControlEvents: UIControlEvents.ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(TimelineTableViewController.tappedNewTweet))
        self.navigationItem.rightBarButtonItem = self.newTweetButton

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        // userstream発火のために必要
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineTableViewController.appDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineTableViewController.appWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Home用のUserstream
        self.timelineModel.prepareUserstream()
    }
    
    func prepareUserstream() {
        self.timelineModel.prepareUserstream()
    }
    
    func appDidBecomeActive(notification: NSNotification) {
        self.timelineModel.prepareUserstream()
    }
    
    func appWillResignActive(notification: NSNotification) {
        self.timelineModel.stopUserstream()
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
        return self.timelineModel.count()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }

        cell!.cleanCell()
        if let targetTimeline = self.timelineModel.getTweetAtIndex(indexPath.row) {
            cell!.configureCell(targetTimeline)
        }

        return cell!
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.timelineModel.getTweetAtIndex(indexPath.row) {
            if TimelineModel.selectMoreIdCell(cTweetData) {
                var sinceID = cTweetData["sinceID"] as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateTimeline(sinceID, aMoreIndex: indexPath.row)
            } else {
                let tweetModel = TweetModel(dict: cTweetData)
                let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: indexPath.row)
                self.navigationController?.pushViewController(detailView, animated: true)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }


    
    func updateTimeline(aSinceID: String?, aMoreIndex: Int?) {
        
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimeline("users/apis/home_timeline.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: nil,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                let userDefault = NSUserDefaults.standardUserDefaults()
                if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                let indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(count) + "件更新")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            
            }, noUpdated: { () -> Void in
                // アップデートがなくても未読の変更が発生しているのでテーブル更新は必須
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "新着なし")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            }, failed: { () -> Void in
            
        })
        
    }
    
    func onRefresh() {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    func tappedNewTweet() {
        let newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    func updateTimelineFromUserstream(timelineModel: TimelineModel) {
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }

    func destroy() {
        self.timelineModel.saveCurrentTimeline("homeTimeline", sinceIdKey: "homeTimelineSinceID")
    }
    // これログアウトで使う
    func clearData() {
        self.timelineModel.clearData()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "homeTimelineSinceID")
        userDefaults.setObject(nil, forKey: "homeTimeline")
        self.tableView.reloadData()
    }
}
