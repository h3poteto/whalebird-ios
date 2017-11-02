//
//  TweetDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/02.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD
import NoticeView
import OHAttributedLabel

class TweetDetailViewController: UIViewController, UIActionSheetDelegate, UITextViewDelegate, NSLayoutManagerDelegate {
    //====================================
    //  class variables
    //====================================
    static let LabelPadding = CGFloat(10)
    static let ActionButtonWidth = CGFloat(50)
    static let ActionButtonHeight = CGFloat(40)
    
    //=====================================
    //  instance variables
    //=====================================
    var timelineModel: TimelineModel?
    var parentIndex: Int?
    var tweetModel: TweetModel!
    
    var blankView: UIScrollView!
    var screenNameLabel: UIButton!
    var userNameLabel: UIButton!
    var tweetBodyLabel: UITextView!
    var postDetailLabel: UILabel!
    var innerMediaButton: Array<UIButton>?
    var profileImageLabel: UIButton!
    var retweetedNameLabel: UIButton?
    var retweetedProfileImageLabel: UIImageView?
    
    var replyButton: UIButton!
    var conversationButton: UIButton!
    var favButton: UIButton!
    var deleteButton: UIButton!
    var moreButton: UIButton!
    
    
    var newTweetButton: UIBarButtonItem!
    var cWindowSize: CGRect!
    
