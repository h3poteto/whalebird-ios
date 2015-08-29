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
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(aTweetModel: TweetModel!, aTimelineModel: TimelineModel?, aParentIndex: Int?) {
        self.init()
        self.tweetModel = aTweetModel
        self.timelineModel = aTimelineModel
        self.parentIndex = aParentIndex
        self.title = "詳細"
    }
    
    override func loadView() {
        super.loadView()
        self.blankView = UIScrollView(frame: self.view.bounds)
        self.blankView.backgroundColor = UIColor.whiteColor()
        self.blankView.scrollEnabled = true
        self.view.addSubview(self.blankView)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton
        
        self.cWindowSize = UIScreen.mainScreen().bounds
        var userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImageLabel = UIButton(frame: CGRectMake(self.cWindowSize.size.width * 0.05, self.cWindowSize.size.width * 0.05, self.cWindowSize.size.width * 0.9, 40))
        var imageURL = NSURL(string: self.tweetModel.profileImage)
        self.profileImageLabel.sd_setBackgroundImageWithURL(imageURL, forState: UIControlState.Normal, placeholderImage: UIImage(named: "noimage"))
        self.profileImageLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.profileImageLabel.sizeToFit()
        
        self.blankView.addSubview(self.profileImageLabel)
        
        if (self.tweetModel.retweetedProfileImage != nil) {
            self.retweetedProfileImageLabel = UIImageView(frame: CGRectMake(self.profileImageLabel.frame.origin.x + self.profileImageLabel.frame.size.width * 2.0 / 3.0, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height * 2.0 / 3.0, self.profileImageLabel.frame.size.width * 2.0 / 4.0, self.profileImageLabel.frame.size.height * 2.0 / 4.0))
            var imageURL = NSURL(string: self.tweetModel.retweetedProfileImage!)
            self.retweetedProfileImageLabel!.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "Warning"))
            self.blankView.addSubview(self.retweetedProfileImageLabel!)
        }

        self.userNameLabel = UIButton(frame: CGRectMake(self.cWindowSize.size.width * 0.05 + 70, self.cWindowSize.size.width * 0.03, self.cWindowSize.size.width * 0.9, 15))
        
        if (userDefault.objectForKey("displayNameType") != nil && userDefault.integerForKey("displayNameType") == 2) {
            self.userNameLabel.setTitle("@" + self.tweetModel.screenName, forState: UIControlState.Normal)
        } else {
            self.userNameLabel.setTitle(self.tweetModel.userName, forState: .Normal)
        }
        self.userNameLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.userNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.BoldFont, size: 15)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.userNameLabel.sizeToFit()
        self.userNameLabel.titleEdgeInsets = UIEdgeInsetsZero
        self.userNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.blankView.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UIButton(frame: CGRectMake(self.cWindowSize.size.width * 0.05 + 70, self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height - 10, self.cWindowSize.size.width * 0.9, 15))
        
        if (userDefault.objectForKey("displayNameType") != nil && ( userDefault.integerForKey("displayNameType") == 2 || userDefault.integerForKey("displayNameType") == 3 )) {
        } else {
            self.screenNameLabel.setTitle("@" + self.tweetModel.screenName, forState: UIControlState.Normal)
        }
        self.screenNameLabel.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.screenNameLabel.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 15)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsetsZero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        self.blankView.addSubview(self.screenNameLabel)
        
        
        
        
        self.tweetBodyLabel = UITextView(frame: CGRectMake(self.cWindowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + TweetDetailViewController.LabelPadding + 5, self.cWindowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.attributedText = self.tweetModel.customAttributedString()
        self.tweetBodyLabel.delegate = self
        self.tweetBodyLabel.dataDetectorTypes = UIDataDetectorTypes.Link | UIDataDetectorTypes.Address
        self.tweetBodyLabel.editable = false
        self.tweetBodyLabel.layoutManager.delegate = self
        self.tweetBodyLabel.scrollEnabled = false
        self.tweetBodyLabel.sizeToFit()
        self.tweetBodyLabel.userInteractionEnabled = true
        self.blankView.addSubview(self.tweetBodyLabel)
        
        
        self.postDetailLabel = UILabel(frame: CGRectMake(self.cWindowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height, self.cWindowSize.size.width * 0.9, 15))
        self.postDetailLabel.textAlignment = NSTextAlignment.Right
        self.postDetailLabel.text = self.tweetModel.postDetail
        self.postDetailLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
        self.blankView.addSubview(self.postDetailLabel)
        
        if (self.tweetModel.retweetedName != nil) {
            self.retweetedNameLabel = UIButton(frame: CGRectMake(self.cWindowSize.size.width * 0.05, self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + TweetDetailViewController.LabelPadding, self.cWindowSize.size.width * 0.9, 15))
            self.retweetedNameLabel?.setTitle("Retweeted by @" + self.tweetModel.retweetedName!, forState: UIControlState.Normal)
            self.retweetedNameLabel?.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            self.retweetedNameLabel?.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
            self.retweetedNameLabel?.contentEdgeInsets = UIEdgeInsetsZero
            self.retweetedNameLabel?.addTarget(self, action: "tappedRetweetedProfile", forControlEvents: UIControlEvents.TouchDown)
            self.blankView.addSubview(self.retweetedNameLabel!)
        }
        

        
        if let cImportImage = UIImage(named: "Import-Line") {
            self.ts_imageWithSize(cImportImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aImportImage) -> Void in
                self.replyButton = UIButton(frame: CGRectMake(0, 100, aImportImage.size.width, aImportImage.size.height))
                self.replyButton.setBackgroundImage(aImportImage, forState: .Normal)
                self.replyButton.center = CGPoint(x: self.cWindowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.replyButton.addTarget(self, action: "tappedReply", forControlEvents: UIControlEvents.TouchDown)
                self.blankView.addSubview(self.replyButton)
            }
        }
        
        if let cConversationImage = UIImage(named: "Conversation-Line") {
            self.ts_imageWithSize(cConversationImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aConversationImage) -> Void in
                self.conversationButton = UIButton(frame: CGRectMake(0, 100, aConversationImage.size.width, aConversationImage.size.height))
                self.conversationButton.setBackgroundImage(aConversationImage, forState: .Normal)
                self.conversationButton.center = CGPoint(x: self.cWindowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.conversationButton.addTarget(self, action: "tappedConversation", forControlEvents: .TouchDown)
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
                self.favButton = UIButton(frame: CGRectMake(0, 100, aStarImage.size.width, aStarImage.size.height))
                self.favButton.setBackgroundImage(aStarImage, forState: .Normal)
                self.favButton.center = CGPoint(x: self.cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
                self.blankView.addSubview(self.favButton)
            }
        }
        
        let cUsername = userDefault.stringForKey("username")
        
        if (cUsername == self.tweetModel.screenName) {
            if let cTrashImage = UIImage(named: "Trash-Line") {
                self.ts_imageWithSize(cTrashImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight, callback: { (aTrashImage) -> Void in
                    self.deleteButton = UIButton(frame: CGRectMake(0, 100, aTrashImage.size.width, aTrashImage.size.height))
                    self.deleteButton.setBackgroundImage(aTrashImage, forState: .Normal)
                    self.deleteButton.center = CGPoint(x: self.cWindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.deleteButton.addTarget(self, action: "tappedDelete", forControlEvents: .TouchDown)
                    self.blankView.addSubview(self.deleteButton)
                })
            }
        } else {
            if var cMoreImage = UIImage(named: "More-Line") {
                self.ts_imageWithSize(cMoreImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight, callback: { (aMoreImage) -> Void in
                    self.moreButton = UIButton(frame: CGRectMake(0, 100, aMoreImage.size.width, aMoreImage.size.height))
                    self.moreButton.setBackgroundImage(aMoreImage, forState: .Normal)
                    self.moreButton.center = CGPoint(x: self.cWindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.moreButton.addTarget(self, action: "tappedMore", forControlEvents: .TouchDown)
                    self.blankView.addSubview(self.moreButton)
                })
            }
        }
        
        self.blankView.contentSize = CGSizeMake(self.cWindowSize.width, self.favButton.frame.origin.y + self.favButton.frame.size.height + 20)
        
        
        // 画像があった場合の処理
        if (self.tweetModel.media != nil) {
            var startPosY = self.favButton.frame.origin.y + self.favButton.frame.size.height + 20.0
            self.innerMediaButton = []
            for (index, mediaURL) in enumerate(self.tweetModel.media!) {
                var eachMediaButton = UIButton(frame: CGRectMake(self.cWindowSize.size.width * 0.05, startPosY, self.cWindowSize.size.width * 0.9, 100))
                self.innerMediaButton!.append(eachMediaButton)
                var imageURL = NSURL(string: mediaURL)
                
                // SDWebImageにより読み込むのでクロージャで位置を再調節
                eachMediaButton.sd_setBackgroundImageWithURL(imageURL, forState: UIControlState.Normal, completed: { (image, error, cacheType, url) -> Void in

                    var fixStartPosY = self.favButton.frame.origin.y + self.favButton.frame.size.height + 20.0
                    for mediaButton in self.innerMediaButton! {
                        // 表示画像のリサイズ
                        mediaButton.sizeToFit()
                        if (mediaButton.frame.size.width > self.cWindowSize.size.width * 0.9){
                            var scale = (self.cWindowSize.size.width * 0.9) / mediaButton.frame.size.width
                            mediaButton.frame.size = CGSizeMake(self.cWindowSize.size.width * 0.9, mediaButton.frame.size.height * scale)
                        }
                        mediaButton.frame.origin.y = fixStartPosY
                        fixStartPosY += mediaButton.frame.size.height + 10.0
                        
                        // スクロール用に全体サイズも調節
                        self.blankView.contentSize = CGSizeMake(self.cWindowSize.width, mediaButton.frame.origin.y + mediaButton.frame.size.height + 20)
                        mediaButton.tag = index
                    }
                    
                })
                eachMediaButton.addTarget(self, action: "tappedMedia:", forControlEvents: UIControlEvents.TouchUpInside)
                startPosY += eachMediaButton.frame.size.height
                self.blankView.addSubview(eachMediaButton)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ts_imageWithSize(image: UIImage, width: CGFloat, height: CGFloat, callback: (UIImage)->Void) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 0.0);
        var context = UIGraphicsGetCurrentContext() as CGContextRef
        UIGraphicsPushContext(context)
        
        let origin = CGPointMake((width - image.size.width) / 2.0, (height - image.size.height) / 2.0)
        image.drawAtPoint(origin)
        
        UIGraphicsPopContext()
        var resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        callback(resizedImage)
    }
    
    // UITextViewの行間
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 3;
    }
    
    func tappedReply() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        if let userScreenName = userDefault.objectForKey("username") as? String {
            var newTweetView = NewTweetViewController(
                aTweetBody: self.tweetModel.replyList(userScreenName),
                aReplyToID: self.tweetModel.tweetID,
                aTopCursor: nil
            )
            self.navigationController!.pushViewController(newTweetView, animated: true)
        }
    }
    
    func tappedConversation() {
        var conversationView = ConversationTableViewController(aTweetID: self.tweetModel.tweetID)
        self.navigationController?.pushViewController(conversationView, animated: true)
    }
    
    //-------------------------------------------------
    //  memo: favDeleteアクションもここで実装
    //-------------------------------------------------
    func tappedFavorite() {
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.tweetModel.favoriteTweet({ () -> Void in
            SVProgressHUD.dismiss()
            var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "お気に入り追加")
            notice.alpha = 0.8
            notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
            notice.show()
            // アイコンの挿げ替え
            self.tweetModel.fFavorited = true
            if let cStarImage = UIImage(named: "Star-Filled") {
                self.ts_imageWithSize(cStarImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aStarImage) -> Void in
                    self.favButton.removeFromSuperview()
                    self.favButton = UIButton(frame: CGRectMake(0, 100, aStarImage.size.width, aStarImage.size.height))
                    self.favButton.setBackgroundImage(aStarImage, forState: .Normal)
                    self.favButton.center = CGPoint(x: self.self.cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
                    self.blankView.addSubview(self.favButton)
                }
            }
            // 親要素のツイート情報を書き換え
            if self.timelineModel != nil && self.parentIndex != nil {
                self.timelineModel!.addFavorite(self.parentIndex!)
            }
        }, unfavorited: { () -> Void in
            SVProgressHUD.dismiss()
            var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "お気に入り削除")
            notice.alpha = 0.8
            notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
            notice.show()
            // アイコンの挿げ替え
            if let cStarImage = UIImage(named: "Star-Line") {
                self.ts_imageWithSize(cStarImage, width: TweetDetailViewController.ActionButtonWidth, height: TweetDetailViewController.ActionButtonHeight) { (aStarImage) -> Void in
                    self.favButton.removeFromSuperview()
                    self.favButton = UIButton(frame: CGRectMake(0, 100, aStarImage.size.width, aStarImage.size.height))
                    self.favButton.setBackgroundImage(aStarImage, forState: .Normal)
                    self.favButton.center = CGPoint(x: self.self.cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                    self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
                    self.blankView.addSubview(self.favButton)
                }
            }
            if self.timelineModel != nil && self.parentIndex != nil {
                self.timelineModel!.deleteFavorite(self.parentIndex!)
            }
        })
    }

    func tappedDelete() {
        var alertController = UIAlertController(title: "ツイート削除", message: "本当に削除しますか？", preferredStyle: .Alert)
        let cOkAction = UIAlertAction(title: "削除する", style: .Default, handler: {action in
            SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
            self.tweetModel.deleteTweet({ () -> Void in
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "削除完了")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        })
        let cCancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {action in
            println("Cancel")
        })
        alertController.addAction(cCancelAction)
        alertController.addAction(cOkAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func tappedMore() {
        var retweetSelectSheet = UIAlertController(title: "Retweet", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oficialRetweetAction = UIAlertAction(title: "公式RT", style: UIAlertActionStyle.Default) { (action) -> Void in
            if (self.tweetModel.fProtected == true) {
                var protectedAlert = UIAlertController(title: "RTできません", message: "非公開アカウントです", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    return true
                })
                protectedAlert.addAction(okAction)
                self.presentViewController(protectedAlert, animated: true, completion: nil)
            } else {
                // 公式RTの処理．直接POSTしちゃって構わない
                var alertController = UIAlertController(title: "公式RT", message: "RTしますか？", preferredStyle: .Alert)
                let cOkAction = UIAlertAction(title: "RTする", style: .Default, handler: {action in
                    SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
                    self.tweetModel.retweetTweet({ () -> Void in
                        SVProgressHUD.dismiss()
                        var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "RTしました")
                        notice.alpha = 0.8
                        notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                        notice.show()
                    })
                })
                let cCancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {action in
                    println("Cancel")
                })
                alertController.addAction(cCancelAction)
                alertController.addAction(cOkAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        let unoficialRetweetAction = UIAlertAction(title: "非公式RT", style: UIAlertActionStyle.Default) { (action) -> Void in
            if (self.tweetModel.fProtected == true) {
                var protectedAlert = UIAlertController(title: "RTできません", message: "非公開アカウントです", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    return true
                })
                protectedAlert.addAction(okAction)
                self.presentViewController(protectedAlert, animated: true, completion: nil)
            } else {
                var retweetView = NewTweetViewController(aTweetBody: "RT @" + self.tweetModel.screenName + " " + self.tweetModel.tweetBody!, aReplyToID: self.tweetModel.tweetID, aTopCursor: true)
                self.navigationController?.pushViewController(retweetView, animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        retweetSelectSheet.addAction(oficialRetweetAction)
        retweetSelectSheet.addAction(unoficialRetweetAction)
        retweetSelectSheet.addAction(cancelAction)
        self.presentViewController(retweetSelectSheet, animated: true, completion: nil)
        
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    func tappedUserProfile() {
        var userProfileView = ProfileViewController(aScreenName: self.tweetModel.screenName)
        self.navigationController?.pushViewController(userProfileView, animated: true)
    }
    
    func tappedRetweetedProfile() {
        var userProfileView = ProfileViewController(aScreenName: self.tweetModel.retweetedName!)
        self.navigationController?.pushViewController(userProfileView, animated: true)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if (URL.scheme?.hasPrefix("at") == true) {
            var userView = ProfileViewController(aScreenName: URL.absoluteString!.stringByReplacingOccurrencesOfString("at:@", withString: "", options: nil, range: nil))
            self.navigationController?.pushViewController(userView, animated: true)
            return false
        } else if (URL.scheme?.hasPrefix("tag") == true) {
            var searchView = SearchTableViewController(aStreamList: StreamList(), keyword: URL.absoluteString!.stringByReplacingOccurrencesOfString("tag:%23", withString: "#", options: nil, range: nil))
            self.navigationController?.pushViewController(searchView, animated: true)
            return false
        } else {
            UIApplication.sharedApplication().openURL(URL)
            return false
        }
    }
    
    // 画像が押された時
    func tappedMedia(sender: AnyObject) {
        if var button = sender as? UIButton {
            let mediaImage = button.backgroundImageForState(UIControlState.Normal)
            let index = button.tag
            var mediaView: MediaViewController!
            if let url = self.tweetModel.video?[index] {
                if count(url) > 0 {
                    mediaView = MediaViewController(aGifImageURL: NSURL(string: url)!)
                } else {
                    mediaView = MediaViewController(aMediaImage: mediaImage)                    
                }
            } else {
                mediaView = MediaViewController(aMediaImage: mediaImage)
            }
            var mediaNavigation = UINavigationController(rootViewController: mediaView)
            self.presentViewController(mediaNavigation, animated: true, completion: nil)
        }
    }
}
