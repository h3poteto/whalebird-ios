//
//  NewDirectMessageViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/12.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD
import NoticeView

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
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = NSLocalizedString("Title", tableName: "NewDirectMessage", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(aReplyToUser: String?) {
        self.init()
        self.title = NSLocalizedString("Title", tableName: "NewDirectMessage", comment: "")
        self.replyToUser = aReplyToUser
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cMaxSize = UIScreen.main.bounds.size

        self.cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", tableName: "NewDirectMessage", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewDirectMessageViewController.onCancelTapped))
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: NSLocalizedString("Send", tableName: "NewDirectMessage", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(NewDirectMessageViewController.onSendTapped))
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.sendToUserLabel = UILabel(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height, width: cMaxSize.width, height: 35))
        self.sendToUserLabel.text = "to: " + self.replyToUser
        self.sendToUserLabel.textAlignment = NSTextAlignment.center
        self.sendToUserLabel.backgroundColor = UIColor.lightGray
        self.sendToUserLabel.center.x = cMaxSize.width / 2.0
        self.view.addSubview(self.sendToUserLabel)
        
        self.newMessageText = UITextView(frame: CGRect(x: 0, y: 100, width: cMaxSize.width, height: cMaxSize.height / 3.0))
        self.newMessageText.isEditable = true
        self.newMessageText.delegate = self
        self.newMessageText.font = UIFont(name: TimelineViewCell.NormalFont, size: 18)
        //self.newMessageText.addSubview(self.sendToUserLabel)
        self.view.addSubview(self.newMessageText)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @objc func onCancelTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    
    }
    
    @objc func onSendTapped() {
        if ((self.newMessageText.text as String).count > 0 && self.replyToUser != nil) {
            self.postDirectMessage(self.newMessageText.text)
        }
    }
    
    func postDirectMessage(_ messageBody: String!) {
        var params: Dictionary<String, String>
        params = [
            "screen_name" : self.replyToUser,
            "text" : messageBody
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject
        ]
        
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/direct_message_create.json", params: cParameter) { (aOperation) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: { () -> Void in
                let notice = WBSuccessNoticeView.successNotice(in: UIApplication.shared.delegate?.window!, title: NSLocalizedString("DirectMessageCompleted", tableName: "NewDirectMessage", comment: ""))
                SVProgressHUD.dismiss()
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
                _ = self.navigationController?.popViewController(animated: true)
            })
        }
    }
}
