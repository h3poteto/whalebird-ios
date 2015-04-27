//
//  NewDirectMessageViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/12.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class NewDirectMessageViewController: UIViewController, UITextViewDelegate {
 
    //=============================================
    //  instance variables
    //=============================================
    var replyToUser: String!
    
    var sendToUserLabel: UILabel!
    var newMessageText: UITextView!
    var cancelButton: UIBarButtonItem!
    var sendButton: UIBarButtonItem!
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "DM送信"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(aReplyToUser: String?) {
        self.init()
        self.replyToUser = aReplyToUser
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.whiteColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cMaxSize = UIScreen.mainScreen().bounds.size

        self.cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "onCancelTapped")
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: "送信", style: UIBarButtonItemStyle.Done, target: self, action: "onSendTapped")
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.sendToUserLabel = UILabel(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, cMaxSize.width, 35))
        self.sendToUserLabel.text = "to: " + self.replyToUser
        self.sendToUserLabel.textAlignment = NSTextAlignment.Center
        self.sendToUserLabel.backgroundColor = UIColor.lightGrayColor()
        self.sendToUserLabel.center.x = cMaxSize.width / 2.0
        self.view.addSubview(self.sendToUserLabel)
        
        self.newMessageText = UITextView(frame: CGRectMake(0, 100, cMaxSize.width, cMaxSize.height / 3.0))
        self.newMessageText.editable = true
        self.newMessageText.delegate = self
        self.newMessageText.font = UIFont(name: TimelineViewCell.NormalFont, size: 18)
        //self.newMessageText.addSubview(self.sendToUserLabel)
        self.view.addSubview(self.newMessageText)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        WhalebirdAPIClient.encodeClipboardURL()
    }
    
    func onCancelTapped() {
        self.navigationController!.popViewControllerAnimated(true)
    
    }
    
    func onSendTapped() {
        if (count(self.newMessageText.text as String) > 0 && self.replyToUser != nil) {
            self.postDirectMessage(self.newMessageText.text)
        }
    }
    
    func postDirectMessage(messageBody: String!) {
        var params: Dictionary<String, String>
        params = [
            "screen_name" : self.replyToUser,
            "text" : messageBody
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/direct_message_create.json", params: cParameter) { (aOperation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                var notice = WBSuccessNoticeView.successNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "送信しました")
                SVProgressHUD.dismiss()
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
}
