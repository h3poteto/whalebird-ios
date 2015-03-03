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
    
    var HeaderImageHeight = CGFloat(160)
    let StatusHeight = CGFloat(40)
    let TextMargin = CGFloat(5)
    
    var twitterScreenName: String!
    var windowSize: CGRect!
    var headerHeight: CGFloat!
    var profileHeaderImageSrc: NSURL?
    
    var profileImage: UIImageView!
    var profileHeaderImage: UIImageView!
    var userNameLabel: UILabel!
    var followStatusLabel: UILabel!
    var descriptionLabel: UILabel!
    
    var tweetNumLabel: UIButton!
    var followNumLabel: UIButton!
    var followerNumLabel: UIButton!
    
    var tableView: UITableView!
    var scrollView: UIScrollView!
    
    var followButton: UIBarButtonItem!
    var unfollowButton: UIBarButtonItem!
    
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
    
    
    var tableType: Int = Int(0)
    
    //==========================================
    //  instance method
    //==========================================
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        var userDefault = NSUserDefaults.standardUserDefaults()
    }
    
    override init() {
        super.init()
    }
    
    init(aScreenName: NSString) {
        super.init()
        self.twitterScreenName = aScreenName
        self.title = "@" + aScreenName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.view.addSubview(self.scrollView)
        
        self.windowSize = UIScreen.mainScreen().bounds
        self.headerHeight = self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        self.followButton = UIBarButtonItem(title: "フォローする", style: UIBarButtonItemStyle.Plain, target: self, action: "tappedFollow")
        self.unfollowButton = UIBarButtonItem(title: "フォロー解除", style: UIBarButtonItemStyle.Plain, target: self, action: "tappedUnfollow")
        
        self.tableView = UITableView(frame: CGRectMake(0, self.HeaderImageHeight + self.StatusHeight, self.windowSize.size.width, 4000))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.scrollEnabled = false
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.scrollView.addSubview(self.tableView)
        self.scrollView.scrollEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: 2000)

        self.scrollView.addPullToRefreshWithActionHandler({ () -> Void in
            self.userTableRefresh()
        }, position: SVPullToRefreshPosition.Bottom)

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        // SVProgressHUDの表示スタイル設定
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hudTapped", name: SVProgressHUDDidReceiveTouchEventNotification, object: nil)
        
        var params:Dictionary<String, String> = [
            "screen_name" : self.twitterScreenName
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        //-------------------------
        //  header
        //-------------------------
        self.profileHeaderImage = UIImageView(frame: CGRectMake(0, 0, self.windowSize.width, self.HeaderImageHeight))
        self.profileHeaderImage.image = UIImage(named: "profile_back.jpg")
        self.scrollView.addSubview(self.profileHeaderImage)
            
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/profile_banner.json", params: cParameter, callback: { (aHeaderData) -> Void in
            var q_main = dispatch_get_main_queue()
            var error = NSError?()
            dispatch_async(q_main, {()->Void in
                if (aHeaderData.objectForKey("sizes")?.objectForKey("mobile_retina")?.objectForKey("url") != nil){
                    var headerImageURL = NSURL(string: aHeaderData.objectForKey("sizes")?.objectForKey("mobile_retina")?.objectForKey("url") as NSString)
                    self.profileHeaderImage.removeFromSuperview()
                    self.profileHeaderImage.sd_setImageWithURL(headerImageURL, placeholderImage: UIImage(named: "profile_back.jpg"))
                    self.scrollView.addSubview(self.profileHeaderImage)
                    self.profileHeaderImageSrc = headerImageURL
                }
            })
            WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/user.json", params: cParameter, callback: { (aUserData) -> Void in
                var q_sub = dispatch_get_main_queue()
                dispatch_async(q_sub, {()->Void in
                    
                    // フォローイベント
                    if( aUserData.objectForKey("following?") as Bool) {
                        self.navigationItem.rightBarButtonItem = self.unfollowButton
                    } else {
                        self.navigationItem.rightBarButtonItem = self.followButton
                    }
                    
                    // プロフィール表示
                    var profileImageURL = NSURL(string: aUserData.objectForKey("profile_image_url") as String)
                    self.profileImage = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                    self.profileImage.center = CGPoint(x: self.windowSize.width / 2.0, y: 40)
                    self.profileImage.sd_setImageWithURL(profileImageURL, placeholderImage: UIImage(named: "noimage.png"))
                    self.scrollView.addSubview(self.profileImage)
                    
                    self.userNameLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, self.profileImage.frame.origin.y + self.profileImage.frame.size.height + self.TextMargin, self.windowSize.width * 0.8, 15))
                    self.userNameLabel.text = aUserData.objectForKey("name") as String!
                    self.userNameLabel.font = UIFont(name: TimelineViewCell.BoldFont, size: 14)
                    self.userNameLabel.textColor = UIColor.blackColor()
                    self.userNameLabel.sizeToFit()
                    self.userNameLabel.textAlignment = NSTextAlignment.Center
                    var nameFrame:CGRect = self.userNameLabel.frame
                    nameFrame.size.width += 10
                    nameFrame.size.height += 5
                    self.userNameLabel.frame = nameFrame
                    self.userNameLabel.layer.cornerRadius = 5
                    self.userNameLabel.clipsToBounds = true
                    self.userNameLabel.center = CGPointMake(self.windowSize.width / 2.0, 80)
                    self.userNameLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
                    self.scrollView.addSubview(self.userNameLabel)
                    
                    self.followStatusLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height + self.TextMargin, self.windowSize.width * 0.8, 15))
                    if (aUserData.objectForKey("follower?") as Bool) {
                        self.followStatusLabel.text = "フォローされています"
                    } else {
                        self.followStatusLabel.text = "フォローされていません"
                    }
                    self.followStatusLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 10)
                    self.followStatusLabel.textColor = self.unselectedTextColor
                    self.followStatusLabel.backgroundColor = self.unselectedButtonColor
                    self.followStatusLabel.sizeToFit()
                    self.followStatusLabel.textAlignment = NSTextAlignment.Center
                    var followFrame:CGRect = self.followStatusLabel.frame
                    followFrame.size.width += 10
                    followFrame.size.height += 5
                    self.followStatusLabel.frame = followFrame
                    self.followStatusLabel.layer.cornerRadius = 5
                    self.followStatusLabel.clipsToBounds = true
                    self.followStatusLabel.center.x = self.windowSize.width     / 2.0
                    self.scrollView.addSubview(self.followStatusLabel)
                    
                    self.descriptionLabel = UILabel(frame: CGRectMake(self.windowSize.width * 0.1, self.followStatusLabel.frame.origin.y + self.followStatusLabel.frame.size.height + self.TextMargin, self.windowSize.width * 0.8, 15))
                    self.descriptionLabel.numberOfLines = 5
                    self.descriptionLabel.text = aUserData.objectForKey("description") as? String
                    self.descriptionLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 11)
                    self.descriptionLabel.sizeToFit()
                    self.descriptionLabel.textAlignment = NSTextAlignment.Center
                    var descriptionFrame: CGRect = self.descriptionLabel.frame
                    descriptionFrame.size.width += 10
                    descriptionFrame.size.height += 5
                    self.descriptionLabel.frame = descriptionFrame
                    self.descriptionLabel.layer.cornerRadius = 5
                    self.descriptionLabel.clipsToBounds = true
                    self.descriptionLabel.center.x = CGFloat(self.windowSize.width / 2.0)
                    self.descriptionLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
                    self.scrollView.addSubview(self.descriptionLabel)
                    
                    // table位置調節
                    if (self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height > self.HeaderImageHeight) {
                        self.HeaderImageHeight = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + self.TextMargin
                        self.tableView.frame.origin.y = self.HeaderImageHeight + self.StatusHeight
                        self.profileHeaderImage.frame.size.height = self.HeaderImageHeight
                        if (self.profileHeaderImageSrc != nil) {
                            self.profileHeaderImage.sd_setImageWithURL(self.profileHeaderImageSrc!, placeholderImage: UIImage(named: "noimage.png"))
                        } else {
                            self.profileHeaderImage.image = UIImage(named: "profile_back.jpg")
                        }
                    }
                    
                    //-----------------------------
                    //  status
                    //-----------------------------
                    
                    var tweetNumText = ("ツイート：" + String(aUserData.objectForKey("statuses_count") as Int)) as NSString
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
                    
                    
                    var followText = ("フォロー：" + String(aUserData.objectForKey("friends_count") as Int)) as NSString
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
                    
                    var followerText = ("フォロワー：" + String(aUserData.objectForKey("followers_count") as Int)) as NSString
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
        self.updateTimeline(0, aMoreIndex: nil)
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
        switch(self.tableType) {
        case 0:
            var timelineCell = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
            if (timelineCell == nil) {
                timelineCell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
            }
            
            timelineCell!.cleanCell()
            timelineCell!.configureCell(self.currentTimeline[indexPath.row] as NSDictionary)
            return timelineCell!
        case 1:
            var profileImageURL = NSURL(string: (self.followUsers[indexPath.row] as NSDictionary).objectForKey("profile_image_url") as NSString)
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell?.textLabel?.text = (self.followUsers[indexPath.row] as NSDictionary).objectForKey("name") as? String
            cell?.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 14)
            cell?.detailTextLabel?.textColor = UIColor.grayColor()
            cell?.detailTextLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
            cell?.detailTextLabel?.text = "@" + ((self.followUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as String!)
            
            cell?.imageView?.sd_setImageWithURL(profileImageURL, placeholderImage: UIImage(named: "noimage.png"))
            break
        case 2:
            var profileImageURL = NSURL(string: (self.followerUsers[indexPath.row] as NSDictionary).objectForKey("profile_image_url") as NSString)
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell?.textLabel?.text = (self.followerUsers[indexPath.row] as NSDictionary).objectForKey("name") as? String
            cell?.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 14)
            cell?.detailTextLabel?.textColor = UIColor.grayColor()
            cell?.detailTextLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
            cell?.detailTextLabel?.text = "@" + ((self.followerUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as String!)
            cell?.imageView?.sd_setImageWithURL(profileImageURL, placeholderImage: UIImage(named: "noimage.png"))
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
            height = TimelineViewCell.estimateCellHeight(self.currentTimeline[indexPath.row] as NSDictionary)
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.HeaderImageHeight + self.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            self.tableView.frame.size.height = self.tableView.contentSize.height
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
            let cTweetData = self.currentTimeline[indexPath.row] as NSDictionary
            var detailView = TweetDetailViewController(
                aTweetID: cTweetData.objectForKey("id_str") as String,
                aTweetBody: cTweetData.objectForKey("text") as String,
                aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as String,
                aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as String,
                aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as String,
                aPostDetail: cTweetData.objectForKey("created_at") as String,
                aRetweetedName: cTweetData.objectForKey("retweeted")?.objectForKey("screen_name") as? String,
                aRetweetedProfileImage: cTweetData.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String,
                aFavorited: cTweetData.objectForKey("favorited?") as? Bool,
                aMedia: cTweetData.objectForKey("media") as? NSArray,
                aParentArray: &self.currentTimeline,
                aParentIndex: indexPath.row
            )
            self.navigationController!.pushViewController(detailView, animated: true)
            break
        case 1:
            var userProfileView = ProfileViewController(aScreenName: (self.followUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as String)
            self.navigationController!.pushViewController(userProfileView, animated: true)
            break
        case 2:
            var userProfileView = ProfileViewController(aScreenName: (self.followerUsers[indexPath.row] as NSDictionary).objectForKey("screen_name") as String)
            self.navigationController!.pushViewController(userProfileView, animated: true)
            break
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    func updateTimeline(aSinceID: Int, aMoreIndex: Int?) {
        var params: Dictionary<String, String> = [
            "contributor_details" : "false",
            "trim_user" : "0",
            "count" : "20"
        ]
        if (aMoreIndex != nil) {
            var strMoreID = (self.currentTimeline[aMoreIndex!] as NSDictionary).objectForKey("id_str") as String
            // max_idは「以下」という判定になるので自身を含めない
            params["max_id"] = BigInteger(string: strMoreID).decrement()
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params,
            "screen_name" : self.twitterScreenName
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/user_timeline.json", params: cParameter) { (aNewTimeline) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                self.newTimeline = []
                for timeline in aNewTimeline {
                    var mutableTimeline = timeline.mutableCopy() as NSMutableDictionary
                    self.newTimeline.append(mutableTimeline)
                }
                if (aMoreIndex == nil) {
                    for newTweet in self.newTimeline {
                        self.currentTimeline.insert(newTweet, atIndex: 0)
                    }
                } else {
                    for newTweet in self.newTimeline.reverse() {
                        self.currentTimeline.append(newTweet)
                    }
                }

                // ここでtableView.contentSizeを再計算しないとだめっぽい
                self.tableView.frame.size.height = CGFloat(self.currentTimeline.count) * 200.0 + self.headerHeight
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            })
        }
        
    }
    
    func updateFollowUser(aNextCursor: String?) {
        var params: Dictionary<String, String> =  [
            "screen_name" : self.twitterScreenName
        ]
        if (aNextCursor != nil) {
            params["cursor"] = aNextCursor!
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/friends.json", params: parameter) { (aFollows) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var user = aFollows as NSDictionary
                self.followUsersNextCursor = user.objectForKey("next_cursor_str") as? String
                self.followUsers = self.followUsers + (user.objectForKey("users") as Array<AnyObject>)
                self.tableView.frame.size.height = CGFloat(self.followUsers.count) * 60.0 + self.headerHeight
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func updateFollowerUser(aNextCursor: String?) {
        var params: Dictionary<String, String> =  [
            "screen_name" : self.twitterScreenName
        ]
        if (aNextCursor != nil) {
            params["cursor"] = aNextCursor!
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params,
            "screen_name" : self.twitterScreenName
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/followers.json", params: cParameter) { (aFollows) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var user = aFollows as NSDictionary
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
        self.tableView.reloadData()
        
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
            self.updateTimeline(0, aMoreIndex: self.currentTimeline.count - 1)
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
    
    func hudTapped() {
        self.scrollView.pullToRefreshView.stopAnimating()
    }
    
    func tappedFollow() {
        var followAlert = UIAlertController(title: "Follow", message: "フォローしますか？", preferredStyle: .Alert)
        let cOkAction = UIAlertAction(title: "フォローする", style: .Default) { (action) -> Void in
            var parameter: Dictionary<String, AnyObject> = [
                "screen_name" : self.twitterScreenName
            ]
            var params: Dictionary<String, AnyObject> = [
                "settings" : parameter
            ]
            SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("/users/apis/follow.json", params: params) { (response) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "フォローしました")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as AppDelegate).alertPosition
                    notice.show()
                    self.navigationItem.rightBarButtonItem = self.unfollowButton
                })
            }
        }
        let cCancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        followAlert.addAction(cOkAction)
        followAlert.addAction(cCancelAction)
        self.presentViewController(followAlert, animated: true, completion: nil)
    }
    
    func tappedUnfollow() {
        var unfollowAlert = UIAlertController(title: "Unfollow", message: "フォロー解除しますか？", preferredStyle: .Alert)
        let cOkAction = UIAlertAction(title: "フォロー解除", style: .Default) { (action) -> Void in
            var parameter: Dictionary<String, AnyObject> = [
                "screen_name" : self.twitterScreenName
            ]
            var params: Dictionary<String, AnyObject> = [
                "settings" : parameter
            ]
            SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("/users/apis/unfollow.json", params: params) { (response) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "フォロー解除しました")
                    notice.alpha = 0.8
                    notice.originY = (UIApplication.sharedApplication().delegate as AppDelegate).alertPosition
                    notice.show()
                    self.navigationItem.rightBarButtonItem = self.followButton
                })
            }
        }
        let cCancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { (action) -> Void in
        }
        unfollowAlert.addAction(cOkAction)
        unfollowAlert.addAction(cCancelAction)
        self.presentViewController(unfollowAlert, animated: true, completion: nil)
        
    }
}
