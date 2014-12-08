//
//  MessageDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/12.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class MessageDetailViewController: UIViewController, TTTAttributedLabelDelegate {
    let LabelPadding = CGFloat(10)
    
    var messageID: String!
    var messageBody: String!
    var screenName: String!
    var userName: String!
    var profileImage: String!
    var postDetail: String!
    
    var screenNameLabel: UIButton!
    var userNameLabel: UIButton!
    var tweetBodyLabel: TTTAttributedLabel!
    var postDetailLabel: UILabel!
    var profileImageLabel: UIImageView!
    
    var replyMessageButton: UIBarButtonItem!

    //===============================================
    //  instance method
    //===============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "DM"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    init(aMessageID: String, aMessageBody: String, aScreeName: String, aUserName: String, aProfileImage: String, aPostDetail: String) {
        super.init()
        self.messageID = aMessageID
        self.messageBody = aMessageBody
        self.screenName = aScreeName
        self.userName = aUserName
        self.profileImage = aProfileImage
        self.postDetail = WhalebirdAPIClient.convertLocalTime(aPostDetail)
        self.title = "詳細"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cWindowSize = UIScreen.mainScreen().bounds
        var userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(cWindowSize.size.width * 0.05, self.navigationController!.navigationBar.frame.size.height * 2.0, cWindowSize.size.width * 0.9, 40))
        var imageURL = NSURL(string: self.profileImage)
        var error = NSError?()
        var imageData = NSData(contentsOfURL: imageURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
        if (error == nil) {
            self.profileImageLabel.image = UIImage(data: imageData!)
            self.profileImageLabel.sizeToFit()
        }
        self.view.addSubview(self.profileImageLabel)
        
        self.userNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 2.0, cWindowSize.size.width * 0.9, 15))
        
        if (userDefault.objectForKey("displayNameType") != nil && userDefault.integerForKey("displayNameType") == 2) {
            self.userNameLabel.setTitle("@" + self.screenName, forState: .Normal)
        } else {
            self.userNameLabel.setTitle(self.userName, forState: .Normal)
        }
        self.userNameLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.userNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.BoldFont, size: 15)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.userNameLabel.titleEdgeInsets = UIEdgeInsetsZero
        self.userNameLabel.sizeToFit()
        self.userNameLabel.frame.size.height = self.userNameLabel.titleLabel!.frame.size.height
        self.userNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 2.0 + self.userNameLabel.frame.size.height + 5, cWindowSize.size.width * 0.9, 15))
        if (userDefault.objectForKey("displayNameType") != nil && ( userDefault.integerForKey("displayNameType") == 2 || userDefault.integerForKey("displayNameType") == 3 )) {
        } else {
            self.screenNameLabel.setTitle("@" + self.screenName, forState: UIControlState.Normal)
        }
        self.screenNameLabel.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.screenNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsetsZero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.frame.size.height = self.screenNameLabel.titleLabel!.frame.size.height
        self.screenNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(self.screenNameLabel)
        
        
        self.tweetBodyLabel = TTTAttributedLabel(frame: CGRectMake(cWindowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + self.LabelPadding, cWindowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        self.tweetBodyLabel.numberOfLines = 0
        self.tweetBodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.tweetBodyLabel.text = self.messageBody
        self.tweetBodyLabel.sizeToFit()
        self.view.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(cWindowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + self.LabelPadding, cWindowSize.size.width * 0.9, 15))
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
        self.view.addSubview(self.postDetailLabel)
        
        self.replyMessageButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "tappedReplyMessage")
        self.navigationItem.rightBarButtonItem = self.replyMessageButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tappedReplyMessage() {
        var newMessage = NewDirectMessageViewController(aReplyToUser: self.screenName)
        self.navigationController!.pushViewController(newMessage, animated: true)
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }

}
