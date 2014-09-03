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
        
        TwitterAPIClient.sharedClient()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        newTweetText.keyboardAppearance = UIKeyboardAppearance.Light
        newTweetText.text = ""
        newTweetText.becomeFirstResponder()
    }
    
    func onCancelTapped() {
        newTweetText.text = ""
        self.navigationController.popViewControllerAnimated(true)
        
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
    //  To Do: fix ここだけnoticeが表示されない
    //-----------------------------------------
    func postTweet(tweetBody: NSString) {
        let target_url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let params: Dictionary<String, String> = [
            "status": newTweetText.text
        ]
        TwitterAPIClient.sharedClient().postTweetData(target_url, params: params, callback: { response, status, error in
            if (response != nil && status >= 200 && status < 300) {
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController.view, title: "Post Success")
                notice.alpha = 0.8
                notice.originY = self.navigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
                notice.show()
            } else {
                var notice = WBErrorNoticeView.errorNoticeInView(self.navigationController.view, title: "Error", message: "Post Error")
                notice.originY = self.navigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
                notice.show()
            }
        })
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
