//
//  ConversationTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD

class ConversationTableViewController: UITableViewController {
    
    //=============================================
    //  instance variables
    //=============================================
    var rootTweetID: String!
    var conversationCell: Array<AnyObject> = []
    var timelineModel: TimelineModel!
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = NSLocalizedString("Title", tableName: "Conversation", comment: "")
    }
    
    convenience init(aTweetID: String) {
        self.init()
        self.title = NSLocalizedString("Title", tableName: "Conversation", comment: "")
        self.rootTweetID = aTweetID
        self.timelineModel = TimelineModel(initSinceId: nil, initTimeline: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.updateConversation()
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
        
        self.conversationCell.insert(cell!, at: (indexPath as NSIndexPath).row)
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
        if let cTweetData = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            let tweetModel = TweetModel(dict: cTweetData)
            let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: (indexPath as NSIndexPath).row)
            self.navigationController?.pushViewController(detailView, animated: true)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    func updateConversation() {
        let params: Dictionary<String, AnyObject> = [
            "id" : self.rootTweetID as AnyObject
        ]
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        self.timelineModel.updateTimelineOnlyNew("users/apis/conversations.json", requestParameter: parameter,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }, noUpdated: { () -> Void in
                SVProgressHUD.dismiss()
            }, failed: { () -> Void in
            
        })
    }

}
