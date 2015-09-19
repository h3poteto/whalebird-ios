//
//  MessageDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/12.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD


class MessageDetailViewController: UIViewController, UITextViewDelegate, NSLayoutManagerDelegate {

    //=============================================
    //  class variables
    //=============================================
    static let LabelPadding = CGFloat(10)

    //=============================================
    //  instance variables
    //=============================================
    var messageModel: MessageModel!
    
    var screenNameLabel: UIButton!
    var userNameLabel: UIButton!
    var tweetBodyLabel: UITextView!
    var postDetailLabel: UILabel!
    var profileImageLabel: UIImageView!
    
    var replyMessageButton: UIBarButtonItem!

    //===============================================
    //  instance methods
    //===============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(aMessageModel: MessageModel) {
        self.init()
        self.messageModel = aMessageModel
        self.title = "詳細"
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cWindowSize = UIScreen.mainScreen().bounds
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(cWindowSize.size.width * 0.05, self.navigationController!.navigationBar.frame.size.height * 2.0, cWindowSize.size.width * 0.9, 40))
        let imageURL = NSURL(string: self.messageModel.profileImage)
        self.profileImageLabel.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "noimage"))
        self.profileImageLabel.sizeToFit()
        
        self.view.addSubview(self.profileImageLabel)
        
        self.userNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 1.7, cWindowSize.size.width * 0.9, 15))
        
        if (userDefault.objectForKey("displayNameType") != nil && userDefault.integerForKey("displayNameType") == 2) {
            self.userNameLabel.setTitle("@" + self.messageModel.screenName, forState: .Normal)
        } else {
            self.userNameLabel.setTitle(self.messageModel.userName, forState: .Normal)
        }
        self.userNameLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.userNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.BoldFont, size: 15)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.userNameLabel.titleEdgeInsets = UIEdgeInsetsZero
        self.userNameLabel.sizeToFit()
        self.userNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05 + 60, self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height - 10, cWindowSize.size.width * 0.9, 15))
        if (userDefault.objectForKey("displayNameType") != nil && ( userDefault.integerForKey("displayNameType") == 2 || userDefault.integerForKey("displayNameType") == 3 )) {
        } else {
            self.screenNameLabel.setTitle("@" + self.messageModel.screenName, forState: UIControlState.Normal)
        }
        self.screenNameLabel.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.screenNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsetsZero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(self.screenNameLabel)
        
        
        self.tweetBodyLabel = UITextView(frame: CGRectMake(cWindowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + MessageDetailViewController.LabelPadding, cWindowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.tweetBodyLabel.text = WhalebirdAPIClient.escapeString(self.messageModel.messageBody) as String
        self.tweetBodyLabel.delegate = self
        self.tweetBodyLabel.dataDetectorTypes = [UIDataDetectorTypes.Link, UIDataDetectorTypes.Address]
        self.tweetBodyLabel.editable = false
        self.tweetBodyLabel.scrollEnabled = false
        self.tweetBodyLabel.layoutManager.delegate = self
        self.tweetBodyLabel.sizeToFit()
        self.view.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(cWindowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + MessageDetailViewController.LabelPadding, cWindowSize.size.width * 0.9, 15))
        self.postDetailLabel.text = self.messageModel.postDetail
        self.postDetailLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
        self.view.addSubview(self.postDetailLabel)
        
        self.replyMessageButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "tappedReplyMessage")
        self.navigationItem.rightBarButtonItem = self.replyMessageButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 4;
    }

    func tappedReplyMessage() {
        let newMessage = NewDirectMessageViewController(aReplyToUser: self.messageModel.screenName)
        self.navigationController?.pushViewController(newMessage, animated: true)
    }
    

}
