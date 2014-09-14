//
//  NewTweetViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate{
    var maxSize: CGSize!
    var tweetBody: String!
    var replyToID: String?
    
    var blankView:UIView!
    var newTweetText: UITextView!
    var cancelButton: UIBarButtonItem!
    var sendButton: UIBarButtonItem!
    
    //======================================
    //  instance method
    //======================================
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    init(TweetBody: String!, ReplyToID: String?) {
        super.init()
        self.tweetBody = TweetBody
        self.replyToID = ReplyToID
    }
    
    override func loadView() {
        super.loadView()
        self.blankView = UIView(frame: self.view.bounds)
        self.blankView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.blankView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let WindowSize = UIScreen.mainScreen().bounds
        self.maxSize = WindowSize.size
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "onCancelTapped")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        sendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onSendTapped")
        self.navigationItem.rightBarButtonItem = sendButton
        
        newTweetText = UITextView(frame: CGRectMake(0, 0, self.maxSize.width, self.maxSize.height / 2.0))
        newTweetText.editable = true
        newTweetText.delegate = self
        self.blankView.addSubview(newTweetText)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        newTweetText.keyboardAppearance = UIKeyboardAppearance.Light
        newTweetText.text = self.tweetBody
        newTweetText.becomeFirstResponder()
    }
    
    func onCancelTapped() {
        newTweetText.text = ""
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    //-----------------------------------------
    //  送信ボタンを押した時の処理
    //-----------------------------------------
    func onSendTapped() {
        if (countElements(newTweetText.text as String) > 0) {
            postTweet(newTweetText.text)
        }
    }
    
    
    //-----------------------------------------
    //  return: status
    //  クライアント名はアプリ登録することで表示される
    //  デバッグ中はvia iOSを変更することはできない
    //  To Do: fix ここだけnoticeが表示されない，早くしたい
    //-----------------------------------------
    func postTweet(tweetBody: NSString) {
        let target_url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        var params: Dictionary<String, String>
        if (self.replyToID != nil) {
            params = [
                "status": newTweetText.text,
                "in_reply_to_status_id": self.replyToID!
            ]
        } else {
            params = [
                "status": newTweetText.text
            ]
        }
        TwitterAPIClient.sharedClient.postTweetData(target_url, params: params, callback: { response, status, error in
            var q_main = dispatch_get_main_queue()
            if (response != nil && status >= 200 && status < 300) {
                dispatch_async(q_main, {()->Void in
                    var notice = WBSuccessNoticeView.successNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Post Success")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                })
            } else {
                dispatch_async(q_main, {()->Void in
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Error", message: "Post Error")
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                })
            }
        })
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
