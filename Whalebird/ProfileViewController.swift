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
    
    var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    var followUsers: Array<AnyObject> = []
    var followUsersNextCursor: String?
    var followerUsers: Array<AnyObject> = []
    var followerUsersNextCursor: String?
    var selectedButtonColor = UIColor.whiteColor()
    var unselectedButtonColor = UIColor(red: 0.945, green: 0.946, blue: 0.947, alpha: 1.0)
    var selectedTextColor = UIColor(red: 0.176, green: 0.584, blue: 0.957, alpha: 1.0)
    var unselectedTextColor = UIColor.grayColor()
    
    var timelineCell: Array<AnyObject> = []
    var refreshControl: UIRefreshControl!
    
    var tableType: Int = Int(0)
    
    //==========================================
    //  instance method
    //==========================================
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let user_default = NSUserDefaults.standardUserDefaults()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let user_default = NSUserDefaults.standardUserDefaults()
    }
    
    override init() {
        super.init()
    }
    
    init(screenName: NSString) {
        super.init()
        self.twitterScreenName = screenName
        self.title = "@" + screenName
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
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: 1000)

        self.scrollView.addPullToRefreshWithActionHandler({ () -> Void in
            self.userTableRefresh()
        }, position: SVPullToRefreshPosition.Bottom)

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        if (self.twitterScreenName != nil) {
            let params:Dictionary<String, String> = [
                "screen_name" : self.twitterScreenName!
            ]
            let parameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            SVProgressHUD.show()
            //-------------------------
            //  header
            //-------------------------
            WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/profile_banner.json", params: parameter, callback: { (header_data) -> Void in
                var q_main = dispatch_get_main_queue()
                var error = NSError?()
                dispatch_async(q_main, {()->Void in
                    if (header_data.objectForKey("sizes")?.objectForKey("mobile_retina")?.objectForKey("url") != nil){
                        var header_image_url = NSURL(string: header_data.objectForKey("sizes")?.objectForKey("mobile_retina")?.objectForKey("url") as NSString)
                        self.profileHeaderImage = UIImageView(frame: CGRectMake(0, 0, self.windowSize.width, self.HeaderImageHeight))
                        self.profileHeaderImage.image = UIImage(data: NSData(contentsOfURL: header_image_url!, options: NSDataReadingOptions.DataReadingMappedAlways, error: &error)!)
                        self.scrollView.addSubview(self.profileHeaderImage)
                    }
                })
                WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/user.json", params: parameter, callback: { (user_data) -> Void in
                    var q_sub = dispatch_get_main_queue()
                    dispatch_async(q_sub, {()->Void in
                        
                        var profile_image_url = NSURL(string: user_data.objectForKey("profile_image_url") as String)
                        self.profileImage = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                        self.profileImage.center = CGPoint(x: self.windowSize.width / 2.0, y: 40 + 10)
                        self.profileImage.image = UIImage(data: NSData(contentsOfURL: profile_image_url!, options: NSDataReadingOptions.DataReadingMappedAlways, error: &error)!)
                        self.scrollView.addSubview(self.profileImage)
                    
                        self.userNameLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, 80, self.windowSize.width * 0.8, 15))
                        self.userNameLabel.text = user_data.objectForKey("name") as String!
                        self.userNameLabel.font = UIFont.boldSystemFontOfSize(14)
                        self.userNameLabel.textColor = UIColor.blackColor()
                        self.userNameLabel.sizeToFit()
                        self.userNameLabel.textAlignment = NSTextAlignment.Center
                        var nameFrame:CGRect = self.userNameLabel.frame
                        nameFrame.size.width += 10
                        nameFrame.size.height += 5
                        self.userNameLabel.frame = nameFrame
                        self.userNameLabel.layer.cornerRadius = 5
                        self.userNameLabel.clipsToBounds = true
                        self.userNameLabel.center = CGPointMake(self.windowSize.width / 2.0, 90)
                        self.userNameLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
                        self.scrollView.addSubview(self.userNameLabel)
                    
                        self.descriptionLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, 110, self.windowSize.width * 0.8, 15))
                        self.descriptionLabel.numberOfLines = 3
                        self.descriptionLabel.text = user_data.objectForKey("description") as? String
                        self.descriptionLabel.font = UIFont.systemFontOfSize(11)
                        self.descriptionLabel.sizeToFit()
                        self.descriptionLabel.textAlignment = NSTextAlignment.Center
                        var descriptionFrame: CGRect = self.descriptionLabel.frame
                        descriptionFrame.size.width += 10
                        descriptionFrame.size.height += 5
                        self.descriptionLabel.frame = descriptionFrame
                        self.descriptionLabel.layer.cornerRadius = 5
                        self.descriptionLabel.clipsToBounds = true
                        self.descriptionLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
                        self.scrollView.addSubview(self.descriptionLabel)
                        
                        //-----------------------------
                        //  status
                        //-----------------------------
                        
                        var tweetNumText = ("ツイート：" + String(user_data.objectForKey("statuses_count") as Int)) as NSString
                        var tweetNumAttributedString = NSMutableAttributedString(string: tweetNumText, attributes: [NSForegroundColorAttributeName: self.selectedTextColor,  NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var tweetNumRange: NSRange = tweetNumText.rangeOfString("ツイート：")
                        tweetNumAttributedString.setFont(UIFont.systemFontOfSize(10), range: tweetNumRange)
                        
                        self.tweetNumLabel = UIButton(frame: CGRectMake(0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        
                        self.tweetNumLabel.setAttributedTitle(tweetNumAttributedString, forState: UIControlState.Normal)
                        self.tweetNumLabel.titleLabel?.textAlignment = NSTextAlignment.Center
                        self.tweetNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.tweetNumLabel.layer.borderWidth = 0.5
                        self.tweetNumLabel.backgroundColor = self.selectedButtonColor
                        self.tweetNumLabel.addTarget(self, action: "tappedTweetNum", forControlEvents: UIControlEvents.TouchDown)
                        self.scrollView.addSubview(self.tweetNumLabel)
                        
                        
                        var followText = ("フォロー：" + String(user_data.objectForKey("friends_count") as Int)) as NSString
                        var followAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followText, attributes: [NSForegroundColorAttributeName: self.unselectedTextColor, NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var followRange: NSRange = followText.rangeOfString("フォロー：")
                        followAttributedString.setFont(UIFont.systemFontOfSize(10), range: followRange)
                        
                        self.followNumLabel = UIButton(frame: CGRectMake(self.windowSize.size.width / 3.0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.followNumLabel.setAttributedTitle(followAttributedString, forState: .Normal)
                        self.followNumLabel.titleLabel?.textAlignment = NSTextAlignment.Center
                        self.followNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.followNumLabel.layer.borderWidth = 0.5
                        self.followNumLabel.backgroundColor = self.unselectedButtonColor
                        self.followNumLabel.addTarget(self, action: "tappedFollowNum", forControlEvents: UIControlEvents.TouchDown)
                        self.scrollView.addSubview(self.followNumLabel)
                        self.followNumLabel.titleLabel?.textColor = self.unselectedTextColor
                        
                        var followerText = ("フォロワー：" + String(user_data.objectForKey("followers_count") as Int)) as NSString
                        var followerAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followerText, attributes: [NSForegroundColorAttributeName: self.unselectedTextColor, NSFontAttributeName: UIFont.systemFontOfSize(14)])
                        var followerRange: NSRange = followerText.rangeOfString("フォロワー：")
                        followerAttributedString.setFont(UIFont.systemFontOfSize(10), range: followerRange)
                    
                        self.followerNumLabel = UIButton(frame: CGRectMake(self.windowSize.size.width * 2.0 / 3.0, self.HeaderImageHeight, self.windowSize.size.width / 3.0, self.StatusHeight))
                        self.followerNumLabel.setAttributedTitle(followerAttributedString, forState: .Normal)
                        self.followerNumLabel.titleLabel?.textAlignment = NSTextAlignment.Center
                        self.followerNumLabel.layer.borderColor = UIColor.grayColor().CGColor
                        self.followerNumLabel.layer.borderWidth = 0.5
                        self.followerNumLabel.backgroundColor = self.unselectedButtonColor
                        self.followerNumLabel.addTarget(self, action: "tappedFollowerNum", forControlEvents: UIControlEvents.TouchDown)
                        self.scrollView.addSubview(self.followerNumLabel)
                        SVProgressHUD.dismiss()

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
        case 2:
            row = self.followerUsers.count
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
            
            self.timelineCell.insert(timeline_cell!, atIndex: indexPath.row)
            timeline_cell!.cleanCell()
            timeline_cell!.configureCell(self.currentTimeline[indexPath.row] as NSDictionary)
            return timeline_cell!
        case 1:
            var error = NSError?()
            var profileImageURL = NSURL(string: (self.followUsers[indexPath.row] as NSDictionary).objectForKey("profile_image_url") as NSString)
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell?.textLabel.text = (self.followUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as? String
            
            cell?.imageView.image = UIImage(data: NSData(
                contentsOfURL: profileImageURL!,
                options: NSDataReadingOptions.DataReadingMappedAlways,
                error: &error)!)
            break
        case 2:
            var error = NSError?()
            var profileImageURL = NSURL(string: (self.followerUsers[indexPath.row] as NSDictionary).objectForKey("profile_image_url") as NSString)
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell?.textLabel.text = (self.followerUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as? String
            
            cell?.imageView.image = UIImage(data: NSData(
                contentsOfURL: profileImageURL!,
                options: NSDataReadingOptions.DataReadingMappedAlways,
                error: &error)!)
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
                height = TimelineViewCell.estimateCellHeight(self.currentTimeline[indexPath.row] as NSDictionary)
            }
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.HeaderImageHeight + self.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            break
        case 1:
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.HeaderImageHeight + self.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            break
        case 2:
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
            let tweetData = self.currentTimeline[indexPath.row] as NSDictionary
            var detailView = TweetDetailViewController(
                tweet_id: tweetData.objectForKey("id_str") as String,
                tweet_body: tweetData.objectForKey("text") as String,
                screen_name: tweetData.objectForKey("user")?.objectForKey("screen_name") as String,
                user_name: tweetData.objectForKey("user")?.objectForKey("name") as String,
                profile_image: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as String,
                post_detail: tweetData.objectForKey("created_at") as String,
                retweeted_name: tweetData.objectForKey("retweeted")?.objectForKey("screen_name") as? String,
                retweeted_profile_image: tweetData.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String
            )
            self.navigationController!.pushViewController(detailView, animated: true)
            break
        case 1:
            var userProfileView = ProfileViewController(screenName: (self.followUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as String)
            self.navigationController!.pushViewController(userProfileView, animated: true)
            break
        case 2:
            var userProfileView = ProfileViewController(screenName: (self.followerUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as String)
            self.navigationController!.pushViewController(userProfileView, animated: true)
            break
        default:
            break
        }
    }
    

    func updateTimeline(since_id: Int) {
        var params: Dictionary<String, String> = [
            "contributor_details" : "false",
            "trim_user" : "0",
            "count" : "10"
        ]
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params,
            "screen_name" : self.twitterScreenName!
        ]
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/user_timeline.json", params: parameter) { (new_timeline) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = new_timeline
                for new_tweet in self.newTimeline {
                    self.currentTimeline.insert(new_tweet, atIndex: 0)
                }
                self.tableView.reloadData()
            })
        }
        
    }
    
    func updateFollowUser(nextCursor: String?) {
        var params: Dictionary<String, String>
        if (nextCursor == nil) {
            params = [
                "screen_name" : self.twitterScreenName!
            ]
        } else {
            params = [
                "screen_name" : self.twitterScreenName!,
                "cursor" : nextCursor!
            ]
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/friends.json", params: parameter) { (follows) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var user = follows as NSDictionary
                self.followUsersNextCursor = user.objectForKey("next_cursor_str") as? String
                self.followUsers = self.followUsers + (user.objectForKey("users") as Array<AnyObject>)
                self.tableView.frame.size.height = CGFloat(self.followUsers.count) * 60.0
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func updateFollowerUser(nextCursor: String?) {
        var params: Dictionary<String, String>
        if (nextCursor == nil) {
            params = [
                "screen_name" : self.twitterScreenName!
            ]
        } else {
            params = [
                "screen_name" : self.twitterScreenName!,
                "cursor" : nextCursor!
            ]
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params,
            "screen_name" : self.twitterScreenName!
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/followers.json", params: parameter) { (follows) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var user = follows as NSDictionary
                self.followerUsersNextCursor = user.objectForKey("next_cursor_str") as? String
                self.followerUsers = self.followerUsers + (user.objectForKey("users") as Array<AnyObject>)
                self.tableView.frame.size.height = CGFloat(self.followerUsers.count) * 60.0 + self.headerHeight
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func tappedTweetNum() {
        self.tableType = 0
        self.tableView.reloadData()
        self.scrollView.contentInset.top = self.headerHeight
        self.tweetNumLabel.backgroundColor = self.selectedButtonColor
        self.tweetNumLabel.titleLabel?.textColor = self.selectedTextColor
        self.followNumLabel.backgroundColor = self.unselectedButtonColor
        self.followNumLabel.titleLabel?.textColor = self.unselectedTextColor
        self.followerNumLabel.backgroundColor = self.unselectedButtonColor
        self.followerNumLabel.titleLabel?.textColor = self.unselectedTextColor
        
    }
    
    func tappedFollowNum() {
        self.tableType = 1
        self.tweetNumLabel.backgroundColor = self.unselectedButtonColor
        self.tweetNumLabel.titleLabel?.textColor = self.unselectedTextColor
        self.followNumLabel.backgroundColor = self.selectedButtonColor
        var attributed = self.followNumLabel.titleLabel?.attributedText as NSMutableAttributedString
        var range = NSRangeFromString(self.followNumLabel.titleLabel?.text)
        attributed.addAttributes([NSForegroundColorAttributeName : self.selectedTextColor], range: range)
        self.followNumLabel.setAttributedTitle(attributed, forState: UIControlState.Normal)
        self.followNumLabel.titleLabel?.textColor = self.selectedTextColor
        self.followerNumLabel.backgroundColor = self.unselectedButtonColor
        self.followerNumLabel.titleLabel?.textColor = self.unselectedTextColor
        if (self.followUsers.count == 0) {
            self.updateFollowUser(nil)
        } else {
            self.tableView.reloadData()
        }
        
    }
    
    func tappedFollowerNum() {
        self.tableType = 2
        self.tweetNumLabel.backgroundColor = self.unselectedButtonColor
        self.tweetNumLabel.titleLabel?.textColor = self.unselectedTextColor
        self.followNumLabel.backgroundColor = self.unselectedButtonColor
        self.followNumLabel.titleLabel?.textColor = self.unselectedTextColor
        self.followerNumLabel.backgroundColor = self.selectedButtonColor
        var attributed = self.followerNumLabel.titleLabel?.attributedText as NSMutableAttributedString
        var range = NSRangeFromString(self.followerNumLabel.titleLabel?.text)
        attributed.addAttributes([NSForegroundColorAttributeName : self.selectedTextColor], range: range)
        self.followerNumLabel.setAttributedTitle(attributed, forState: UIControlState.Normal)
        self.followerNumLabel.titleLabel?.textColor = self.selectedTextColor
        if (self.followerUsers.count == 0) {
            self.updateFollowerUser(nil)
        } else {
            self.tableView.reloadData()
        }
    }
    
    // 更新は下方向（過去を遡る方向）にのみ実装する
    func userTableRefresh() {
        switch(self.tableType) {
        case 0:
            // TODO: タイムラインも更新したい
            // でもこれあとでいい
            self.scrollView.pullToRefreshView.stopAnimating()
            self.scrollView.contentInset = UIEdgeInsetsMake(self.tabBarController!.tabBar.frame.size.height, 0, self.tabBarController!.tabBar.frame.size.height, 0)
            break
        case 1:
            self.updateFollowUser(self.followUsersNextCursor)
            break
        case 2:
            self.updateFollowerUser(self.followerUsersNextCursor)
            break
        default:
            break
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollView.contentInset = UIEdgeInsetsMake(self.tabBarController!.tabBar.frame.size.height, 0, 0, 0)
    }

}
