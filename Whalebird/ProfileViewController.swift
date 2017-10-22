//
//  ProfileViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/14.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import QuartzCore
import SVProgressHUD
import SVPullToRefresh
import OHAttributedLabel
import NoticeView

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //=============================================
    //  class variables
    //=============================================
    fileprivate static let StatusHeight = CGFloat(40)
    fileprivate static let TextMargin = CGFloat(5)
    
    //===================================
    //  instance variables
    //===================================
    fileprivate var headerImageHeight = CGFloat(160)
    fileprivate var privateAccount = false
    var myself = false
    
    fileprivate var twitterScreenName: String!
    fileprivate var windowSize: CGRect!
    fileprivate var headerHeight: CGFloat!
    fileprivate var profileHeaderImageSrc: URL?
    
    fileprivate var profileImage: UIImageView!
    fileprivate var profileHeaderImage: UIImageView!
    fileprivate var userNameLabel: UILabel!
    fileprivate var followStatusLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    
    fileprivate var tweetNumLabel: UIButton!
    fileprivate var followNumLabel: UIButton!
    fileprivate var followerNumLabel: UIButton!
    
    fileprivate var tableView: UITableView!
    fileprivate var scrollView: UIScrollView!
    
    fileprivate var followButton: UIBarButtonItem!
    fileprivate var unfollowButton: UIBarButtonItem!
    
    fileprivate var followUsers: Array<AnyObject> = []
    fileprivate var followUsersNextCursor: String?
    fileprivate var followerUsers: Array<AnyObject> = []
    fileprivate var followerUsersNextCursor: String?
    fileprivate var privateAccountAnnounce: Array<AnyObject> = []
    
    fileprivate var selectedButtonColor = UIColor.white
    fileprivate let unselectedButtonColor = UIColor(red: 0.945, green: 0.946, blue: 0.947, alpha: 1.0)
    fileprivate let selectedTextColor = UIColor(red: 0.176, green: 0.584, blue: 0.957, alpha: 1.0)
    fileprivate let unselectedTextColor = UIColor.gray
    
    
    fileprivate var tableType: Int = Int(0)
    fileprivate var timelineModel: TimelineModel!
    
    //==========================================
    //  instance methods
    //==========================================
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(aScreenName: String) {
        self.init()
        self.twitterScreenName = aScreenName
        self.title = "@" + aScreenName
        self.timelineModel = TimelineModel(initSinceId: nil, initTimeline: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.view.addSubview(self.scrollView)
        
        self.windowSize = UIScreen.main.bounds
        self.headerHeight = self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        
        self.followButton = UIBarButtonItem(title: NSLocalizedString("Follow", tableName: "Profile", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.tappedFollow))
        self.unfollowButton = UIBarButtonItem(title: NSLocalizedString("Unfollow", tableName: "Profile", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.tappedUnfollow))
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: self.headerImageHeight + ProfileViewController.StatusHeight, width: self.windowSize.size.width, height: 100))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.scrollView.addSubview(self.tableView)
        self.scrollView.isScrollEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.windowSize.size.height + 100)


        self.scrollView.addPullToRefresh(actionHandler: { () -> Void in
            self.userTableRefresh()
        }, position: SVPullToRefreshPosition.bottom)

        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        // SVProgressHUDの表示スタイル設定
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.hudTapped), name: NSNotification.Name.SVProgressHUDDidReceiveTouchEvent, object: nil)
        
        let params:Dictionary<String, String> = [
            "screen_name" : self.twitterScreenName
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        //-------------------------
        //  header
        //-------------------------
        self.profileHeaderImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.windowSize.width, height: self.headerImageHeight))
        self.profileHeaderImage.image = UIImage(named: "profile_back")
        self.scrollView.addSubview(self.profileHeaderImage)
            
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/profile_banner.json", params: cParameter, callback: { (aHeaderData) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                if (((aHeaderData.object(forKey: "sizes") as? NSDictionary)?.object(forKey: "mobile_retina") as? NSDictionary)?.object(forKey: "url") != nil){
                    let headerImageURL = URL(string: ((aHeaderData.object(forKey: "sizes") as? NSDictionary)?.object(forKey: "mobile_retina") as? NSDictionary)?.object(forKey: "url") as! String)
                    self.profileHeaderImage.removeFromSuperview()
                    self.profileHeaderImage.sd_setImage(with: headerImageURL, placeholderImage: UIImage(named: "profile_back"))
                    self.scrollView.addSubview(self.profileHeaderImage)
                    self.profileHeaderImageSrc = headerImageURL
                }
            })
            WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/user.json", params: cParameter, callback: { (aUserData) -> Void in
                let q_sub = DispatchQueue.main
                q_sub.async(execute: {()->Void in
                    
                    self.privateAccount = aUserData.object(forKey: "private_account?") as! Bool
                    
                    // フォローイベント
                    if (aUserData.object(forKey: "follow_request_sent?") as! Bool) {
                    } else {
                        if self.myself {
                            self.navigationItem.rightBarButtonItem = nil
                        } else {
                            if aUserData.object(forKey: "following?") as! Bool {
                                self.navigationItem.rightBarButtonItem = self.unfollowButton
                            } else {
                                self.navigationItem.rightBarButtonItem = self.followButton
                            }
                        }
                    }
                    //-----------------------------
                    //  body
                    //-----------------------------
                    if self.privateAccount && !self.myself {
                        self.tableType = 3
                        self.privateAccountAnnounce = ["private" as AnyObject]
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    } else {
                        self.updateTimeline(nil)
                    }
                    
                    // プロフィール表示
                    let profileImageURL = URL(string: aUserData.object(forKey: "profile_image_url") as! String)
                    self.profileImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                    self.profileImage.center = CGPoint(x: self.windowSize.width / 2.0, y: 40)
                    self.profileImage.sd_setImage(with: profileImageURL, placeholderImage: UIImage(named: "noimage"))
                    // 角丸にする
                    self.profileImage.layer.cornerRadius = 6.0
                    self.profileImage.layer.masksToBounds = true
                    self.profileImage.layer.borderWidth = 0.0
                    self.scrollView.addSubview(self.profileImage)
                    
                    self.userNameLabel = UILabel(frame: CGRect(x: self.windowSize.width * 0.1, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + ProfileViewController.TextMargin, width: self.windowSize.width * 0.8, height: 15))
                    self.userNameLabel.text = aUserData.object(forKey: "name") as? String
                    self.userNameLabel.font = UIFont(name: TimelineViewCell.BoldFont, size: 14)
                    self.userNameLabel.textColor = UIColor.black
                    self.userNameLabel.sizeToFit()
                    self.userNameLabel.textAlignment = NSTextAlignment.center
                    var nameFrame:CGRect = self.userNameLabel.frame
                    nameFrame.size.width += 10
                    nameFrame.size.height += 5
                    self.userNameLabel.frame = nameFrame
                    self.userNameLabel.layer.cornerRadius = 5
                    self.userNameLabel.clipsToBounds = true
                    self.userNameLabel.center = CGPoint(x: self.windowSize.width / 2.0, y: 80)
                    self.userNameLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
                    self.scrollView.addSubview(self.userNameLabel)
                    
                    self.followStatusLabel = UILabel(frame: CGRect(x: self.windowSize.width * 0.1, y: self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height + ProfileViewController.TextMargin, width: self.windowSize.width * 0.8, height: 15))
                    if !self.myself {
                        if aUserData.object(forKey: "follower?") as! Bool {
                            self.followStatusLabel.text = NSLocalizedString("BeingFollowed", tableName: "Profile", comment: "")
                        } else {
                            self.followStatusLabel.text = NSLocalizedString("NotBeingFollowed", tableName: "Profile", comment: "")
                        }
                    }
                    self.followStatusLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 10)
                    self.followStatusLabel.textColor = self.unselectedTextColor
                    self.followStatusLabel.backgroundColor = self.unselectedButtonColor
                    self.followStatusLabel.sizeToFit()
                    self.followStatusLabel.textAlignment = NSTextAlignment.center
                    var followFrame:CGRect = self.followStatusLabel.frame
                    followFrame.size.width += 10
                    followFrame.size.height += 5
                    self.followStatusLabel.frame = followFrame
                    self.followStatusLabel.layer.cornerRadius = 5
                    self.followStatusLabel.clipsToBounds = true
                    self.followStatusLabel.center.x = self.windowSize.width     / 2.0
                    self.scrollView.addSubview(self.followStatusLabel)
                    
                    self.descriptionLabel = UILabel(frame: CGRect(x: self.windowSize.width * 0.1, y: self.followStatusLabel.frame.origin.y + self.followStatusLabel.frame.size.height + ProfileViewController.TextMargin, width: self.windowSize.width * 0.8, height: 15))
                    self.descriptionLabel.numberOfLines = 5
                    self.descriptionLabel.text = aUserData.object(forKey: "description") as? String
                    self.descriptionLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 11)
                    self.descriptionLabel.sizeToFit()
                    self.descriptionLabel.textAlignment = NSTextAlignment.center
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
                    if (self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height > self.headerImageHeight) {
                        self.headerImageHeight = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + ProfileViewController.TextMargin
                        self.tableView.frame.origin.y = self.headerImageHeight + ProfileViewController.StatusHeight
                        self.profileHeaderImage.frame.size.height = self.headerImageHeight
                        if (self.profileHeaderImageSrc != nil) {
                            self.profileHeaderImage.sd_setImage(with: self.profileHeaderImageSrc!, placeholderImage: UIImage(named: "noimage"))
                        } else {
                            self.profileHeaderImage.image = UIImage(named: "profile_back")
                        }
                    }
                    
                    //-----------------------------
                    //  status
                    //-----------------------------
                    
                    let tweetNumText = (NSLocalizedString("TweetCount", tableName: "Profile", comment: "") + String(aUserData.object(forKey: "statuses_count") as! Int)) as NSString
                    let tweetNumAttributedString = NSMutableAttributedString(string: tweetNumText as String, attributes: [NSAttributedStringKey.foregroundColor: self.selectedTextColor,  NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
                    let tweetNumRange = tweetNumText.range(of: NSLocalizedString("TweetCount", tableName: "Profile", comment: ""))
                    tweetNumAttributedString.setFont(UIFont.systemFont(ofSize: 10), range: tweetNumRange)
                    
                    self.tweetNumLabel = UIButton(frame: CGRect(x: 0, y: self.headerImageHeight, width: self.windowSize.size.width / 3.0, height: ProfileViewController.StatusHeight))
                    
                    self.tweetNumLabel.setAttributedTitle(tweetNumAttributedString, for: UIControlState())
                    self.tweetNumLabel.titleLabel?.textAlignment = NSTextAlignment.center
                    self.tweetNumLabel.layer.borderColor = UIColor.gray.cgColor
                    self.tweetNumLabel.layer.borderWidth = 0.5
                    self.tweetNumLabel.backgroundColor = self.selectedButtonColor
                    self.tweetNumLabel.addTarget(self, action: #selector(ProfileViewController.tappedTweetNum), for: UIControlEvents.touchDown)
                    self.scrollView.addSubview(self.tweetNumLabel)
                    
                    
                    let followText = (NSLocalizedString("FriendCount", tableName: "Profile", comment: "") + String(aUserData.object(forKey: "friends_count") as! Int)) as NSString
                    let followAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followText as String, attributes: [NSAttributedStringKey.foregroundColor: self.unselectedTextColor, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
                    let followRange: NSRange = followText.range(of: NSLocalizedString("FriendCount", tableName: "Profile", comment: ""))
                    followAttributedString.setFont(UIFont.systemFont(ofSize: 10), range: followRange)
                    
                    self.followNumLabel = UIButton(frame: CGRect(x: self.windowSize.size.width / 3.0, y: self.headerImageHeight, width: self.windowSize.size.width / 3.0, height: ProfileViewController.StatusHeight))
                    self.followNumLabel.setAttributedTitle(followAttributedString, for: UIControlState())
                    self.followNumLabel.titleLabel?.textAlignment = NSTextAlignment.center
                    self.followNumLabel.layer.borderColor = UIColor.gray.cgColor
                    self.followNumLabel.layer.borderWidth = 0.5
                    self.followNumLabel.backgroundColor = self.unselectedButtonColor
                    self.followNumLabel.addTarget(self, action: #selector(ProfileViewController.tappedFollowNum), for: UIControlEvents.touchDown)
                    self.scrollView.addSubview(self.followNumLabel)
                    self.followNumLabel.titleLabel?.textColor = self.unselectedTextColor
                    
                    let followerText = (NSLocalizedString("FollowerCount", tableName: "Profile", comment: "") + String(aUserData.object(forKey: "followers_count") as! Int)) as NSString
                    let followerAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: followerText as String, attributes: [NSAttributedStringKey.foregroundColor: self.unselectedTextColor, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
                    let followerRange: NSRange = followerText.range(of: NSLocalizedString("FollowerCount", tableName: "Profile", comment: ""))
                    followerAttributedString.setFont(UIFont.systemFont(ofSize: 10), range: followerRange)
                    
                    self.followerNumLabel = UIButton(frame: CGRect(x: self.windowSize.size.width * 2.0 / 3.0, y: self.headerImageHeight, width: self.windowSize.size.width / 3.0, height: ProfileViewController.StatusHeight))
                    self.followerNumLabel.setAttributedTitle(followerAttributedString, for: UIControlState())
                    self.followerNumLabel.titleLabel?.textAlignment = NSTextAlignment.center
                    self.followerNumLabel.layer.borderColor = UIColor.gray.cgColor
                    self.followerNumLabel.layer.borderWidth = 0.5
                    self.followerNumLabel.backgroundColor = self.unselectedButtonColor
                    self.followerNumLabel.addTarget(self, action: #selector(ProfileViewController.tappedFollowerNum), for: UIControlEvents.touchDown)
                    self.scrollView.addSubview(self.followerNumLabel)
                    
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        var row = 0
        switch(self.tableType){
        case 0:
            row = self.timelineModel.count()
            break
        case 1:
            row = self.followUsers.count
            break
        case 2:
            row = self.followerUsers.count
            break
        case 3:
            row = self.privateAccountAnnounce.count
            break
        default:
            row = self.timelineModel.count()
            break
        }
        return row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch(self.tableType) {
        case 0:
            var timelineCell = tableView.dequeueReusableCell(withIdentifier: "TimelineViewCell", for: indexPath) as? TimelineViewCell
            if (timelineCell == nil) {
                timelineCell = TimelineViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "TimelineViewCell")
            }
            
            timelineCell!.cleanCell()
            if let targetTimeline = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
                timelineCell!.configureCell(targetTimeline as NSDictionary)
            }
            return timelineCell!
        case 1:
            let profileImageURL = URL(string: (self.followUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "profile_image_url_https") as! String)
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            cell?.textLabel?.text = (self.followUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "name") as? String
            cell?.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 14)
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.detailTextLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
            cell?.detailTextLabel?.text = "@" + ((self.followUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "screen_name") as! String!)
            
            cell?.imageView?.sd_setImage(with: profileImageURL, placeholderImage: UIImage(named: "noimage"))
            // 角丸にする
            cell?.imageView?.layer.cornerRadius = 6.0
            cell?.imageView?.layer.masksToBounds = true
            cell?.imageView?.layer.borderWidth = 0.0
            break
        case 2:
            let profileImageURL = URL(string: (self.followerUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "profile_image_url_https") as! String)
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            cell?.textLabel?.text = (self.followerUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "name") as? String
            cell?.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 14)
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.detailTextLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
            cell?.detailTextLabel?.text = "@" + ((self.followerUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "screen_name") as! String
            )
            cell?.imageView?.sd_setImage(with: profileImageURL, placeholderImage: UIImage(named: "noimage"))
            // 角丸にする
            cell?.imageView?.layer.cornerRadius = 6.0
            cell?.imageView?.layer.masksToBounds = true
            cell?.imageView?.layer.borderWidth = 0.0
            break
        case 3:
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
            cell?.textLabel?.text = NSLocalizedString("ProtectedAccount", tableName: "Profile", comment: "")
            cell?.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 14)
            break
        default:
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            break
        }
        
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        switch(self.tableType) {
        case 0:
            if let targetTimeline = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
                height = TimelineViewCell.estimateCellHeight(targetTimeline as NSDictionary)
            }
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.headerImageHeight + ProfileViewController.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            self.tableView.frame.size.height = self.tableView.contentSize.height
            break
        case 1:
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.headerImageHeight + ProfileViewController.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            break
        case 2:
            self.scrollView.contentSize = CGSize(width: self.windowSize.size.width, height: self.tableView.contentSize.height + self.headerImageHeight + ProfileViewController.StatusHeight + self.tabBarController!.tabBar.frame.size.height)
            break
        default:
            break
        }
        return height
    }
   

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(self.tableType){
        case 0:
            if let cTweetData = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
                let tweetModel = TweetModel(dict: cTweetData)
                let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: (indexPath as NSIndexPath).row)
                self.navigationController?.pushViewController(detailView, animated: true)
            }
            break
        case 1:
            let userProfileView = ProfileViewController(aScreenName: (self.followUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "screen_name") as! String)
            self.navigationController?.pushViewController(userProfileView, animated: true)
            break
        case 2:
            let userProfileView = ProfileViewController(aScreenName: (self.followerUsers[(indexPath as NSIndexPath).row] as! NSDictionary).object(forKey: "screen_name") as! String)
            self.navigationController?.pushViewController(userProfileView, animated: true)
            break
        default:
            break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 途中読み込みがないので，変則的なメソッド追加でtimelineModelに寄せられそう
    func updateTimeline(_ aMoreIndex: Int?) {
        var params: Dictionary<String, String> = [
            "contributor_details" : "false",
            "trim_user" : "0",
            "count" : "20"
        ]
        if (aMoreIndex != nil) {
            if let strMoreID = self.timelineModel.getTweetAtIndex(aMoreIndex!)?["id_str"] as? String {
                // max_idは「以下」という判定になるので自身を含めない
                params["max_id"] = BigInteger(string: strMoreID).decrement()
            }
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject,
            "screen_name" : self.twitterScreenName as AnyObject
        ]
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        self.timelineModel.updateTimelineWithoutMoreCell("users/apis/user_timeline.json",
            requestParameter: cParameter,
            moreIndex: aMoreIndex,
            completed: { (count, currentRowIndex) -> Void in
                // ここでtableView.contentSizeを再計算しないとだめっぽい
                self.tableView.frame.size.height = CGFloat(self.timelineModel.count()) * 200.0 + self.headerHeight
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            }, noUpdated: { () -> Void in
            
            }, failed: { () -> Void in
            
        })
    }
    
    func updateFollowUser(_ aNextCursor: String?) {
        var params: Dictionary<String, String> =  [
            "screen_name" : self.twitterScreenName
        ]
        if (aNextCursor != nil) {
            params["cursor"] = aNextCursor!
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/friends.json", params: parameter) { (aFollows) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                let user = aFollows as NSDictionary
                self.followUsersNextCursor = user.object(forKey: "next_cursor_str") as? String
                self.followUsers = self.followUsers + (user.object(forKey: "users") as! Array<AnyObject>)
                self.tableView.frame.size.height = CGFloat(self.followUsers.count) * 60.0 + self.headerHeight
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func updateFollowerUser(_ aNextCursor: String?) {
        var params: Dictionary<String, String> =  [
            "screen_name" : self.twitterScreenName
        ]
        if (aNextCursor != nil) {
            params["cursor"] = aNextCursor!
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject,
            "screen_name" : self.twitterScreenName as AnyObject
        ]
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
        WhalebirdAPIClient.sharedClient.getDictionaryAPI("users/apis/followers.json", params: cParameter) { (aFollows) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                let user = aFollows as NSDictionary
                self.followerUsersNextCursor = user.object(forKey: "next_cursor_str") as? String
                self.followerUsers = self.followerUsers + (user.object(forKey: "users") as! Array<AnyObject>)
                self.tableView.frame.size.height = CGFloat(self.followerUsers.count) * 60.0 + self.headerHeight
                self.tableView.reloadData()
                self.scrollView.pullToRefreshView.stopAnimating()
                self.scrollView.contentInset.top = self.headerHeight
                SVProgressHUD.dismiss()
            })
        }
    }
    
    
    @objc func tappedTweetNum() {
        if (!self.privateAccount) {
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
        
    }
    
    @objc func tappedFollowNum() {
        if (!self.privateAccount) {
            self.tableType = 1
            self.tweetNumLabel.backgroundColor = self.unselectedButtonColor
            self.tweetNumLabel.titleLabel?.textColor = self.unselectedTextColor
            self.followNumLabel.backgroundColor = self.selectedButtonColor
            let attributed = self.followNumLabel.titleLabel?.attributedText as! NSMutableAttributedString
            let range = NSRangeFromString((self.followNumLabel.titleLabel?.text)!)
            attributed.addAttributes([NSAttributedStringKey.foregroundColor : self.selectedTextColor], range: range)
            self.followNumLabel.setAttributedTitle(attributed, for: UIControlState())
            self.followNumLabel.titleLabel?.textColor = self.selectedTextColor
            self.followerNumLabel.backgroundColor = self.unselectedButtonColor
            self.followerNumLabel.titleLabel?.textColor = self.unselectedTextColor
            if (self.followUsers.count == 0) {
                self.updateFollowUser(nil)
            } else {
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func tappedFollowerNum() {
        if (!self.privateAccount) {
            self.tableType = 2
            self.tweetNumLabel.backgroundColor = self.unselectedButtonColor
            self.tweetNumLabel.titleLabel?.textColor = self.unselectedTextColor
            self.followNumLabel.backgroundColor = self.unselectedButtonColor
            self.followNumLabel.titleLabel?.textColor = self.unselectedTextColor
            self.followerNumLabel.backgroundColor = self.selectedButtonColor
            let attributed = self.followerNumLabel.titleLabel?.attributedText as! NSMutableAttributedString
            let range = NSRangeFromString((self.followerNumLabel.titleLabel?.text)!)
            attributed.addAttributes([NSAttributedStringKey.foregroundColor : self.selectedTextColor], range: range)
            self.followerNumLabel.setAttributedTitle(attributed, for: UIControlState())
            self.followerNumLabel.titleLabel?.textColor = self.selectedTextColor
            if (self.followerUsers.count == 0) {
                self.updateFollowerUser(nil)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    // 更新は下方向（過去を遡る方向）にのみ実装する
    func userTableRefresh() {
        if (!self.privateAccount) {
            switch(self.tableType) {
            case 0:
                self.updateTimeline(self.timelineModel.count() - 1)
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
    }
    
    @objc func hudTapped() {
        self.scrollView.pullToRefreshView.stopAnimating()
    }
    
    @objc func tappedFollow() {
        let followAlert = UIAlertController(title: NSLocalizedString("FollowTitle", tableName: "Profile", comment: ""), message: NSLocalizedString("FollowConfirm", tableName: "Profile", comment: ""), preferredStyle: .alert)
        let cOkAction = UIAlertAction(title: NSLocalizedString("FollowOK", tableName: "Profile", comment: ""), style: .default) { (action) -> Void in
            let parameter: Dictionary<String, AnyObject> = [
                "screen_name" : self.twitterScreenName as AnyObject
            ]
            let params: Dictionary<String, AnyObject> = [
                "settings" : parameter as AnyObject
            ]
            SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("/users/apis/follow.json", params: params) { (response) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: {()->Void in
                    SVProgressHUD.dismiss()
                    let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("FollowComplete", tableName: "Profile", comment: ""))
                    notice?.alpha = 0.8
                    notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                    notice?.show()
                    if (self.privateAccount) {
                    } else{
                        self.navigationItem.rightBarButtonItem = self.unfollowButton
                    }
                })
            }
        }
        let cCancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        followAlert.addAction(cCancelAction)
        followAlert.addAction(cOkAction)
        self.present(followAlert, animated: true, completion: nil)
    }
    
    @objc func tappedUnfollow() {
        let unfollowAlert = UIAlertController(title: NSLocalizedString("UnfollowTitle", tableName: "Profile", comment: ""), message: NSLocalizedString("UnfollowConfirm", tableName: "Profile", comment: ""), preferredStyle: .alert)
        let cOkAction = UIAlertAction(title: NSLocalizedString("UnfollowOK", tableName: "Profile", comment: ""), style: .default) { (action) -> Void in
            let parameter: Dictionary<String, AnyObject> = [
                "screen_name" : self.twitterScreenName as AnyObject
            ]
            let params: Dictionary<String, AnyObject> = [
                "settings" : parameter as AnyObject
            ]
            SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("/users/apis/unfollow.json", params: params) { (response) -> Void in
                let q_main = DispatchQueue.main
                q_main.async(execute: {()->Void in
                    SVProgressHUD.dismiss()
                    let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("UnfollowComplete", tableName: "Profile", comment: ""))
                    notice?.alpha = 0.8
                    notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                    notice?.show()
                    self.navigationItem.rightBarButtonItem = self.followButton
                })
            }
        }
        let cCancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) -> Void in
        }
        unfollowAlert.addAction(cCancelAction)
        unfollowAlert.addAction(cOkAction)
        self.present(unfollowAlert, animated: true, completion: nil)
        
    }
    
}
