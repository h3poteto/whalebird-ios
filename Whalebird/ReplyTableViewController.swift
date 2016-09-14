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

class ReplyTableViewController: UITableViewController {
    
    //=============================================
    //  instance variables
    //=============================================
    var refreshTimeline: ODRefreshControl!
    var newTweetButton: UIBarButtonItem!
    var timelineModel: TimelineModel!
    
    //=============================================
    //  instance methods
    //=============================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override init(style: UITableViewStyle) {
        super.init(style: style)        
        self.title = "リプライ"
        self.tabBarItem.image = UIImage(named: "Speaking-Line")
        let userDefaults = UserDefaults.standard
        let sinceId = userDefaults.string(forKey: "replyTimelineSinceId") as String?
        let replyTimeline = userDefaults.array(forKey: "replyTimeline") as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: replyTimeline as Array<AnyObject>?)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.refreshTimeline = ODRefreshControl(in: self.tableView)
        self.refreshTimeline.addTarget(self, action: #selector(ReplyTableViewController.onRefresh(_:)), for: UIControlEvents.valueChanged)
        self.edgesForExtendedLayout = UIRectEdge()

        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ReplyTableViewController.tappedNewTweet(_:)))
        self.navigationItem.rightBarButtonItem = self.newTweetButton
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
            cell = TimelineViewCell(style: .default, reuseIdentifier: "TimelineViewCell")
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
        SVProgressHUD.show(withStatus: "キャンセル", maskType: SVProgressHUDMaskType.clear)
        self.timelineModel.updateTimeline("users/apis/mentions.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: nil,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                let userDefault = UserDefaults.standard
                if (currentRowIndex != nil && userDefault.integer(forKey: "afterUpdatePosition") == 2) {
                    let indexPath = IndexPath(row: currentRowIndex!, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                }
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: String(count) + "件更新")
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
                
            }, noUpdated: { () -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: "新着なし")
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
            }, failed: { () -> Void in
                
        })
    }
    
    func onRefresh(_ sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    func tappedNewTweet(_ sender: AnyObject) {
        let newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }
    
    func destroy() {
        self.timelineModel.saveCurrentTimeline("replyTimeline", sinceIdKey: "replyTimelineSinceId")
    }
    
    func clearData() {
        self.timelineModel.clearData()
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "replyTimelineSinceID")
        userDefaults.set(nil, forKey: "replyTimeline")
        self.tableView.reloadData()
    }
}