    //=====================================
    //  instance method
    //=====================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(aTweetModel: TweetModel!, aTimelineModel: TimelineModel?, aParentIndex: Int?) {
        self.init()
        self.tweetModel = aTweetModel
        self.timelineModel = aTimelineModel
        self.parentIndex = aParentIndex
        self.title = NSLocalizedString("Title", tableName: "TweetDetail", comment: "")
    }
    
    override func loadView() {
        super.loadView()
        self.blankView = UIScrollView(frame: self.view.bounds)
        self.blankView.backgroundColor = UIColor.white
        self.blankView.isScrollEnabled = true
        self.view.addSubview(self.blankView)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(TweetDetailViewController.tappedNewTweet(_:)))
        self.navigationItem.rightBarButtonItem = self.newTweetButton
        
        self.cWindowSize = UIScreen.main.bounds
        let userDefault = UserDefaults.standard
        
        self.profileImageLabel = UIButton(frame: CGRect(x: self.cWindowSize.size.width * 0.05, y: self.cWindowSize.size.width * 0.05, width: self.cWindowSize.size.width * 0.9, height: 40))
        let imageURL = URL(string: self.tweetModel.profileImage)
        self.profileImageLabel.sd_setBackgroundImage(with: imageURL, for: UIControlState(), placeholderImage: UIImage(named: "noimage"))
        self.profileImageLabel.addTarget(self, action: #selector(TweetDetailViewController.tappedUserProfile), for: UIControlEvents.touchDown)
        // 角丸にする
        self.profileImageLabel.layer.cornerRadius = 6.0
        self.profileImageLabel.layer.masksToBounds = true
        self.profileImageLabel.layer.borderWidth = 0.0
        self.profileImageLabel.sizeToFit()
        
        self.blankView.addSubview(self.profileImageLabel)
        
        if (self.tweetModel.retweetedProfileImage != nil) {
            self.retweetedProfileImageLabel = UIImageView(frame: CGRect(x: self.profileImageLabel.frame.origin.x + self.profileImageLabel.frame.size.width * 2.0 / 3.0, y: self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height * 2.0 / 3.0, width: self.profileImageLabel.frame.size.width * 2.0 / 4.0, height: self.profileImageLabel.frame.size.height * 2.0 / 4.0))
            let imageURL = URL(string: self.tweetModel.retweetedProfileImage!)
            self.retweetedProfileImageLabel?.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "Warning"))
            // 角丸にする
            self.retweetedProfileImageLabel?.layer.cornerRadius = 6.0
            self.retweetedProfileImageLabel?.layer.masksToBounds = true
            self.retweetedProfileImageLabel?.layer.borderWidth = 0.0
            self.blankView.addSubview(self.retweetedProfileImageLabel!)
        }

        self.userNameLabel = UIButton(frame: CGRect(x: self.cWindowSize.size.width * 0.05 + 70, y: self.cWindowSize.size.width * 0.03, width: self.cWindowSize.size.width * 0.9, height: 15))
        
        if (userDefault.object(forKey: "displayNameType") != nil && userDefault.integer(forKey: "displayNameType") == 2) {
            self.userNameLabel.setTitle("@" + self.tweetModel.screenName, for: UIControlState())
        } else {
            self.userNameLabel.setTitle(self.tweetModel.userName, for: UIControlState())
        }
        self.userNameLabel.setTitleColor(UIColor.black, for: UIControlState())
        self.userNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.BoldFont, size: 15)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.left
        self.userNameLabel.sizeToFit()
        self.userNameLabel.titleEdgeInsets = UIEdgeInsets.zero
        self.userNameLabel.addTarget(self, action: #selector(TweetDetailViewController.tappedUserProfile), for: UIControlEvents.touchDown)
        self.blankView.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UIButton(frame: CGRect(x: self.cWindowSize.size.width * 0.05 + 70, y: self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height - 10, width: self.cWindowSize.size.width * 0.9, height: 15))
        
        if (userDefault.object(forKey: "displayNameType") != nil && ( userDefault.integer(forKey: "displayNameType") == 2 || userDefault.integer(forKey: "displayNameType") == 3 )) {
        } else {
            self.screenNameLabel.setTitle("@" + self.tweetModel.screenName, for: UIControlState())
        }
        self.screenNameLabel.setTitleColor(UIColor.gray, for: UIControlState())
        self.screenNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsets.zero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.addTarget(self, action: #selector(TweetDetailViewController.tappedUserProfile), for: UIControlEvents.touchDown)
        self.blankView.addSubview(self.screenNameLabel)
        
        
        
        
        self.tweetBodyLabel = UITextView(frame: CGRect(x: self.cWindowSize.size.width * 0.05, y: self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + TweetDetailViewController.LabelPadding + 5, width: self.cWindowSize.size.width * 0.9, height: 15))
        self.tweetBodyLabel.attributedText = self.tweetModel.customAttributedString()
        self.tweetBodyLabel.delegate = self
        self.tweetBodyLabel.dataDetectorTypes = [UIDataDetectorTypes.link, UIDataDetectorTypes.address]
        self.tweetBodyLabel.isEditable = false
        self.tweetBodyLabel.layoutManager.delegate = self
        self.tweetBodyLabel.isScrollEnabled = false
        self.tweetBodyLabel.sizeToFit()
        self.tweetBodyLabel.isUserInteractionEnabled = true
        self.blankView.addSubview(self.tweetBodyLabel)
        
        
        self.postDetailLabel = UILabel(frame: CGRect(x: self.cWindowSize.size.width * 0.05, y: self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height, width: self.cWindowSize.size.width * 0.9, height: 15))
        self.postDetailLabel.textAlignment = NSTextAlignment.right
        self.postDetailLabel.text = self.tweetModel.postDetail
        self.postDetailLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
        self.blankView.addSubview(self.postDetailLabel)
        
        if (self.tweetModel.retweetedName != nil) {
            self.retweetedNameLabel = UIButton(frame: CGRect(x: self.cWindowSize.size.width * 0.05, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + TweetDetailViewController.LabelPadding, width: self.cWindowSize.size.width * 0.9, height: 15))
            self.retweetedNameLabel?.setTitle("Retweeted by @" + self.tweetModel.retweetedName!, for: UIControlState())
            self.retweetedNameLabel?.setTitleColor(UIColor.gray, for: UIControlState())
            self.retweetedNameLabel?.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
            self.retweetedNameLabel?.contentEdgeInsets = UIEdgeInsets.zero
            self.retweetedNameLabel?.addTarget(self, action: #selector(TweetDetailViewController.tappedRetweetedProfile), for: UIControlEvents.touchDown)
            self.blankView.addSubview(self.retweetedNameLabel!)
        }
        

        
        if let cImportImage = UIImage(named: "Import-Line") {
            self.ts_imageWithSize(cImportImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aImportImage) -> Void in
                self.replyButton = UIButton(frame: CGRect(x: 0, y: 100, width: aImportImage.size.width, height: aImportImage.size.height))
                self.replyButton.setBackgroundImage(aImportImage, for: UIControlState())
                self.replyButton.center = CGPoint(x: self.cWindowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.replyButton.addTarget(self, action: #selector(TweetDetailViewController.tappedReply), for: UIControlEvents.touchDown)
                self.blankView.addSubview(self.replyButton)
            }
        }
        
        if let cConversationImage = UIImage(named: "Conversation-Line") {
            self.ts_imageWithSize(cConversationImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aConversationImage) -> Void in
                self.conversationButton = UIButton(frame: CGRect(x: 0, y: 100, width: aConversationImage.size.width, height: aConversationImage.size.height))
                self.conversationButton.setBackgroundImage(aConversationImage, for: UIControlState())
                self.conversationButton.center = CGPoint(x: self.cWindowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.conversationButton.addTarget(self, action: #selector(TweetDetailViewController.tappedConversation), for: .touchDown)
                self.blankView.addSubview(self.conversationButton)
            }
        }
        var starImage: UIImage?
        if (self.tweetModel.fFavorited == true) {
            starImage = UIImage(named: "Star-Filled")
        } else {
            starImage = UIImage(named: "Star-Line")
        }
        if starImage != nil {
            self.ts_imageWithSize(starImage!, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aStarImage) -> Void in
                self.favButton = UIButton(frame: CGRect(x: 0, y: 100, width: aStarImage.size.width, height: aStarImage.size.height))
                self.favButton.setBackgroundImage(aStarImage, for: UIControlState())
                self.favButton.center = CGPoint(x: self.cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.favButton.addTarget(self, action: #selector(TweetDetailViewController.tappedFavorite), for: .touchDown)
                self.blankView.addSubview(self.favButton)
            }
        }
        
        let cUsername = userDefault.string(forKey: "username")
        
        if (cUsername == self.tweetModel.screenName) {
            if let cTrashImage = UIImage(named: "Trash-Line") {
                self.ts_imageWithSize(cTrashImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight, callback: { (aTrashImage) -> Void in
                    self.deleteButton = UIButton(frame: CGRect(x: 0, y: 100, width: aTrashImage.size.width, height: aTrashImage.size.height))
                    self.deleteButton.setBackgroundImage(aTrashImage, for: UIControlState())
                    self.deleteButton.center = CGPoint(x: self.cWindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.deleteButton.addTarget(self, action: #selector(TweetDetailViewController.tappedDelete), for: .touchDown)
                    self.blankView.addSubview(self.deleteButton)
                })
            }
        } else {
            if let cMoreImage = UIImage(named: "More-Line") {
                self.ts_imageWithSize(cMoreImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight, callback: { (aMoreImage) -> Void in
                    self.moreButton = UIButton(frame: CGRect(x: 0, y: 100, width: aMoreImage.size.width, height: aMoreImage.size.height))
                    self.moreButton.setBackgroundImage(aMoreImage, for: UIControlState())
                    self.moreButton.center = CGPoint(x: self.cWindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.moreButton.addTarget(self, action: #selector(TweetDetailViewController.tappedMore), for: .touchDown)
                    self.blankView.addSubview(self.moreButton)
                })
            }
        }
        
        self.blankView.contentSize = CGSize(width: self.cWindowSize.width, height: self.favButton.frame.origin.y + self.favButton.frame.size.height + 20)
        
        
        // 画像があった場合の処理
        if (self.tweetModel.media != nil) {
            var startPosY = self.favButton.frame.origin.y + self.favButton.frame.size.height + 20.0
            self.innerMediaButton = []
            for (index, mediaURL) in (self.tweetModel.media!).enumerated() {
                let eachMediaButton = UIButton(frame: CGRect(x: self.cWindowSize.size.width * 0.05, y: startPosY, width: self.cWindowSize.size.width * 0.9, height: 100))
                self.innerMediaButton!.append(eachMediaButton)
                let imageURL = URL(string: mediaURL)

                let loadingImage: UIImage! = UIImage(named: "Loading")
                
                // SDWebImageにより読み込むのでクロージャで位置を再調節
                eachMediaButton.sd_setBackgroundImage(with: imageURL, for: UIControlState(), placeholderImage: loadingImage, options: .cacheMemoryOnly, completed: { (image, error, cacheType, url) in

                    var fixStartPosY = self.favButton.frame.origin.y + self.favButton.frame.size.height + 20.0
                    for mediaButton in self.innerMediaButton! {
                        // 表示画像のリサイズ
                        mediaButton.sizeToFit()
                        if (mediaButton.frame.size.width > self.cWindowSize.size.width * 0.9){
                            let scale = (self.cWindowSize.size.width * 0.9) / mediaButton.frame.size.width
                            mediaButton.frame.size = CGSize(width: self.cWindowSize.size.width * 0.9, height: mediaButton.frame.size.height * scale)
                        }
                        mediaButton.frame.origin.y = fixStartPosY
                        fixStartPosY += mediaButton.frame.size.height + 10.0
                        
                        // スクロール用に全体サイズも調節
                        self.blankView.contentSize = CGSize(width: self.cWindowSize.width, height: mediaButton.frame.origin.y + mediaButton.frame.size.height + 20)
                        mediaButton.tag = index
                    }
                    
                })
                eachMediaButton.addTarget(self, action: #selector(TweetDetailViewController.tappedMedia(_:)), for: UIControlEvents.touchUpInside)
                startPosY += eachMediaButton.frame.size.height
                self.blankView.addSubview(eachMediaButton)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ts_imageWithSize(_ image: UIImage, width: CGFloat, height: CGFloat, callback: (UIImage)->Void) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0);
        let context = UIGraphicsGetCurrentContext()! as CGContext
        UIGraphicsPushContext(context)
        
        let origin = CGPoint(x: (width - image.size.width) / 2.0, y: (height - image.size.height) / 2.0)
        image.draw(at: origin)
        
        UIGraphicsPopContext()
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        callback(resizedImage!)
    }
    
    // UITextViewの行間
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 3;
    }
    
    @objc func tappedReply() {
        let userDefault = UserDefaults.standard
        if let userScreenName = userDefault.object(forKey: "username") as? String {
            let newTweetView = NewTweetViewController(
                aTweetBody: self.tweetModel.replyList(userScreenName),
                aReplyToID: self.tweetModel.tweetID,
                aTopCursor: nil
            )
            self.navigationController!.pushViewController(newTweetView, animated: true)
        }
    }
    
    @objc func tappedConversation() {
        let conversationView = ConversationTableViewController(aTweetID: self.tweetModel.tweetID)
        self.navigationController?.pushViewController(conversationView, animated: true)
    }
    
    //-------------------------------------------------
    //  memo: favDeleteアクションもここで実装
    //-------------------------------------------------
    @objc func tappedFavorite() {
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        self.tweetModel.favoriteTweet({ () -> Void in
            SVProgressHUD.dismiss()
            let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("AddFav",  tableName: "TweetDetail",comment: ""))
            notice?.alpha = 0.8
            notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
            notice?.show()
            // アイコンの挿げ替え
            self.tweetModel.fFavorited = true
            if let cStarImage = UIImage(named: "Star-Filled") {
                self.ts_imageWithSize(cStarImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aStarImage) -> Void in
                    self.favButton.removeFromSuperview()
                    self.favButton = UIButton(frame: CGRect(x: 0, y: 100, width: aStarImage.size.width, height: aStarImage.size.height))
                    self.favButton.setBackgroundImage(aStarImage, for: UIControlState())
                    self.favButton.center = CGPoint(x: self.self.cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.favButton.addTarget(self, action: #selector(TweetDetailViewController.tappedFavorite), for: .touchDown)
                    self.blankView.addSubview(self.favButton)
                }
            }
            // 親要素のツイート情報を書き換え
            if self.timelineModel != nil && self.parentIndex != nil {
                self.timelineModel!.addFavorite(self.parentIndex!)
            }
        }, unfavorited: { () -> Void in
            SVProgressHUD.dismiss()
            let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("DeleteFav",  tableName: "TweetDetail",comment: ""))
            notice?.alpha = 0.8
            notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
            notice?.show()
            // アイコンの挿げ替え
            if let cStarImage = UIImage(named: "Star-Line") {
                self.ts_imageWithSize(cStarImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aStarImage) -> Void in
                    self.favButton.removeFromSuperview()
                    self.favButton = UIButton(frame: CGRect(x: 0, y: 100, width: aStarImage.size.width, height: aStarImage.size.height))
                    self.favButton.setBackgroundImage(aStarImage, for: UIControlState())
                    self.favButton.center = CGPoint(x: self.self.cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.favButton.addTarget(self, action: #selector(TweetDetailViewController.tappedFavorite), for: .touchDown)
                    self.blankView.addSubview(self.favButton)
                }
            }
            if self.timelineModel != nil && self.parentIndex != nil {
                self.timelineModel!.deleteFavorite(self.parentIndex!)
            }
        })
    }

    @objc func tappedDelete() {
        let alertController = UIAlertController(title: NSLocalizedString("TweetDeleteTitle",  tableName: "TweetDetail",comment: ""), message: NSLocalizedString("TweetDeleteMessage",  tableName: "TweetDetail",comment: ""), preferredStyle: .alert)
        let cOkAction = UIAlertAction(title: NSLocalizedString("TweetDeleteOK",  tableName: "TweetDetail",comment: ""), style: .default, handler: {action in
            SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
            self.tweetModel.deleteTweet({ () -> Void in
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("TweetDeleteComplete",  tableName: "TweetDetail",comment: ""))
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
                _ = self.navigationController?.popViewController(animated: true)
            })
        })
        let cCancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {action in
        })
        alertController.addAction(cCancelAction)
        alertController.addAction(cOkAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func tappedMore() {
        let retweetSelectSheet = UIAlertController(title: NSLocalizedString("RTTitle",  tableName: "TweetDetail",comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let oficialRetweetAction = UIAlertAction(title: NSLocalizedString("RTOfficial",  tableName: "TweetDetail",comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            if (self.tweetModel.fProtected == true) {
                let protectedAlert = UIAlertController(title: NSLocalizedString("RTError",  tableName: "TweetDetail",comment: ""), message: NSLocalizedString("RTPrivate",  tableName: "TweetDetail",comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                protectedAlert.addAction(okAction)
                self.present(protectedAlert, animated: true, completion: nil)
            } else {
                // 公式RTの処理．直接POSTしちゃって構わない
                let alertController = UIAlertController(title: NSLocalizedString("RTOfficial",  tableName: "TweetDetail",comment: ""), message: NSLocalizedString("RTConfirm",  tableName: "TweetDetail",comment: ""), preferredStyle: .alert)
                let cOkAction = UIAlertAction(title: NSLocalizedString("RTPost",  tableName: "TweetDetail",comment: ""), style: .default, handler: {action in
                    SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
                    self.tweetModel.retweetTweet({ () -> Void in
                        SVProgressHUD.dismiss()
                        let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: NSLocalizedString("RTComplete",  tableName: "TweetDetail",comment: ""))
                        notice?.alpha = 0.8
                        notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                        notice?.show()
                    })
                })
                let cCancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {action in
                })
                alertController.addAction(cCancelAction)
                alertController.addAction(cOkAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        let unoficialRetweetAction = UIAlertAction(title: NSLocalizedString("RTUnofficial",  tableName: "TweetDetail",comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            if (self.tweetModel.fProtected == true) {
                let protectedAlert = UIAlertController(title: NSLocalizedString("RTError",  tableName: "TweetDetail",comment: ""), message: NSLocalizedString("RTPrivate",  tableName: "TweetDetail",comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                protectedAlert.addAction(okAction)
                self.present(protectedAlert, animated: true, completion: nil)
            } else {
                let retweetView = NewTweetViewController(aTweetBody: "RT @" + self.tweetModel.screenName + " " + self.tweetModel.tweetBody!, aReplyToID: self.tweetModel.tweetID, aTopCursor: true)
                self.navigationController?.pushViewController(retweetView, animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        retweetSelectSheet.addAction(oficialRetweetAction)
        retweetSelectSheet.addAction(unoficialRetweetAction)
        retweetSelectSheet.addAction(cancelAction)
        self.present(retweetSelectSheet, animated: true, completion: nil)
        
    }
    
    @objc func tappedNewTweet(_ sender: AnyObject) {
        let newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    @objc func tappedUserProfile() {
        let userProfileView = ProfileViewController(aScreenName: self.tweetModel.screenName)
        self.navigationController?.pushViewController(userProfileView, animated: true)
    }
    
    @objc func tappedRetweetedProfile() {
        let userProfileView = ProfileViewController(aScreenName: self.tweetModel.retweetedName!)
        self.navigationController?.pushViewController(userProfileView, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.scheme!.hasPrefix("at") == true) {
            let userView = ProfileViewController(aScreenName: URL.absoluteString.replacingOccurrences(of: "at:@", with: "", options: [], range: nil))
            self.navigationController?.pushViewController(userView, animated: true)
            return false
        } else if (URL.scheme!.hasPrefix("tag") == true) {
            let decodedURLString = URL.absoluteString.removingPercentEncoding
            let searchView = SearchAddListTableViewController(aStreamList: StreamList(), keyword: decodedURLString!.replacingOccurrences(of: "tag:#", with: "#", options: [], range: nil))
            self.navigationController?.pushViewController(searchView, animated: true)
            return false
        } else {
            UIApplication.shared.openURL(URL)
            return false
        }
    }
    
    // 画像が押された時
    @objc func tappedMedia(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            let mediaImage = button.backgroundImage(for: UIControlState())
            let index = button.tag
            var mediaView: MediaViewController!
            if let url = self.tweetModel.video?[index] {
                if url.characters.count > 0 {
                    mediaView = MediaViewController(aGifImageURL: URL(string: url)!)
                } else {
                    mediaView = MediaViewController(aMediaImage: mediaImage)                    
                }
            } else {
                mediaView = MediaViewController(aMediaImage: mediaImage)
            }
            let mediaNavigation = UINavigationController(rootViewController: mediaView)
            self.present(mediaNavigation, animated: true, completion: nil)
        }
    }
}
