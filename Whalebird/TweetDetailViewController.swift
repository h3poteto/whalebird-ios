//
//  TweetDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/02.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
    //=====================================
    //  instance variables
    //=====================================
    let _LabelPadding = CGFloat(10)
    var tweetBody:String?
    var screenName:String!
    var postDetail:String!
    var profileImage:String!
    
    var blankView:UIView!
    var screenNameLabel:UILabel!
    var tweetBodyLabel:UILabel!
    var postDetailLabel:UILabel!
    var profileImageLabel:UIImageView!
    
    var replyButton:UIButton!
    var rtButton:UIButton!
    var favButton:UIButton!
    var deleteButton:UIButton!
    
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
    
    init(TweetBody:String, ScreenName:String, ProfileImage:String, PostDetail:String) {
        super.init()
        self.tweetBody = TweetBody
        self.screenName = ScreenName
        self.postDetail = PostDetail
        self.profileImage = ProfileImage
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
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(WindowSize.size.width * 0.05, self.navigationController.navigationBar.frame.size.height * 2.0, WindowSize.size.width * 0.9, 40))
        var image_url = NSURL.URLWithString(self.profileImage)
        var error = NSError?()
        self.profileImageLabel.image = UIImage(data: NSData.dataWithContentsOfURL(image_url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error))
        self.profileImageLabel.sizeToFit()
        self.blankView.addSubview(self.profileImageLabel)
        
        self.screenNameLabel = UILabel(frame: CGRectMake(WindowSize.size.width * 0.05 + 50, self.navigationController.navigationBar.frame.size.height * 2.0, WindowSize.size.width * 0.9, 15))
        self.screenNameLabel.text = self.screenName
        self.screenNameLabel.font = UIFont.systemFontOfSize(13)
        self.blankView.addSubview(self.screenNameLabel)
        
        self.tweetBodyLabel = UILabel(frame: CGRectMake(WindowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + _LabelPadding, WindowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.text = self.tweetBody
        self.tweetBodyLabel.numberOfLines = 0
        self.tweetBodyLabel.font = UIFont.systemFontOfSize(15)
        self.tweetBodyLabel.sizeToFit()
        self.blankView.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(WindowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + _LabelPadding, WindowSize.size.width * 0.9, 15))
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont.systemFontOfSize(11)
        self.blankView.addSubview(self.postDetailLabel)
        
        self.replyButton = UIButton(frame: CGRectMake(0, 100, 40, 15))
        self.replyButton.setTitle("Reply", forState: UIControlState.Normal)
        self.replyButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.replyButton.sizeToFit()
        self.replyButton.center = CGPoint(x: WindowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.replyButton.frame.size.height)
        self.blankView.addSubview(self.replyButton)
        
        self.rtButton = UIButton(frame: CGRectMake(0, 100, 40, 15))
        self.rtButton.setTitle("RT", forState: .Normal)
        self.rtButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.rtButton.sizeToFit()
        self.rtButton.center = CGPoint(x: WindowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.rtButton.frame.size.height)
        self.blankView.addSubview(self.rtButton)
        
        self.favButton = UIButton(frame: CGRectMake(0, 100, 40, 15))
        self.favButton.setTitle("Fav", forState: .Normal)
        self.favButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.favButton.sizeToFit()
        self.favButton.center = CGPoint(x: WindowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.favButton.frame.size.height)
        self.blankView.addSubview(self.favButton)
        
        self.deleteButton = UIButton(frame: CGRectMake(0, 100, 40, 15))
        self.deleteButton.setTitle("Delete", forState: .Normal)
        self.deleteButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.deleteButton.sizeToFit()
        self.deleteButton.center = CGPoint(x: WindowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.deleteButton.frame.size.height)
        self.blankView.addSubview(self.deleteButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
