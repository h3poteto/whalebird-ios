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
    
    var tweetNumLabel: UILabel!
    var followNumLabel: UILabel!
    var followerNumLabel: UILabel!
    
    var tableView: UITableView!
    var scrollView: UIScrollView!
    
    var newTimeline: NSArray = NSArray()
    var currentTimeline: NSMutableArray = NSMutableArray()
    
    var timelineCell: NSMutableArray = NSMutableArray()
    var refreshTimeline: UIRefreshControl!
    
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
                    // profile
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
                        
                        self.tweetNumLabel = UILabel(frame: CGRectMake(0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.tweetNumLabel.attributedText = tweetNumAttributedString
                        self.tweetNumLabel.textAlignment = NSTextAlignment.Center
                        self.tweetNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.tweetNumLabel.layer.borderWidth = 0.5
                        self.scrollView.addSubview(self.tweetNumLabel)
                        
                        
                        var followText = ("フォロー：" + String(user_data.objectForKey("friends_count") as Int)) as NSString
                        var followAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followText, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var followRange: NSRange = followText.rangeOfString("フォロー：")
                        followAttributedString.setFont(UIFont.systemFontOfSize(10), range: followRange)
                        
                        self.followNumLabel = UILabel(frame: CGRectMake(self.windowSize.size.width / 3.0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.followNumLabel.attributedText = followAttributedString
                        self.followNumLabel.textAlignment = NSTextAlignment.Center
                        self.followNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.followNumLabel.layer.borderWidth = 0.5
                        self.scrollView.addSubview(self.followNumLabel)
                        
                        
                        var followerText = ("フォロワー：" + String(user_data.objectForKey("followers_count") as Int)) as NSString
                        var followerAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followerText, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var followerRange: NSRange = followerText.rangeOfString("フォロワー：")
                        followerAttributedString.setFont(UIFont.systemFontOfSize(10), range: followerRange)
                    
                        self.followerNumLabel = UILabel(frame: CGRectMake(self.windowSize.size.width * 2.0 / 3.0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.followerNumLabel.attributedText = followerAttributedString
                        self.followerNumLabel.textAlignment = NSTextAlignment.Center
                        self.followerNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.followerNumLabel.layer.borderWidth = 0.5
                        self.scrollView.addSubview(self.followerNumLabel)

                    })
                })
            })
            //-----------------------------
            //  body
            //-----------------------------
            // ここでtableのupdate
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
        return self.currentTimeline.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.timelineCell.insertObject(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        cell!.configureCell(self.currentTimeline.objectAtIndex(indexPath.row) as NSDictionary)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if (self.timelineCell.count > 0 && indexPath.row < self.timelineCell.count) {
            var cell: TimelineViewCell  = self.timelineCell.objectAtIndex(indexPath.row) as TimelineViewCell
            height = cell.cellHeight()
        }
        self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.HeaderImageHeight + self.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
        return height
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweetData = self.currentTimeline.objectAtIndex(indexPath.row) as NSDictionary
        var detail_view = TweetDetailViewController(
            TweetID: tweetData.objectForKey("id_str") as NSString,
            TweetBody: tweetData.objectForKey("text") as NSString,
            ScreenName: tweetData.objectForKey("user")?.objectForKey("screen_name") as NSString,
            UserName: tweetData.objectForKey("user")?.objectForKey("name") as NSString,
            ProfileImage: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as NSString,
            PostDetail: TwitterAPIClient.createdAtToString(tweetData.objectForKey("created_at") as NSString))
        self.navigationController!.pushViewController(detail_view, animated: true)
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
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Timeline Updated")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.tableView.reloadData()
            })
        })
        
    }

}
