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
    @IBOutlet var newTweetText: UITextView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var sendButton: UIBarButtonItem!
    
    
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
        self.view.addSubview(newTweetText)
        
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
        
    }
    
    func onSendTapped() {
        postTweet(newTweetText.text)
    }
    
    
    //-----------------------------------------
    //  return: status
    //-----------------------------------------
    func postTweet(tweetBody: NSString) -> Int {
        return 200
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
