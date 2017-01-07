//
//  DirectMessageTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import ODRefreshControl
import SVProgressHUD
import NoticeView

class DirectMessageTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var refreshMessage: ODRefreshControl!
    var newMessageButton: UIBarButtonItem!
    var timelineModel: TimelineModel!
    
    //============================================
    //  instance methods
    //============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = NSLocalizedString("Title", tableName: "DirectMessage", comment: "")
        self.tabBarItem.image = UIImage(named: "Mail")
        let userDefaults = UserDefaults.standard
        let sinceId = userDefaults.string(forKey: "directMessageSinceId") as String?
        let directMessage = userDefaults.array(forKey: "directMessage") as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: directMessage as Array<AnyObject>?)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshMessage = ODRefreshControl(in: self.tableView)
        self.refreshMessage.addTarget(self, action: #selector(DirectMessageTableViewController.onRefresh), for: UIControlEvents.valueChanged)
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
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
        if let targetMessage = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            cell!.configureCell(targetMessage as NSDictionary)
        }


        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetMessage = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            height = TimelineViewCell.estimateCellHeight(targetMessage as NSDictionary)
        }
        return height
    }

    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetMessage = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            height = TimelineViewCell.estimateCellHeight(targetMessage as NSDictionary)
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cMessageData = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            if TimelineModel.selectMoreIdCell(cMessageData as NSDictionary) {
                var sinceID = cMessageData["sinceID"] as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateMessage(sinceID, aMoreIndex: (indexPath as NSIndexPath).row)
            } else {
                let messageModel = MessageModel(dict: cMessageData)
                let detailView = MessageDetailViewController(aMessageModel: messageModel)
                self.navigationController?.pushViewController(detailView, animated: true)
                
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func updateMessage(_ aSinceID: String?, aMoreIndex: Int?) {
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        self.timelineModel.updateTimeline("users/apis/direct_messages.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: nil,
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
        self.refreshMessage.beginRefreshing()
        updateMessage(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshMessage.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.destroy()
    }
    
    func destroy() {
        self.timelineModel.saveCurrentTimeline("directMessage", sinceIdKey: "directMessageSinceId")
    }
    
    func clearData() {
        self.timelineModel.clearData()
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "directMessageSinceID")
        userDefaults.set(nil, forKey: "directMessage")
        self.tableView.reloadData()
    }
}
