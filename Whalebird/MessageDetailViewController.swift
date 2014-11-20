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
    
    init(MessageID: String, MessageBody: String, ScreeName: String, UserName: String, ProfileImage: String, PostDetail: String) {
        super.init()
        self.messageID = MessageID
        self.messageBody = MessageBody
        self.screenName = ScreeName
        self.userName = UserName
        self.profileImage = ProfileImage
        self.postDetail = WhalebirdAPIClient.convertLocalTime(PostDetail)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let windowSize = UIScreen.mainScreen().bounds
        var userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(windowSize.size.width * 0.05, self.navigationController!.navigationBar.frame.size.height * 2.0, windowSize.size.width * 0.9, 40))
        var image_url = NSURL(string: self.profileImage)
        var error = NSError?()
        var imageData = NSData(contentsOfURL: image_url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
        if (error == nil) {
            self.profileImageLabel.image = UIImage(data: imageData!)
            self.profileImageLabel.sizeToFit()
        }
        self.view.addSubview(self.profileImageLabel)
        
        self.userNameLabel = UIButton(frame: CGRectMake(windowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 2.0, windowSize.size.width * 0.9, 15))
        self.userNameLabel.setTitle(self.userName, forState: .Normal)
        self.userNameLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.userNameLabel.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.userNameLabel.titleEdgeInsets = UIEdgeInsetsZero
        self.userNameLabel.sizeToFit()
        self.userNameLabel.frame.size.height = self.userNameLabel.titleLabel!.frame.size.height
        self.userNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 3 ) {
            self.view.addSubview(self.userNameLabel)
        }
        
        self.screenNameLabel = UIButton(frame: CGRectMake(windowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 2.0 + self.userNameLabel.frame.size.height + 5, windowSize.size.width * 0.9, 15))
        self.screenNameLabel.setTitle("@" + self.screenName, forState: UIControlState.Normal)
        self.screenNameLabel.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.screenNameLabel.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsetsZero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.frame.size.height = self.screenNameLabel.titleLabel!.frame.size.height
        self.screenNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 2 ) {
            self.view.addSubview(self.screenNameLabel)
        }
        
        self.tweetBodyLabel = TTTAttributedLabel(frame: CGRectMake(windowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + self.LabelPadding, windowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        self.tweetBodyLabel.numberOfLines = 0
        self.tweetBodyLabel.font = UIFont.systemFontOfSize(15)
        self.tweetBodyLabel.text = self.messageBody
        self.tweetBodyLabel.sizeToFit()
        self.view.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + self.LabelPadding, windowSize.size.width * 0.9, 15))
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont.systemFontOfSize(11)
        self.view.addSubview(self.postDetailLabel)
        
        self.replyMessageButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "tappedReplyMessage")
        self.navigationItem.rightBarButtonItem = self.replyMessageButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tappedReplyMessage() {
        var newMessage = NewDirectMessageViewController(ReplyToUser: self.screenName)
        self.navigationController!.pushViewController(newMessage, animated: true)
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }

}
