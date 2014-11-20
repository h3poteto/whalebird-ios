//
//  DirectMessageTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class DirectMessageTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var newMessage: Array<AnyObject> = []
    var currentMessage: Array<AnyObject> = []
    var messageCell: Array<AnyObject> = []
    
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
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("directMessageSinceId") as String?
        self.sinceId = getSinceId
        
        var directMessage = userDefaults.arrayForKey("directMessage") as Array?
        if (directMessage != nil) {
            for message in directMessage! {
                self.currentMessage.insert(message, atIndex: 0)
            }
            var moreID = self.currentMessage.last?.objectForKey("id_str") as String
            var readMoreDictionary = NSMutableDictionary(dictionary: [
                "moreID" : moreID,
                "sinceID" : "sinceID"
                ])
            self.currentMessage.insert(readMoreDictionary, atIndex: self.currentMessage.count)
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
        self.messageCell.insert(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        cell!.configureCell(self.currentMessage[indexPath.row] as NSDictionary)


        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.messageCell.count > 0 && indexPath.row < self.messageCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentMessage[indexPath.row] as NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }

    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.messageCell.count > 0 && indexPath.row < self.messageCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentMessage[indexPath.row] as NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let messageData = self.currentMessage[indexPath.row] as NSDictionary
        if (messageData.objectForKey("moreID") != nil && messageData.objectForKey("moreID") as String != "moreID") {
            var sinceID = messageData.objectForKey("sinceID") as? String
            if (sinceID == "sinceID") {
                sinceID = nil
            }
            self.updateMessage(sinceID, more_index: indexPath.row)
        } else {
            println(messageData)
            var detailView = MessageDetailViewController(
                MessageID: messageData.objectForKey("id_str") as NSString,
                MessageBody: messageData.objectForKey("text") as NSString,
                ScreeName: messageData.objectForKey("user")?.objectForKey("screen_name") as NSString,
                UserName: messageData.objectForKey("user")?.objectForKey("name") as NSString,
                ProfileImage: messageData.objectForKey("user")?.objectForKey("profile_image_url") as NSString,
                PostDetail: messageData.objectForKey("created_at") as NSString)
            self.navigationController!.pushViewController(detailView, animated: true)
            
        }
    }
    
    func updateMessage(since_id: String?, more_index: Int?) {
        var params: Dictionary<String, String> = [
            "count" : "20"
        ]
        if (since_id != nil) {
            params["since_id"] = since_id as String!
        }
        if (more_index != nil) {
            var strMoreID = (self.currentMessage[more_index!] as NSDictionary).objectForKey("moreID") as String
            // max_idは「以下」という判定になるので自身を含めない
            var intMoreID = strMoreID.toInt()! - 1
            params["max_id"] = String(intMoreID)
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/direct_messages.json", params: parameter) { (new_message) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newMessage = new_message
                if (self.newMessage.count > 0) {
                    if (more_index == nil) {
                        // refreshによる更新
                        if (self.newMessage.count >= 20) {
                            var moreID = self.newMessage.first?.objectForKey("id_str") as String
                            var readMoreDictionary = NSMutableDictionary()
                            if (self.currentMessage.count > 0) {
                                var sinceID = self.currentMessage.first?.objectForKey("id_str") as String
                                readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : sinceID
                                    ])
                            } else {
                                readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : "sinceID"
                                    ])
                            }
                            self.newMessage.insert(readMoreDictionary, atIndex: 0)
                        }
                        for new_tweet in self.newMessage {
                            self.currentMessage.insert(new_tweet, atIndex: 0)
                            self.sinceId = (new_tweet as NSDictionary).objectForKey("id_str") as String?
                        }
                    } else {
                        // readMoreを押した場合
                        // tableの途中なのかbottomなのかの判定
                        if (more_index == self.currentMessage.count - 1) {
                            // bottom
                            var moreID = self.newMessage.first?.objectForKey("id_str") as String
                            var readMoreDictionary = NSMutableDictionary(dictionary: [
                                "moreID" : moreID,
                                "sinceID" : "sinceID"
                                ])
                            self.newMessage.insert(readMoreDictionary, atIndex: 0)
                            self.currentMessage.removeLast()
                            self.currentMessage += self.newMessage.reverse()
                        } else {
                            // 途中
                            if (self.newMessage.count >= 20) {
                                var moreID = self.newMessage.first?.objectForKey("id_str") as String
                                var sinceID = (self.currentMessage[more_index! + 1] as NSDictionary).objectForKey("id_str") as String
                                var readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : sinceID
                                    ])
                                self.newMessage.insert(readMoreDictionary, atIndex: 0)
                            }
                            self.currentMessage.removeAtIndex(more_index!)
                            for new_tweet in self.newMessage {
                                self.currentMessage.insert(new_tweet, atIndex: more_index!)
                            }
                            
                        }
                    }
                    
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(new_message.count) + "件更新")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                    self.tableView.reloadData()
                } else {
                    
                }
                SVProgressHUD.dismiss()
            })
        }
    }

    
    func onRefresh() {
        self.refreshMessage.beginRefreshing()
        updateMessage(self.sinceId, more_index: nil)
        self.refreshMessage.endRefreshing()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.destroy()
    }
    
    func destroy() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanMessageArray: Array<NSMutableDictionary> = []
        let messageMin = min(self.currentMessage.count, 20)
        if (messageMin <= 0) {
            return
        }
        for message in self.currentMessage[0...(messageMin - 2)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(message as NSMutableDictionary)
            cleanMessageArray.append(dic)
        }
        userDefaults.setObject(cleanMessageArray.reverse(), forKey: "directMessage")
        userDefaults.setObject(self.sinceId, forKey: "directMessageSinceId")
    }
}
