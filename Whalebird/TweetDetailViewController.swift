//
//  TweetDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/02.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController, UIActionSheetDelegate {
    let LabelPadding = CGFloat(10)
    
    //=====================================
    //  instance variables
    //=====================================
    var tweetID:String!
    var tweetBody:String?
    var screenName:String!
    var userName:String!
    var postDetail:String!
    var profileImage:String!
    
    var blankView:UIView!
    var screenNameLabel:UILabel!
    var userNameLabel:UILabel!
    var tweetBodyLabel:UILabel!
    var postDetailLabel:UILabel!
    var profileImageLabel:UIImageView!
    
    var replyButton:UIButton!
    var conversationButton:UIButton!
    var favButton:UIButton!
    var deleteButton:UIButton!
    var moreButton:UIButton!
    
    var optionButtonArea:UILabel!
    
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
    
    init(TweetID:String, TweetBody:String, ScreenName:String, UserName:String, ProfileImage:String, PostDetail:String) {
        super.init()
        self.tweetID = TweetID
        self.tweetBody = TweetBody
        self.screenName = ScreenName
        self.postDetail = PostDetail
        self.profileImage = ProfileImage
        self.userName = UserName
    }
    
    override func loadView() {
        super.loadView()
        self.blankView = UIView(frame: self.view.bounds)
        self.blankView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.blankView)
    }

    // TODO: ここからもツイートできるようにnavBarに追加しておいて
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton
        
        let windowSize = UIScreen.mainScreen().bounds
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(windowSize.size.width * 0.05, self.navigationController!.navigationBar.frame.size.height * 2.0, windowSize.size.width * 0.9, 40))
        var image_url = NSURL.URLWithString(self.profileImage)
        var error = NSError?()
        self.profileImageLabel.image = UIImage(data: NSData.dataWithContentsOfURL(image_url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error))
        self.profileImageLabel.sizeToFit()
        self.blankView.addSubview(self.profileImageLabel)

        self.userNameLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 2.0, windowSize.size.width * 0.9, 15))
        self.userNameLabel.text = self.userName
        self.userNameLabel.font = UIFont.systemFontOfSize(13)
        self.blankView.addSubview(self.userNameLabel)
        
        self.screenNameLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05 + 60, self.navigationController!.navigationBar.frame.size.height * 2.0 + self.userNameLabel.frame.size.height + 5, windowSize.size.width * 0.9, 15))
        self.screenNameLabel.text = self.screenName
        self.screenNameLabel.font = UIFont.systemFontOfSize(13)
        self.blankView.addSubview(self.screenNameLabel)
        
        self.tweetBodyLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + self.LabelPadding, windowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.text = self.tweetBody
        self.tweetBodyLabel.numberOfLines = 0
        self.tweetBodyLabel.font = UIFont.systemFontOfSize(15)
        self.tweetBodyLabel.sizeToFit()
        self.blankView.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + self.LabelPadding, windowSize.size.width * 0.9, 15))
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont.systemFontOfSize(11)
        self.blankView.addSubview(self.postDetailLabel)
        
        

        
        let importImage = UIImage(named: "Import-Line.png")
        self.replyButton = UIButton(frame: CGRectMake(0, 100, importImage.size.width, importImage.size.height))
        self.replyButton.setBackgroundImage(importImage, forState: .Normal)
        self.replyButton.center = CGPoint(x: windowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 30)
        self.replyButton.addTarget(self, action: "tappedReply", forControlEvents: UIControlEvents.TouchDown)
        self.blankView.addSubview(self.replyButton)
        
        let conversationImage = UIImage(named: "Conversation-Line.png")
        self.conversationButton = UIButton(frame: CGRectMake(0, 100, conversationImage.size.width, conversationImage.size.height))
        self.conversationButton.setBackgroundImage(conversationImage, forState: .Normal)
        self.conversationButton.center = CGPoint(x: windowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 30)
        self.conversationButton.addTarget(self, action: "tappedConversation", forControlEvents: .TouchDown)
        self.blankView.addSubview(self.conversationButton)
        
        let starImage = UIImage(named: "Star-Line.png")
        self.favButton = UIButton(frame: CGRectMake(0, 100, starImage.size.width, starImage.size.height))
        self.favButton.setBackgroundImage(starImage, forState: .Normal)
        self.favButton.center = CGPoint(x: windowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 30)
        self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
        self.blankView.addSubview(self.favButton)
        
        let user_default = NSUserDefaults.standardUserDefaults()
        let username = user_default.stringForKey("username")
        
        if (username == self.screenName) {
            let trashImage = UIImage(named: "Trash-Line.png")
            self.deleteButton = UIButton(frame: CGRectMake(0, 100, trashImage.size.width, trashImage.size.height))
            self.deleteButton.setBackgroundImage(trashImage, forState: .Normal)
            self.deleteButton.center = CGPoint(x: windowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 30)
            self.deleteButton.addTarget(self, action: "tappedDelete", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.deleteButton)
        } else {
            let moreImage = UIImage(named: "More-Line.png")
            self.moreButton = UIButton(frame: CGRectMake(0, 100, moreImage.size.width, moreImage.size.height))
            self.moreButton.setBackgroundImage(moreImage, forState: .Normal)
            self.moreButton.center = CGPoint(x: windowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 30)
            self.moreButton.addTarget(self, action: "tappedMore", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.moreButton)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //---------------------------------------------------
    // TODO: 複数人の会話の場合全員をターゲットにしているか確認
    //---------------------------------------------------
    func tappedReply() {
        var newTweetView = NewTweetViewController(TweetBody: "@" + self.screenName + " ", ReplyToID: self.tweetID)
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    // TODO: 会話内容取得アクション＋専用View作成
    func tappedConversation() {
    }
    
    //-------------------------------------------------
    //  memo: favDeleteアクションに関しては初期段階では不要
    //-------------------------------------------------
    func tappedFavorite() {
        let target_url = NSURL(string: "https://api.twitter.com/1.1/favorites/create.json")
        let params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        TwitterAPIClient.sharedClient.postTweetData(target_url, params: params, callback: {data, status, error in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Add Favorite")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            })
        })
    }

    func tappedDelete() {
        var alertController = UIAlertController(title: "ツイート削除", message: "削除していい？", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {action in
            println("OK")
            let target_url = NSURL(string: "https://api.twitter.com/1.1/statuses/destroy/" + self.tweetID + ".json")
            let params:Dictionary<String, String> = [
                "id" : self.tweetID
            ]
            TwitterAPIClient.sharedClient.postTweetData(target_url, params: params, callback: {request, status, error in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Delete Complete")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                    self.navigationController!.popViewControllerAnimated(true)
                })
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in
            println("Cancel")
        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //-----------------------------------------
    // TODO: RT以外にも何かあれば
    //-----------------------------------------
    func tappedMore() {
        var retweetSelectSheet = UIActionSheet(title: "Retweet", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        retweetSelectSheet.addButtonWithTitle("公式RT")
        retweetSelectSheet.addButtonWithTitle("非公式RT")
        retweetSelectSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        retweetSelectSheet.showInView(self.view)
        
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
        case 1:
            // 公式RTの処理．直接POSTしちゃって構わない
            var alertController = UIAlertController(title: "公式RT", message: "RTしていい？", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: {action in
                println("OK")
                let target_url = NSURL(string: "https://api.twitter.com/1.1/statuses/retweet/" + self.tweetID + ".json")
                let params:Dictionary<String, String> = [
                    "id" : self.tweetID
                ]
                TwitterAPIClient.sharedClient.postTweetData(target_url, params: params, callback: {response, status, error in
                    var q_main = dispatch_get_main_queue()
                    dispatch_async(q_main, {()->Void in
                        var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Retweet Complete")
                        notice.alpha = 0.8
                        notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                        notice.show()
                    })
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in
                println("Cancel")
            })
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
            break
        case 2:
            // TODO: RTの場合もreplyidは必要？
            var retweetView = NewTweetViewController(TweetBody: "RT @" + self.userName + " " + self.tweetBody!, ReplyToID: nil)
            self.navigationController!.pushViewController(retweetView, animated: true)
            break
        default:
            break
        }
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
}
