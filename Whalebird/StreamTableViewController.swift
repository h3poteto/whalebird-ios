//
//  StreamTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import ODRefreshControl
import SVProgressHUD
import NoticeView

class StreamTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var streamElement: StreamList.Stream!

    var parentNavigation: UINavigationController!
    var refreshTimeline: ODRefreshControl!
    var newTweetButton: UIBarButtonItem!
    var fCellSelect: Bool = false
    var timelineModel: TimelineModel!
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    
    convenience init(aStreamElement: StreamList.Stream, aParentNavigation: UINavigationController) {
        self.init()
        self.streamElement = aStreamElement
        self.parentNavigation = aParentNavigation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    
        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.refreshTimeline = ODRefreshControl(in: self.tableView)
        self.refreshTimeline.addTarget(self, action: #selector(StreamTableViewController.onRefresh(_:)), for: .valueChanged)
        self.edgesForExtendedLayout = UIRectEdge()
        
        
        let userDefaults = UserDefaults.standard
        let sinceId = userDefaults.string(forKey: self.streamElement.name + "SinceId") as String?
        let streamTimeline = userDefaults.array(forKey: self.streamElement.name) as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: streamTimeline as Array<AnyObject>?)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        destroy()
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

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cTweetData = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            if TimelineModel.selectMoreIdCell(cTweetData as NSDictionary) {
                self.fCellSelect = false
            } else {
                self.fCellSelect = true
            }
        }
        return indexPath
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
                self.parentNavigation.pushViewController(detailView, animated: true)
            }
            
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    func getCurrentOffset() ->CGPoint {
        return self.tableView.contentOffset
    }
    
    func setCurrentOffset(_ offset: CGPoint) {
        self.tableView.setContentOffset(offset, animated: false)
    }
    
    
    
    func updateTimeline(_ aSinceID: String?, aMoreIndex: Int?) {

        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        self.timelineModel.updateTimeline("users/apis/list_timeline.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: self.streamElement,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                let userDefault = UserDefaults.standard
                if (currentRowIndex != nil && userDefault.integer(forKey: "afterUpdatePosition") == 2) {
                    let indexPath = IndexPath(row: currentRowIndex!, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                }
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.parentNavigation.view, title: String(format: NSLocalizedString("NewTweets", comment: ""), count))
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
                
            }, noUpdated: { () -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.parentNavigation.view, title: NSLocalizedString("NoNewTweets", comment: ""))
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
    
    
    func destroy() {
        self.timelineModel.saveCurrentTimeline(self.streamElement.name, sinceIdKey: self.streamElement.name + "SinceId")
    }
}
