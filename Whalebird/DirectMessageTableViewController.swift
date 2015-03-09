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
    
    var refreshMessage: ODRefreshControl!
    var newMessageButton: UIBarButtonItem!
    
    var sinceId: String?
    let tweetCount = Int(50)
    
    //============================================
    //  instance method
    //============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "DM"
        self.tabBarItem.image = UIImage(named: "assets/Mail.png")
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
        
        self.refreshMessage = ODRefreshControl(inScrollView: self.tableView)
        self.refreshMessage.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None
        
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
        cell!.cleanCell()
        cell!.configureCell(self.currentMessage[indexPath.row] as NSDictionary)


        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        height = TimelineViewCell.estimateCellHeight(self.currentMessage[indexPath.row] as NSDictionary)
        return height
    }

    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        height = TimelineViewCell.estimateCellHeight(self.currentMessage[indexPath.row] as NSDictionary)
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cMessageData = self.currentMessage[indexPath.row] as NSDictionary
        if (cMessageData.objectForKey("moreID") != nil && cMessageData.objectForKey("moreID") as String != "moreID") {
            var sinceID = cMessageData.objectForKey("sinceID") as? String
            if (sinceID == "sinceID") {
                sinceID = nil
            }
            self.updateMessage(sinceID, aMoreIndex: indexPath.row)
        } else {
            var detailView = MessageDetailViewController(
                aMessageID: cMessageData.objectForKey("id_str") as NSString,
                aMessageBody: cMessageData.objectForKey("text") as NSString,
                aScreeName: cMessageData.objectForKey("user")?.objectForKey("screen_name") as NSString,
                aUserName: cMessageData.objectForKey("user")?.objectForKey("name") as NSString,
                aProfileImage: cMessageData.objectForKey("user")?.objectForKey("profile_image_url") as NSString,
                aPostDetail: cMessageData.objectForKey("created_at") as NSString)
            self.navigationController!.pushViewController(detailView, animated: true)
            
        }
    }
    
    func updateMessage(aSinceID: String?, aMoreIndex: Int?) {
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        if (aSinceID != nil) {
            params["since_id"] = aSinceID as String!
        }
        if (aMoreIndex != nil) {
            var strMoreID = (self.currentMessage[aMoreIndex!] as NSDictionary).objectForKey("moreID") as String
            // max_idは「以下」という判定になるので自身を含めない
            params["max_id"] = BigInteger(string: strMoreID).decrement()
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/direct_messages.json", params: cParameter) { (aNewMessage) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newMessage = aNewMessage
                var currentRowIndex: Int?
                if (self.newMessage.count > 0) {
                    if (aMoreIndex == nil) {
                        // refreshによる更新
                        if (self.newMessage.count >= self.tweetCount) {
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
                        if (self.currentMessage.count > 0) {
                            currentRowIndex = self.newMessage.count
                        }
                        for newTweet in self.newMessage {
                            self.currentMessage.insert(newTweet, atIndex: 0)
                            self.sinceId = (newTweet as NSDictionary).objectForKey("id_str") as String?
                        }
                    } else {
                        // readMoreを押した場合
                        // tableの途中なのかbottomなのかの判定
                        if (aMoreIndex == self.currentMessage.count - 1) {
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
                            if (self.newMessage.count >= self.tweetCount) {
                                var moreID = self.newMessage.first?.objectForKey("id_str") as String
                                var sinceID = (self.currentMessage[aMoreIndex! + 1] as NSDictionary).objectForKey("id_str") as String
                                var readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : sinceID
                                    ])
                                self.newMessage.insert(readMoreDictionary, atIndex: 0)
                            }
                            self.currentMessage.removeAtIndex(aMoreIndex!)
                            for newTweet in self.newMessage {
                                self.currentMessage.insert(newTweet, atIndex: aMoreIndex!)
                            }
                            
                        }
                    }
                    self.tableView.reloadData()
                    var userDefault = NSUserDefaults.standardUserDefaults()
                    if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                        var indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    }
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(aNewMessage.count) + "件更新")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as AppDelegate).alertPosition
                    notice.show()
                } else {
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "新着なし")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as AppDelegate).alertPosition
                    notice.show()
                }
            })
        }
    }

    
    func onRefresh() {
        self.refreshMessage.beginRefreshing()
        updateMessage(self.sinceId, aMoreIndex: nil)
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
        let cMessageMin = min(self.currentMessage.count, self.tweetCount)
        if (cMessageMin <= 0) {
            return
        }
        for message in self.currentMessage[0...(cMessageMin - 2)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(message as NSDictionary)
            cleanMessageArray.append(dic)
        }
        userDefaults.setObject(cleanMessageArray.reverse(), forKey: "directMessage")
        userDefaults.setObject(self.sinceId, forKey: "directMessageSinceId")
    }
}
