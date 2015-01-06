//
//  TweetDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/02.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController, UIActionSheetDelegate, UITextViewDelegate, NSLayoutManagerDelegate {
    let LabelPadding = CGFloat(10)
    
    //=====================================
    //  instance variables
    //=====================================
    var tweetID: String!
    var tweetBody: String?
    var screenName: String!
    var userName: String!
    var postDetail: String!
    var profileImage: String!
    var retweetedName: String?
    var retweetedProfileImage: String?
    
    var blankView: UIScrollView!
    var screenNameLabel: UIButton!
    var userNameLabel: UIButton!
    var tweetBodyLabel: UITextView!
    var postDetailLabel: UILabel!
    var profileImageLabel: UIImageView!
    var retweetedNameLabel: UIButton?
    var retweetedProfileImageLabel: UIImageView?
    
    var replyButton: UIButton!
    var conversationButton: UIButton!
    var favButton: UIButton!
    var deleteButton: UIButton!
    var moreButton: UIButton!
    
    
    var newTweetButton: UIBarButtonItem!
    
    //=====================================
    //  instance method
    //=====================================
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    init(aTweetID: String, aTweetBody: String, aScreenName: String, aUserName: String, aProfileImage: String, aPostDetail: String, aRetweetedName: String?, aRetweetedProfileImage: String?) {
        super.init()
        self.tweetID = aTweetID
        self.tweetBody = aTweetBody
        self.screenName = aScreenName
        self.postDetail = WhalebirdAPIClient.convertLocalTime(aPostDetail)
        self.profileImage = aProfileImage
        self.userName = aUserName
        self.retweetedName = aRetweetedName
        self.retweetedProfileImage = aRetweetedProfileImage

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
        
        let cWindowSize = UIScreen.mainScreen().bounds
        var userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(cWindowSize.size.width * 0.05, cWindowSize.size.width * 0.05, cWindowSize.size.width * 0.9, 40))
        var imageURL = NSURL(string: self.profileImage)
        self.profileImageLabel.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "noimage.png"))
        self.profileImageLabel.sizeToFit()
        
        self.blankView.addSubview(self.profileImageLabel)
        
        if (self.retweetedProfileImage != nil) {
            self.retweetedProfileImageLabel = UIImageView(frame: CGRectMake(self.profileImageLabel.frame.origin.x + self.profileImageLabel.frame.size.width * 2.0 / 3.0, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height * 2.0 / 3.0, self.profileImageLabel.frame.size.width * 2.0 / 4.0, self.profileImageLabel.frame.size.height * 2.0 / 4.0))
            var imageURL = NSURL(string: self.retweetedProfileImage!)
            self.retweetedProfileImageLabel!.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "Warning.png"))
            self.blankView.addSubview(self.retweetedProfileImageLabel!)
        }

        self.userNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05 + 70, cWindowSize.size.width * 0.05, cWindowSize.size.width * 0.9, 15))
        
        if (userDefault.objectForKey("displayNameType") != nil && userDefault.integerForKey("displayNameType") == 2) {
            self.userNameLabel.setTitle("@" + self.screenName, forState: UIControlState.Normal)
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
        self.blankView.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05 + 70, cWindowSize.size.width * 0.05 + self.userNameLabel.frame.size.height + 5, cWindowSize.size.width * 0.9, 15))
        
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
        self.blankView.addSubview(self.screenNameLabel)
        
        // string
        var escapedTweetBody = WhalebirdAPIClient.escapeString(self.tweetBody!)
        var screenNameList: Array<String> = []
        var tScreenName = ""
        var fReply = false
        for char in self.tweetBody! {
            if (fReply) {
                if (char == " " || char == "　" || !self.checkScreenName(char)) {
                    screenNameList.append(tScreenName)
                    tScreenName = ""
                    fReply = false
                } else {
                    tScreenName.append(char)
                }
            }else if (char == "@") {
                tScreenName.append(char)
                fReply = true
            }
        }
        var attributedString = NSMutableAttributedString(string: escapedTweetBody, attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
        attributedString.setFont(UIFont(name: TimelineViewCell.NormalFont, size: 15))
        for screen in screenNameList {
            var nameRange: NSRange = (escapedTweetBody as NSString).rangeOfString(screen)
            attributedString.addAttributes([NSLinkAttributeName: "at:" + screen], range: nameRange)
        }
        
        
        self.tweetBodyLabel = UITextView(frame: CGRectMake(cWindowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + self.LabelPadding + 5, cWindowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.attributedText = attributedString
        self.tweetBodyLabel.delegate = self
        self.tweetBodyLabel.dataDetectorTypes = UIDataDetectorTypes.Link | UIDataDetectorTypes.Address
        self.tweetBodyLabel.editable = false
        self.tweetBodyLabel.layoutManager.delegate = self
        self.tweetBodyLabel.scrollEnabled = false
        self.tweetBodyLabel.sizeToFit()
        self.tweetBodyLabel.userInteractionEnabled = true
        self.blankView.addSubview(self.tweetBodyLabel)
        
        
        self.postDetailLabel = UILabel(frame: CGRectMake(cWindowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height, cWindowSize.size.width * 0.9, 15))
        self.postDetailLabel.textAlignment = NSTextAlignment.Right
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
        self.blankView.addSubview(self.postDetailLabel)
        
        if (self.retweetedName != nil) {
            self.retweetedNameLabel = UIButton(frame: CGRectMake(cWindowSize.size.width * 0.05, self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.LabelPadding, cWindowSize.size.width * 0.9, 15))
            self.retweetedNameLabel?.setTitle("Retweeted by @" + self.retweetedName!, forState: UIControlState.Normal)
            self.retweetedNameLabel?.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            self.retweetedNameLabel?.titleLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
            self.retweetedNameLabel?.contentEdgeInsets = UIEdgeInsetsZero
            self.retweetedNameLabel?.addTarget(self, action: "tappedRetweetedProfile", forControlEvents: UIControlEvents.TouchDown)
            self.blankView.addSubview(self.retweetedNameLabel!)
        }
        
        
        // そのまま表示するとボタン領域が小さくてタップしにくいので拡大
        let actionButtonWidth = CGFloat(50)
        let actionButtonHeight = CGFloat(40)

        
        let cImportImage = UIImage(named: "Import-Line.png")
        self.ts_imageWithSize(cImportImage!, width: actionButtonWidth, height: actionButtonHeight) { (aImportImage) -> Void in
            self.replyButton = UIButton(frame: CGRectMake(0, 100, aImportImage.size.width, aImportImage.size.height))
            self.replyButton.setBackgroundImage(aImportImage, forState: .Normal)
            self.replyButton.center = CGPoint(x: cWindowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
            self.replyButton.addTarget(self, action: "tappedReply", forControlEvents: UIControlEvents.TouchDown)
            self.blankView.addSubview(self.replyButton)
        }
        
        let cConversationImage = UIImage(named: "Conversation-Line.png")
        self.ts_imageWithSize(cConversationImage!, width: actionButtonWidth, height: actionButtonHeight) { (aConversationImage) -> Void in
            self.conversationButton = UIButton(frame: CGRectMake(0, 100, aConversationImage.size.width, aConversationImage.size.height))
            self.conversationButton.setBackgroundImage(aConversationImage, forState: .Normal)
            self.conversationButton.center = CGPoint(x: cWindowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
            self.conversationButton.addTarget(self, action: "tappedConversation", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.conversationButton)
        }
        
        let cStarImage = UIImage(named: "Star-Line.png")
        self.ts_imageWithSize(cStarImage!, width: actionButtonWidth, height: actionButtonHeight) { (aStarImage) -> Void in
            self.favButton = UIButton(frame: CGRectMake(0, 100, aStarImage.size.width, aStarImage.size.height))
            self.favButton.setBackgroundImage(aStarImage, forState: .Normal)
            self.favButton.center = CGPoint(x: cWindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
            self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.favButton)
        }
        
        let cUsername = userDefault.stringForKey("username")
        
        if (cUsername == self.screenName) {
            let cTrashImage = UIImage(named: "Trash-Line.png")
            self.ts_imageWithSize(cTrashImage!, width: actionButtonWidth, height: actionButtonHeight, callback: { (aTrashImage) -> Void in
                self.deleteButton = UIButton(frame: CGRectMake(0, 100, aTrashImage.size.width, aTrashImage.size.height))
                self.deleteButton.setBackgroundImage(aTrashImage, forState: .Normal)
                self.deleteButton.center = CGPoint(x: cWindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.deleteButton.addTarget(self, action: "tappedDelete", forControlEvents: .TouchDown)
                self.blankView.addSubview(self.deleteButton)
            })
        } else {
            var cMoreImage = UIImage(named: "More-Line.png")
            
            self.ts_imageWithSize(cMoreImage!, width: actionButtonWidth, height: actionButtonHeight, callback: { (aMoreImage) -> Void in
                self.moreButton = UIButton(frame: CGRectMake(0, 100, aMoreImage.size.width, aMoreImage.size.height))
                self.moreButton.setBackgroundImage(aMoreImage, forState: .Normal)
                self.moreButton.center = CGPoint(x: cWindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
                self.moreButton.addTarget(self, action: "tappedMore", forControlEvents: .TouchDown)
                self.blankView.addSubview(self.moreButton)
            })
        }
        
        self.blankView.contentSize = CGSizeMake(cWindowSize.width, self.favButton.frame.origin.y + self.favButton.frame.size.height + 20)
        
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
        let userScreenName = userDefault.objectForKey("username") as String
        
        var replyList: Array<String> = []
        var tScreenName = ""
        var fReply = false
        replyList.append("@" + self.screenName)
        for char in self.tweetBody! {
            if (fReply) {
                if (char == " " || char == "　" || !self.checkScreenName(char)) {
                    if ("@" + userScreenName != tScreenName) {
                        replyList.append(tScreenName)
                    }
                    tScreenName = ""
                    fReply = false
                } else {
                    tScreenName.append(char)
                }
            }else if (char == "@") {
                tScreenName.append(char)
                fReply = true
            }
        }
        var replyListStr = ""
        for name in replyList {
            replyListStr += name + " "
        }
        var newTweetView = NewTweetViewController(aTweetBody: replyListStr, aReplyToID: self.tweetID)
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    func tappedConversation() {
        var conversationView = ConversationTableViewController(aTweetID: self.tweetID)
        self.navigationController!.pushViewController(conversationView, animated: true)
    }
    
    //-------------------------------------------------
    //  memo: favDeleteアクションに関しては初期段階では不要
    //-------------------------------------------------
    func tappedFavorite() {
        var params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: UInt(SVProgressHUDMaskTypeClear))
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/favorite.json", params: cParameter) { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "お気に入り追加")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            })
        }
    }

    func tappedDelete() {
        var alertController = UIAlertController(title: "ツイート削除", message: "本当に削除しますか？", preferredStyle: .Alert)
        let cOkAction = UIAlertAction(title: "はい", style: .Default, handler: {action in
            println("OK")
            var params:Dictionary<String, String> = [
                "id" : self.tweetID
            ]
            let cParameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            SVProgressHUD.showWithStatus("キャンセル", maskType: UInt(SVProgressHUDMaskTypeClear))
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/delete.json", params: cParameter, callback: { (operation) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "削除完了")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                    self.navigationController!.popViewControllerAnimated(true)
                })
            })
        })
        let cCancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {action in
            println("Cancel")
        })
        alertController.addAction(cOkAction)
        alertController.addAction(cCancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func tappedMore() {
        var retweetSelectSheet = UIAlertController(title: "Retweet", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let oficialRetweetAction = UIAlertAction(title: "公式RT", style: UIAlertActionStyle.Default) { (action) -> Void in
            // 公式RTの処理．直接POSTしちゃって構わない
            var alertController = UIAlertController(title: "公式RT", message: "RTしますか？", preferredStyle: .Alert)
            let cOkAction = UIAlertAction(title: "はい", style: .Default, handler: {action in
                println("OK")
                var params:Dictionary<String, String> = [
                    "id" : self.tweetID
                ]
                let cParameter: Dictionary<String, AnyObject> = [
                    "settings" : params
                ]
                SVProgressHUD.showWithStatus("キャンセル", maskType: UInt(SVProgressHUDMaskTypeClear))
                WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/retweet.json", params: cParameter, callback: { (operation) -> Void in
                    var q_main = dispatch_get_main_queue()
                    dispatch_async(q_main, {()->Void in
                        SVProgressHUD.dismiss()
                        var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "RTしました")
                        notice.alpha = 0.8
                        notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                        notice.show()
                    })
                })
            })
            let cCancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {action in
                println("Cancel")
            })
            alertController.addAction(cOkAction)
            alertController.addAction(cCancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        let unoficialRetweetAction = UIAlertAction(title: "非公式RT", style: UIAlertActionStyle.Default) { (action) -> Void in
            var retweetView = NewTweetViewController(aTweetBody: "RT @" + self.screenName + " " + self.tweetBody!, aReplyToID: self.tweetID)
            self.navigationController!.pushViewController(retweetView, animated: true)
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
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    func tappedUserProfile() {
        var userProfileView = ProfileViewController(aScreenName: self.screenName)
        self.navigationController!.pushViewController(userProfileView, animated: true)
    }
    
    func tappedRetweetedProfile() {
        var userProfileView = ProfileViewController(aScreenName: self.retweetedName!)
        self.navigationController!.pushViewController(userProfileView, animated: true)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if (URL.scheme?.hasPrefix("at") == true) {
            var userView = ProfileViewController(aScreenName: URL.absoluteString!.stringByReplacingOccurrencesOfString("at:@", withString: "", options: nil, range: nil))
            self.navigationController!.pushViewController(userView, animated: true)
        }
        return true
    }
    
    // twitter独自のscreen name判定
    // _ はscreen nameと判定．他の文字は半角英数字のみ許可
    func checkScreenName(aCharacter: Character) -> Bool {
        if (aCharacter == "_") {
            return true
        } else {
            // 半角全角判定
            var str = String(aCharacter)
            if (str.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false) == nil) {
                return false
            } else {
                var charSet = NSCharacterSet.alphanumericCharacterSet()
                var aScanner = NSScanner.localizedScannerWithString(str) as NSScanner
                aScanner.charactersToBeSkipped = nil
                aScanner.scanCharactersFromSet(charSet, intoString: nil)
                return aScanner.atEnd
            }
        }
    }
}
