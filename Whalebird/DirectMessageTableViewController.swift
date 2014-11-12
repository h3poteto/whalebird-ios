//
//  DirectMessageTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class DirectMessageTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var newMessage = NSArray()
    var currentMessage = NSMutableArray()
    var messageCell = NSMutableArray()
    
    var refreshMessage: UIRefreshControl!
    var newMessageButton: UIBarButtonItem!
    
    var sinceId: String?
    
    //============================================
    //  instance method
    //============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "DM"
        self.tabBarItem.image = UIImage(named: "Mail.png")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshMessage = UIRefreshControl()
        self.refreshMessage.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshMessage)
        
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.newMessageButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewMessage")
        self.navigationItem.rightBarButtonItem = self.newMessageButton
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("directMessageSinceId") as String?
        self.sinceId = getSinceId
        
        var directMessage = userDefaults.arrayForKey("directMessage") as Array?
        if (directMessage != nil) {
            for message in directMessage! {
                self.currentMessage.insertObject(message, atIndex: 0)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.currentMessage.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: .Default, reuseIdentifier: "TimelineViewCell")
        }
        self.messageCell.insertObject(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        cell!.configureCell(self.currentMessage.objectAtIndex(indexPath.row) as NSDictionary)


        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.messageCell.count > 0 && indexPath.row < self.messageCell.count) {
            var cell: TimelineViewCell = self.messageCell.objectAtIndex(indexPath.row) as TimelineViewCell
            height = cell.cellHeight()
        } else {
            height = 60.0
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let messageData = self.currentMessage.objectAtIndex(indexPath.row) as NSDictionary
        var detailView = MessageDetailViewController(
            MessageID: messageData.objectForKey("id_str") as NSString,
            MessageBody: messageData.objectForKey("text") as NSString,
            ScreeName: messageData.objectForKey("user")?.objectForKey("screen_name") as NSString,
            UserName: messageData.objectForKey("user")?.objectForKey("name") as NSString,
            ProfileImage: messageData.objectForKey("user")?.objectForKey("profile_image_url") as NSString,
            PostDetail: messageData.objectForKey("created_at") as NSString)
        self.navigationController!.pushViewController(detailView, animated: true)
    }
    
    func updateMessage(since_id: String?) {
        var params: Dictionary<String, String>
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
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/direct_messages.json", params: parameter) { (new_message) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                self.newMessage = new_message
                for message in self.newMessage {
                    self.currentMessage.insertObject(message, atIndex: 0)
                    self.sinceId = (message as NSDictionary).objectForKey("id_str") as String?
                }
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(self.newMessage.count) + "件更新")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }
    }

    
    func onRefresh() {
        self.refreshMessage.beginRefreshing()
        updateMessage(self.sinceId)
        self.refreshMessage.endRefreshing()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func tappedNewMessage() {
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.destroy()
    }
    
    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanMessageArray: Array<NSMutableDictionary> = []
        for message in self.currentMessage {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(message as NSMutableDictionary)
            cleanMessageArray.append(dic)
        }
        userDefaults.setObject(cleanMessageArray.reverse(), forKey: "directMessage")
        userDefaults.setObject(self.sinceId, forKey: "directMessageSinceId")
    }
}
