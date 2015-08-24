//
//  ReplyTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import ODRefreshControl
import SVProgressHUD
import NoticeView

class ReplyTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    //=============================================
    //  instance variables
    //=============================================
    var refreshTimeline: ODRefreshControl!
    var newTweetButton: UIBarButtonItem!
    var timelineModel: TimelineModel!
    
    //=============================================
    //  instance methods
    //=============================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リプライ"
        self.tabBarItem.image = UIImage(named: "Speaking-Line")
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var sinceId = userDefaults.stringForKey("replyTimelineSinceId") as String?
        var replyTimeline = userDefaults.arrayForKey("replyTimeline") as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: replyTimeline)
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
            cell = TimelineViewCell(style: .Default, reuseIdentifier: "TimelineViewCell")
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
                var tweetModel = TweetModel(dict: cTweetData)
                var detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: indexPath.row)
                self.navigationController?.pushViewController(detailView, animated: true)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }


    
    func updateTimeline(aSinceID: String?, aMoreIndex: Int?) {
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimeline("users/apis/mentions.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: nil,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                var userDefault = NSUserDefaults.standardUserDefaults()
                if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                    var indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(count) + "件更新")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                
            }, noUpdated: { () -> Void in
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "新着なし")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            }, failed: { () -> Void in
                
        })
    }
    
    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }
    
    func destroy() {
        self.timelineModel.saveCurrentTimeline("replyTimeline", sinceIdKey: "replyTimelineSinceId")
    }
    
    func clearData() {
        self.timelineModel.clearData()
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "replyTimelineSinceID")
        userDefaults.setObject(nil, forKey: "replyTimeline")
        self.tableView.reloadData()
    }
}

