//
//  ConversationTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController {
    
    //=============================================
    //  instance variables
    //=============================================
    var rootTweetID: String!
    var newConversation: Array<AnyObject> = []
    var conversationCell: Array<AnyObject> = []
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "会話"
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init(aTweetID: String) {
        self.init()
        self.rootTweetID = aTweetID
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.updateConversation()
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
        return self.newConversation.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.conversationCell.insert(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        if (self.newConversation[indexPath.row] as? NSDictionary != nil) {
            cell!.configureCell(self.newConversation[indexPath.row] as! NSDictionary)
        }

        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.conversationCell.count > 0 && indexPath.row < self.conversationCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.newConversation[indexPath.row] as! NSDictionary)
        } else {
            height = 60.0
        }
        
        return height
    }



    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.conversationCell.count > 0 && indexPath.row < self.conversationCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.newConversation[indexPath.row] as! NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.newConversation[indexPath.row] as? NSDictionary {
            var detailView = TweetDetailViewController(
                aTweetID: cTweetData.objectForKey("id_str") as! String,
                aTweetBody: cTweetData.objectForKey("text") as! String,
                aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as! String,
                aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as! String,
                aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as! String,
                aPostDetail: cTweetData.objectForKey("created_at") as! String,
                aRetweetedName: nil,
                aRetweetedProfileImage: nil,
                aFavorited: cTweetData.objectForKey("favorited?") as? Bool,
                aMedia: cTweetData.objectForKey("media") as? NSArray,
                aParentArray: &self.newConversation,
                aParentIndex: indexPath.row,
                aProtected: cTweetData.objectForKey("user")?.objectForKey("protected?") as? Bool
            )
            self.navigationController?.pushViewController(detailView, animated: true)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    func updateConversation() {
        var params: Dictionary<String, AnyObject> = [
            "id" : self.rootTweetID
        ]
        var parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/conversations.json", params: parameter) { (aNewConversation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                for timeline in aNewConversation {
                    if var mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                        self.newConversation.insert(mutableTimeline, atIndex: 0)                        
                    }
                }
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }
    }

}
