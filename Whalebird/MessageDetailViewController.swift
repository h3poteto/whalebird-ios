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
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(aMessageModel: MessageModel) {
        self.init()
        self.messageModel = aMessageModel
        self.title = NSLocalizedString("Title", tableName: "MessageDetail", comment: "")
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cWindowSize = UIScreen.main.bounds
        let userDefault = UserDefaults.standard
        
        self.profileImageLabel = UIImageView(frame: CGRect(x: cWindowSize.size.width * 0.05, y: self.navigationController!.navigationBar.frame.size.height * 2.0, width: cWindowSize.size.width * 0.9, height: 40))
        let imageURL = URL(string: self.messageModel.profileImage)
        self.profileImageLabel.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "noimage"))
        // 角丸にする
        self.profileImageLabel.layer.cornerRadius = 6.0
        self.profileImageLabel.layer.masksToBounds = true
        self.profileImageLabel.layer.borderWidth = 0.0
        self.profileImageLabel.sizeToFit()
        
        self.view.addSubview(self.profileImageLabel)
        
        self.userNameLabel = UIButton(frame: CGRect(x: cWindowSize.size.width * 0.05 + 60, y: self.navigationController!.navigationBar.frame.size.height * 1.7, width: cWindowSize.size.width * 0.9, height: 15))
        
        if (userDefault.object(forKey: "displayNameType") != nil && userDefault.integer(forKey: "displayNameType") == 2) {
            self.userNameLabel.setTitle("@" + self.messageModel.screenName, for: UIControlState())
        } else {
            self.userNameLabel.setTitle(self.messageModel.userName, for: UIControlState())
        }
        self.userNameLabel.setTitleColor(UIColor.black, for: UIControlState())
        self.userNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.BoldFont, size: 15)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.left
        self.userNameLabel.titleEdgeInsets = UIEdgeInsets.zero
        self.userNameLabel.sizeToFit()
        self.userNameLabel.addTarget(self, action: #selector(MessageDetailViewController.tappedUserProfile), for: UIControlEvents.touchDown)
        self.view.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UIButton(frame: CGRect(x: cWindowSize.size.width * 0.05 + 60, y: self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height - 10, width: cWindowSize.size.width * 0.9, height: 15))
        if (userDefault.object(forKey: "displayNameType") != nil && ( userDefault.integer(forKey: "displayNameType") == 2 || userDefault.integer(forKey: "displayNameType") == 3 )) {
        } else {
            self.screenNameLabel.setTitle("@" + self.messageModel.screenName, for: UIControlState())
        }
        self.screenNameLabel.setTitleColor(UIColor.gray, for: UIControlState())
        self.screenNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsets.zero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.addTarget(self, action: #selector(MessageDetailViewController.tappedUserProfile), for: UIControlEvents.touchDown)
        self.view.addSubview(self.screenNameLabel)
        
        
        self.tweetBodyLabel = UITextView(frame: CGRect(x: cWindowSize.size.width * 0.05, y: self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + MessageDetailViewController.LabelPadding, width: cWindowSize.size.width * 0.9, height: 15))
        self.tweetBodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.tweetBodyLabel.text = WhalebirdAPIClient.escapeString(self.messageModel.messageBody) as String
        self.tweetBodyLabel.delegate = self
        self.tweetBodyLabel.dataDetectorTypes = [UIDataDetectorTypes.link, UIDataDetectorTypes.address]
        self.tweetBodyLabel.isEditable = false
        self.tweetBodyLabel.isScrollEnabled = false
        self.tweetBodyLabel.layoutManager.delegate = self
        self.tweetBodyLabel.sizeToFit()
        self.view.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRect(x: cWindowSize.size.width * 0.05, y: self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + MessageDetailViewController.LabelPadding, width: cWindowSize.size.width * 0.9, height: 15))
        self.postDetailLabel.text = self.messageModel.postDetail
        self.postDetailLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
        self.view.addSubview(self.postDetailLabel)
        
        self.replyMessageButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.reply, target: self, action: #selector(MessageDetailViewController.tappedReplyMessage))
        self.navigationItem.rightBarButtonItem = self.replyMessageButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 4;
    }

    @objc func tappedReplyMessage() {
        let newMessage = NewDirectMessageViewController(aReplyToUser: self.messageModel.screenName)
        self.navigationController?.pushViewController(newMessage, animated: true)
    }
    
    @objc func tappedUserProfile() {
        let userProfileView = ProfileViewController(aScreenName: self.messageModel.screenName)
        self.navigationController?.pushViewController(userProfileView, animated: true)
    }

}
