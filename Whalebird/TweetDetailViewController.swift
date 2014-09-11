//
//  TweetDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/02.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController, UIActionSheetDelegate {
    let _iconSize = CGFloat(40)
    let _LabelPadding = CGFloat(10)
    
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
    var rtButton:UIButton!
    var favButton:UIButton!
    var deleteButton:UIButton!
    var detailButton:UIButton!
    
    var optionButtonArea:UILabel!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.tweetBodyLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + _LabelPadding, windowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.text = self.tweetBody
        self.tweetBodyLabel.numberOfLines = 0
        self.tweetBodyLabel.font = UIFont.systemFontOfSize(15)
        self.tweetBodyLabel.sizeToFit()
        self.blankView.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + _LabelPadding, windowSize.size.width * 0.9, 15))
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont.systemFontOfSize(11)
        self.blankView.addSubview(self.postDetailLabel)
        
        self.optionButtonArea = UILabel(frame: CGRectMake(0, self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 10, windowSize.size.width, _iconSize))
        self.optionButtonArea.backgroundColor = UIColor(red: 0.529, green: 0.808, blue: 0.980, alpha: 1.0)
        self.blankView.addSubview(self.optionButtonArea)
        
        
        
        self.replyButton = UIButton(frame: CGRectMake(0, 100, _iconSize, _iconSize))
        self.replyButton.setBackgroundImage(UIImage(named: "appbar.reply.email.png"), forState: .Normal)
        self.replyButton.center = CGPoint(x: windowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.replyButton.frame.size.height / 2.0 + 10)
        self.replyButton.addTarget(self, action: "tappedReply", forControlEvents: UIControlEvents.TouchDown)
        self.blankView.addSubview(self.replyButton)
        
        self.rtButton = UIButton(frame: CGRectMake(0, 100, _iconSize, _iconSize))
        self.rtButton.setBackgroundImage(UIImage(named: "appbar.repeat.png"), forState: .Normal)
        self.rtButton.center = CGPoint(x: windowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.rtButton.frame.size.height / 2.0 + 10)
        self.rtButton.addTarget(self, action: "tappedRetweet", forControlEvents: .TouchDown)
        self.blankView.addSubview(self.rtButton)
        
        self.favButton = UIButton(frame: CGRectMake(0, 100, _iconSize, _iconSize))
        self.favButton.setBackgroundImage(UIImage(named: "appbar.star.png"), forState: .Normal)
        self.favButton.center = CGPoint(x: windowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.favButton.frame.size.height / 2.0 + 10)
        self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
        self.blankView.addSubview(self.favButton)
        
        let user_default = NSUserDefaults.standardUserDefaults()
        let username = user_default.stringForKey("username")
        
        if (username == self.screenName) {
            self.deleteButton = UIButton(frame: CGRectMake(0, 100, _iconSize, _iconSize))
            self.deleteButton.setBackgroundImage(UIImage(named: "appbar.delete.png"), forState: .Normal)
            self.deleteButton.center = CGPoint(x: windowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.deleteButton.frame.size.height / 2.0 + 10)
            self.deleteButton.addTarget(self, action: "tappedDelete", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.deleteButton)
        } else {
            self.detailButton = UIButton(frame: CGRectMake(0, 100, _iconSize, _iconSize))
            self.detailButton.setBackgroundImage(UIImage(named: "appbar.list.png"), forState: .Normal)
            self.detailButton.center = CGPoint(x: windowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.detailButton.frame.size.height / 2.0 + 10)
            self.detailButton.addTarget(self, action: "tappedDetail", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.detailButton)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO イベントの実装
    // Replyに関してはreply toのidをどこかで取得してくる必要あり．通知から起動したときも入るようにidだけ渡せれば最高
    
    func tappedReply() {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    func tappedRetweet() {
        var retweetSelectSheet = UIActionSheet(title: "Retweet", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        retweetSelectSheet.addButtonWithTitle("公式RT")
        retweetSelectSheet.addButtonWithTitle("非公式RT")
        retweetSelectSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        retweetSelectSheet.showInView(self.view)
    }
    
    func tappedFavorite() {
        // TODO: Delete側のアクションも作る必要あり．favの情報も必要である
        
        let target_url = NSURL(string: "https://api.twitter.com/1.1/favorites/create.json")
        let params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        TwitterAPIClient.sharedClient().postTweetData(target_url, params: params, callback: {data, status, error in
            // これnavigationControllerに表示しようとすると，出ないのであとでなんか考えて
            var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Add Favorite")
            notice.alpha = 0.8
            notice.originY = UIApplication.sharedApplication().statusBarFrame.height
            notice.show()
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
            TwitterAPIClient.sharedClient().postTweetData(target_url, params: params, callback: {request, status, error in
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Delete Complete")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.navigationController!.popViewControllerAnimated(true)
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in
            println("Cancel")
        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func tappedDetail() {
        
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
                TwitterAPIClient.sharedClient().postTweetData(target_url, params: params, callback: {response, status, error in
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "Retweet Complete")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
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
            var retweetView = NewTweetViewController(TweetBody: "RT @" + self.userName + " " + self.tweetBody!)
            self.navigationController!.pushViewController(retweetView, animated: true)
            break
        default:
            break
        }
    }
}
