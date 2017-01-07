
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
    var searchItemButton: UIBarButtonItem!
    
    var timelineModel: TimelineModel!
    
    //=========================================
    //  instance methods
    //=========================================
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.plain)
        self.view.backgroundColor = UIColor.white
        self.title = NSLocalizedString("Title", tableName: "Timeline", comment: "")
        self.tabBarItem.image = UIImage(named: "Home")
        let userDefaults = UserDefaults.standard
        let sinceId = userDefaults.string(forKey: "homeTimelineSinceId") as String?
        let homeTimeline = userDefaults.array(forKey: "homeTimeline") as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: homeTimeline as Array<AnyObject>?)
        self.timelineModel.delegate = self
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshTimeline = ODRefreshControl(in: self.tableView)
        self.refreshTimeline.addTarget(self, action: #selector(TimelineTableViewController.onRefresh), for: UIControlEvents.valueChanged)
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(TimelineTableViewController.tappedNewTweet))
        self.navigationItem.rightBarButtonItem = self.newTweetButton

        self.searchItemButton = UIBarButtonItem(image: UIImage(named: "Search-Line"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(TimelineTableViewController.displaySearch))
        self.navigationItem.leftBarButtonItem = self.searchItemButton

        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        // userstream発火のために必要
        NotificationCenter.default.addObserver(self, selector: #selector(TimelineTableViewController.appDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimelineTableViewController.appWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Home用のUserstream
        self.timelineModel.prepareUserstream()
    }
    
    func prepareUserstream() {
        self.timelineModel.prepareUserstream()
    }
    
    func appDidBecomeActive(_ notification: Notification) {
        self.timelineModel.prepareUserstream()
    }
    
    func appWillResignActive(_ notification: Notification) {
        self.timelineModel.stopUserstream()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.timelineModel.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCell(withIdentifier: "TimelineViewCell", for: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "TimelineViewCell")
        }

        cell!.cleanCell()
        if let targetTimeline = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            cell!.configureCell(targetTimeline as NSDictionary)
        }

        return cell!
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline as NSDictionary)
        }
        return height
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline as NSDictionary)
        }
        return height
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cTweetData = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            if TimelineModel.selectMoreIdCell(cTweetData as NSDictionary) {
                var sinceID = cTweetData["sinceID"] as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateTimeline(sinceID, aMoreIndex: (indexPath as NSIndexPath).row)
            } else {
                let tweetModel = TweetModel(dict: cTweetData)
                let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: (indexPath as NSIndexPath).row)
                self.navigationController?.pushViewController(detailView, animated: true)
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }


    
    func updateTimeline(_ aSinceID: String?, aMoreIndex: Int?) {
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        self.timelineModel.updateTimeline("users/apis/home_timeline.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: nil,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                let userDefault = UserDefaults.standard
                if (currentRowIndex != nil && userDefault.integer(forKey: "afterUpdatePosition") == 2) {
                let indexPath = IndexPath(row: currentRowIndex!, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                }
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: String(format: NSLocalizedString("NewTweets", comment: ""), count))
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
            
            }, noUpdated: { () -> Void in
                // アップデートがなくても未読の変更が発生しているのでテーブル更新は必須
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("NoNewTweets", comment: ""))
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
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
    
    func updateTimelineFromUserstream(_ timelineModel: TimelineModel) {
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }

    func destroy() {
        self.timelineModel.saveCurrentTimeline("homeTimeline", sinceIdKey: "homeTimelineSinceID")
    }
    // これログアウトで使う
    func clearData() {
        self.timelineModel.clearData()
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "homeTimelineSinceID")
        userDefaults.set(nil, forKey: "homeTimeline")
        self.tableView.reloadData()
    }

    func displaySearch() {
        let searchView = SearchTableViewController()
        self.navigationController?.pushViewController(searchView, animated: true)
    }
}
