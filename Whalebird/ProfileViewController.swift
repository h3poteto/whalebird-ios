//
//  ProfileViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/14.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import QuartzCore


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //===================================
    //  instance variable
    //===================================
    
    let HeaderImageHeight = CGFloat(160)
    let StatusHeight = CGFloat(40)
    
    var twitterScreenName: NSString?
    var windowSize: CGRect!
    var headerHeight: CGFloat!
    
    var profileImage: UIImageView!
    var profileHeaderImage: UIImageView!
    var userNameLabel: UILabel!
    var descriptionLabel: UILabel!
    
    var tweetNumLabel: UIButton!
    var followNumLabel: UIButton!
    var followerNumLabel: UIButton!
    
    var tableView: UITableView!
    var scrollView: UIScrollView!
    
    var newTimeline: NSArray = NSArray()
    var currentTimeline: NSMutableArray = NSMutableArray()
    var followUsers: NSMutableArray = NSMutableArray()
    var followerUsers: NSMutableArray = NSMutableArray()
    
    var timelineCell: NSMutableArray = NSMutableArray()
    var refreshControl: UIRefreshControl!
    
    var tableType: Int = Int(0)
    
    //==========================================
    //  instance method
    //==========================================
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let user_default = NSUserDefaults.standardUserDefaults()
        self.twitterScreenName = user_default.objectForKey("username") as? NSString
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "ユーザー"
        self.tabBarItem.image = UIImage(named: "Profile-Line.png")
        let user_default = NSUserDefaults.standardUserDefaults()
        self.twitterScreenName = user_default.objectForKey("username") as? NSString
    }
    
    override init() {
        super.init()
    }
    
    init(screenName: NSString) {
        super.init()
        self.twitterScreenName = screenName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.view.addSubview(self.scrollView)
        
        self.windowSize = UIScreen.mainScreen().bounds
        self.headerHeight = self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        self.tableView = UITableView(frame: CGRectMake(0, self.HeaderImageHeight + self.StatusHeight, self.windowSize.size.width, 2000))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.scrollEnabled = false
        self.scrollView.addSubview(self.tableView)
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: 1000)
        
        
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        if (self.twitterScreenName != nil) {
            let params:Dictionary<String, String> = [
                "screen_name" : self.twitterScreenName!
            ]
            
            //-------------------------
            //  header
            //-------------------------
            TwitterAPIClient.sharedClient.getUserInfo(NSURL(string: "https://api.twitter.com/1.1/users/profile_banner.json"), params: params, callback: { header_data in
                var q_main = dispatch_get_main_queue()
                var error = NSError?()
                dispatch_async(q_main, {()->Void in
                    if (header_data.objectForKey("sizes")?.objectForKey("mobile_retina")?.objectForKey("url") != nil){
                        var header_image_url = NSURL.URLWithString(header_data.objectForKey("sizes")?.objectForKey("mobile_retina")?.objectForKey("url") as NSString)
                        self.profileHeaderImage = UIImageView(frame: CGRectMake(0, 0, self.windowSize.width, self.HeaderImageHeight))
                        self.profileHeaderImage.image = UIImage(data: NSData(contentsOfURL: header_image_url, options: NSDataReadingOptions.DataReadingMappedAlways, error: &error))
                        self.scrollView.addSubview(self.profileHeaderImage)
                    }
                })
                
                TwitterAPIClient.sharedClient.getUserInfo(NSURL(string: "https://api.twitter.com/1.1/users/show.json"), params: params, callback: { user_data in
                    var q_sub = dispatch_get_main_queue()
                    dispatch_async(q_sub, {()->Void in
                        // TODO: APIが尽きたときの処理も念のため書いておく
                        
                        var profile_image_url = NSURL.URLWithString(user_data.objectForKey("profile_image_url") as String)
                        self.profileImage = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                        self.profileImage.center = CGPoint(x: self.windowSize.width / 2.0, y: 40 + 10)
                        self.profileImage.image = UIImage(data: NSData(contentsOfURL: profile_image_url, options: NSDataReadingOptions.DataReadingMappedAlways, error: &error))
                        self.scrollView.addSubview(self.profileImage)
                    
                        self.userNameLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, 80, self.windowSize.width * 0.8, 15))
                        self.userNameLabel.text = user_data.objectForKey("screen_name") as? String
                        self.userNameLabel.font = UIFont.systemFontOfSize(10)
                        self.userNameLabel.sizeToFit()
                        self.userNameLabel.textAlignment = NSTextAlignment.Center
                        var name_frame:CGRect = self.userNameLabel.frame
                        name_frame.size.width += 10
                        name_frame.size.height += 5
                        self.userNameLabel.frame = name_frame
                        self.userNameLabel.layer.cornerRadius = 5
                        self.userNameLabel.clipsToBounds = true
                        self.userNameLabel.center = CGPointMake(self.windowSize.width / 2.0, 90)
                        self.userNameLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
                        self.scrollView.addSubview(self.userNameLabel)
                    
                        self.descriptionLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, 110, self.windowSize.width * 0.8, 15))
                        self.descriptionLabel.numberOfLines = 3
                        self.descriptionLabel.text = user_data.objectForKey("description") as? String
                        self.descriptionLabel.font = UIFont.systemFontOfSize(9)
                        self.descriptionLabel.sizeToFit()
                        self.descriptionLabel.textAlignment = NSTextAlignment.Center
                        self.descriptionLabel.layer.cornerRadius = 5
                        self.descriptionLabel.clipsToBounds = true
                        self.descriptionLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
                        self.scrollView.addSubview(self.descriptionLabel)
                        
                        //-----------------------------
                        //  status
                        //-----------------------------
                        
                        // TODO: ここOHAttributedLabel使おう
                        
                        var tweetNumText = ("ツイート：" + String(user_data.objectForKey("statuses_count") as Int)) as NSString
                        var tweetNumAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: tweetNumText, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var tweetNumRange: NSRange = tweetNumText.rangeOfString("ツイート：")
                        tweetNumAttributedString.setFont(UIFont.systemFontOfSize(10), range: tweetNumRange)
                        
                        self.tweetNumLabel = UIButton(frame: CGRectMake(0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.tweetNumLabel.setAttributedTitle(tweetNumAttributedString, forState: .Normal)
                        self.tweetNumLabel.titleLabel?.textAlignment = NSTextAlignment.Center
                        self.tweetNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.tweetNumLabel.layer.borderWidth = 0.5
                        self.tweetNumLabel.addTarget(self, action: "tappedTweetNum", forControlEvents: UIControlEvents.TouchDown)
                        self.scrollView.addSubview(self.tweetNumLabel)
                        
                        
                        var followText = ("フォロー：" + String(user_data.objectForKey("friends_count") as Int)) as NSString
                        var followAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followText, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var followRange: NSRange = followText.rangeOfString("フォロー：")
                        followAttributedString.setFont(UIFont.systemFontOfSize(10), range: followRange)
                        
                        self.followNumLabel = UIButton(frame: CGRectMake(self.windowSize.size.width / 3.0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.followNumLabel.setAttributedTitle(followAttributedString, forState: .Normal)
                        self.followNumLabel.titleLabel?.textAlignment = NSTextAlignment.Center
                        self.followNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.followNumLabel.layer.borderWidth = 0.5
                        self.followNumLabel.addTarget(self, action: "tappedFollowNum", forControlEvents: UIControlEvents.TouchDown)
                        self.scrollView.addSubview(self.followNumLabel)
                        
                        
                        var followerText = ("フォロワー：" + String(user_data.objectForKey("followers_count") as Int)) as NSString
                        var followerAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followerText, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var followerRange: NSRange = followerText.rangeOfString("フォロワー：")
                        followerAttributedString.setFont(UIFont.systemFontOfSize(10), range: followerRange)
                    
                        self.followerNumLabel = UIButton(frame: CGRectMake(self.windowSize.size.width * 2.0 / 3.0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.followerNumLabel.setAttributedTitle(followerAttributedString, forState: .Normal)
                        self.followerNumLabel.titleLabel?.textAlignment = NSTextAlignment.Center
                        self.followerNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.followerNumLabel.layer.borderWidth = 0.5
                        self.followerNumLabel.addTarget(self, action: "tappedFollowerNum", forControlEvents: UIControlEvents.TouchDown)
                        self.scrollView.addSubview(self.followerNumLabel)

                    })
                })
            })
            //-----------------------------
            //  body
            //-----------------------------
            // ここでtableのupdate
            // 呼び出し回数が多すぎる
            updateTimeline(0)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        var row = 0
        switch(self.tableType){
        case 0:
            row = self.currentTimeline.count
            break
        case 1:
            row = self.followUsers.count
            break
        default:
            row = self.currentTimeline.count
            break
        }
        return row
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        //var timeline_cell: TimelineViewCell
        switch(self.tableType) {
        case 0:
            var timeline_cell = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
            if (timeline_cell == nil) {
                timeline_cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
            }
            
            self.timelineCell.insertObject(timeline_cell!, atIndex: indexPath.row)
            timeline_cell!.cleanCell()
            timeline_cell!.configureCell(self.currentTimeline.objectAtIndex(indexPath.row) as NSDictionary)
            return timeline_cell!
        case 1:
            var error = NSError?()
            var profileImageURL = NSURL.URLWithString((self.followUsers.objectAtIndex(indexPath.row) as NSDictionary).objectForKey("profile_image_url") as NSString)
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell?.textLabel?.text = (self.followUsers.objectAtIndex(indexPath.row) as NSDictionary).objectForKey("screen_name") as? String
            
            cell?.imageView?.image = UIImage(data: NSData(
                contentsOfURL: profileImageURL,
                options: NSDataReadingOptions.DataReadingMappedAlways,
                error: &error))
            break
        default:
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            break
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        switch(self.tableType) {
        case 0:
            if (self.timelineCell.count > 0 && indexPath.row < self.timelineCell.count) {
                var cell: TimelineViewCell  = self.timelineCell.objectAtIndex(indexPath.row) as TimelineViewCell
                height = cell.cellHeight()
            }
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.HeaderImageHeight + self.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            break
        case 1:
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.HeaderImageHeight + self.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            break
        default:
            break
        }
        return height
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(self.tableType){
        case 0:
            let tweetData = self.currentTimeline.objectAtIndex(indexPath.row) as NSDictionary
            var detail_view = TweetDetailViewController(
                TweetID: tweetData.objectForKey("id_str") as NSString,
                TweetBody: tweetData.objectForKey("text") as NSString,
                ScreenName: tweetData.objectForKey("user")?.objectForKey("screen_name") as NSString,
                UserName: tweetData.objectForKey("user")?.objectForKey("name") as NSString,
                ProfileImage: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as NSString,
                PostDetail: TwitterAPIClient.createdAtToString(tweetData.objectForKey("created_at") as NSString))
            self.navigationController!.pushViewController(detail_view, animated: true)
            break
        case 1:
            break
        default:
            break
        }
    }
    

    func updateTimeline(since_id: Int) {
        var url = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/user_timeline.json")
        var params: Dictionary<String, String> = [
            "contributor_details" : "true",
            "trim_user" : "0",
            "count" : "10",
            "screen_name" : self.twitterScreenName!
        ]
        TwitterAPIClient.sharedClient.getTimeline(url, params: params, callback: {new_timeline in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                for new_tweet in self.newTimeline {
                    self.currentTimeline.insertObject(new_tweet, atIndex: 0)
                }
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Get Timeline")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
            })
        })
        
    }
    
    func updateFollowUser() {
        var url = NSURL.URLWithString("https://api.twitter.com/1.1/followers/list.json")
        var params: Dictionary<String, String> = [
            "screen_name" : self.twitterScreenName!
        ]
        TwitterAPIClient.sharedClient.getUserInfo(url, params: params, callback: {follows in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var user = follows as NSDictionary
                self.followUsers = user.objectForKey("users") as NSMutableArray
                self.tableView.reloadData()
            })
        })
    }
    
    func updateFollowerUser() {
        var url = NSURL.URLWithString("https://api.twitter.com/1.1/friends/list.json")
        var params: Dictionary<String, String> = [
            "screen_name" : self.twitterScreenName!
        ]
        TwitterAPIClient.sharedClient.getUserInfo(url, params: params, callback: {follows in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var user = follows as NSDictionary
                self.followUsers = user.objectForKey("users") as NSMutableArray
                self.tableView.reloadData()
            })
        })
    }
    
    func tappedTweetNum() {
        self.tableType = 0
        self.tableView.reloadData()
        
    }
    
    func tappedFollowNum() {
        self.tableType = 1
        updateFollowUser()
        
    }
    
    func tappedFollowerNum() {
        self.tableType = 1
        updateFollowerUser()
    }
    
    // TODO: 追加読み込み機能の実装．typeで分ける

}
