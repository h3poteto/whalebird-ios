//
//  TimelineViewCell.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TimelineViewCell: UITableViewCell {
    
    //===================================
    //  class variables
    //===================================
    private struct ClassProperty {
        static let ImagePadding = CGFloat(7)
        static let ImageSize = CGFloat(40)
        static let DefaultLineHeight = CGFloat(15)
        static let DefaultFontSize = CGFloat(13)
    }
    
    class var ImagePadding: CGFloat {
        get {
            return ClassProperty.ImagePadding
        }
    }
    class var ImageSize: CGFloat {
        get {
            return ClassProperty.ImageSize
        }
    }
    class var DefaultLineHeight: CGFloat {
        get {
            return ClassProperty.DefaultLineHeight
        }
    }
    class var DefaultFontSize: CGFloat {
        get {
            return ClassProperty.DefaultFontSize
        }
    }
    
    
    //===================================
    //  instance variables
    //===================================
    var maxSize = CGSize()
    
    var nameLabel: UILabel!
    var screenNameLabel: UILabel!
    var profileImage: UIImageView!
    var bodyLabel: UILabel!
    var postDetailLable: UILabel!
    var retweetedLabel: UILabel?
    var retweetedProfileImageLabel: UIImageView?
    var retweeted = false
    
    //====================================
    //  class method
    //====================================
    class func estimateCellHeight(dict: NSDictionary) -> CGFloat {
        var height = CGFloat(60.0)
        if (dict.objectForKey("moreID") == nil) {
            let windowMaxSize = UIScreen.mainScreen().bounds.size
            // bodyLabelの開始位置
            height = TimelineViewCell.ImagePadding * 2 + TimelineViewCell.DefaultLineHeight * 2
            // dummyでbodyLabelを生成
            var dummyLabel = UILabel(frame: CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, TimelineViewCell.DefaultLineHeight * 2 + TimelineViewCell.ImagePadding * 2, windowMaxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight))
            dummyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            dummyLabel.numberOfLines = 0
            dummyLabel.textAlignment = NSTextAlignment.Left
            dummyLabel.textColor = UIColor.blackColor()
            dummyLabel.text = dict.objectForKey("text") as NSString
            dummyLabel.font = UIFont.systemFontOfSize(TimelineViewCell.DefaultFontSize)
            dummyLabel.sizeToFit()
            // retweeted分の行追加
            height += dummyLabel.frame.size.height + TimelineViewCell.ImagePadding
            if (dict.objectForKey("retweeted") != nil) {
                height += TimelineViewCell.DefaultLineHeight
            }
        } else {
            height = CGFloat(40.0)
        }
        return height
    }
    
    //====================================
    //  instance method
    //====================================
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let WindowSize = UIScreen.mainScreen().bounds
        self.maxSize = WindowSize.size
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //--------------------------------------
    // Cellは使いまわされるので，描画されるたびに消去処理をしておかないといけない
    //--------------------------------------
    func cleanCell() {
        if (self.profileImage != nil) {
            self.profileImage.removeFromSuperview()
        }
        if (self.nameLabel != nil) {
            self.nameLabel.removeFromSuperview()
        }
        if (self.screenNameLabel != nil) {
            self.screenNameLabel.removeFromSuperview()
        }
        if (self.bodyLabel != nil) {
            self.bodyLabel.removeFromSuperview()
        }
        if (self.postDetailLable != nil) {
            self.postDetailLable.removeFromSuperview()
        }
        if (self.retweetedLabel != nil) {
            self.retweetedLabel?.removeFromSuperview()
        }
        if (self.retweetedProfileImageLabel != nil) {
            self.retweetedProfileImageLabel?.removeFromSuperview()
        }
        
        self.profileImage = nil
        self.nameLabel = nil
        self.screenNameLabel = nil
        self.bodyLabel = nil
        self.postDetailLable = nil
        self.retweetedLabel = nil
        self.retweetedProfileImageLabel = nil
        self.retweeted = false
    }
    //--------------------------------------------
    // cell は再利用される
    // configureCellはcellForRowAtIndexで呼ばれるので，描画されるたびに要素を全て作り直す
    //--------------------------------------------
    func configureCell(dict: NSDictionary) {
        if (dict.objectForKey("moreID") != nil) {
            self.bodyLabel = UILabel(frame: CGRectMake(0, 0, self.maxSize.width, 40))
            self.bodyLabel.font = UIFont.systemFontOfSize(15)
            self.bodyLabel.textAlignment = NSTextAlignment.Center
            self.bodyLabel.textColor = UIColor.blueColor()
            self.bodyLabel.text = "もっと読む"
            self.bodyLabel.backgroundColor = UIColor.lightGrayColor()
            self.contentView.addSubview(self.bodyLabel)
            
        } else{
        
            if (dict.objectForKey("retweeted") != nil ) {
                self.retweeted = true
            }
            var userDefault = NSUserDefaults.standardUserDefaults()
            
            self.profileImage = UIImageView(frame: CGRectMake(TimelineViewCell.ImagePadding, TimelineViewCell.ImagePadding, TimelineViewCell.ImageSize, TimelineViewCell.ImageSize))
            self.contentView.addSubview(self.profileImage)
            self.retweetedProfileImageLabel = UIImageView(frame: CGRectMake(TimelineViewCell.ImagePadding + TimelineViewCell.ImageSize * 3.0 / 4.0, TimelineViewCell.ImagePadding + TimelineViewCell.ImageSize * 3.0 / 4.0, TimelineViewCell.ImageSize * 2.0 / 3.0, TimelineViewCell.ImageSize * 2.0 / 3.0))
            if (self.retweeted) {
                self.contentView.addSubview(self.retweetedProfileImageLabel!)
            }
            self.nameLabel = UILabel(frame: CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4 , TimelineViewCell.ImagePadding, self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight))
            if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 3 ) {
                self.contentView.addSubview(self.nameLabel)
            }
            self.screenNameLabel = UILabel(frame: CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, TimelineViewCell.DefaultLineHeight + TimelineViewCell.ImagePadding * 1, self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight))
            if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 2 ) {
                self.contentView.addSubview(self.screenNameLabel)
            }
            self.bodyLabel = UILabel(frame: CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, TimelineViewCell.DefaultLineHeight * 2 + TimelineViewCell.ImagePadding * 2, self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.bodyLabel)
            self.postDetailLable = UILabel(frame: CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, TimelineViewCell.DefaultLineHeight + TimelineViewCell.ImagePadding * 1, self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.postDetailLable)
            
            self.retweetedLabel = UILabel(frame: CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, 40, self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.retweetedLabel!)
            
            //------------------------------------
            //  profileImageLabel
            //------------------------------------
            var q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_global, { () -> Void in
                var error = NSError?()
                var imageURL = NSURL(string: dict.objectForKey("user")?.objectForKey("profile_image_url") as NSString)
                var imageData = NSData(contentsOfURL: imageURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
                var image: UIImage?
                if (error == nil) {
                    image = UIImage(data: imageData!)
                }
                dispatch_async(q_main, { () -> Void in
                    if (image != nil) {
                        self.profileImage.image = image
                        self.profileImage.sizeToFit()
                    }
                })
            })
            //------------------------------------
            //  retweetedProfileImageLabel
            //------------------------------------
            if (retweeted) {
                dispatch_async(q_global, { () -> Void in
                    var error = NSError?()
                    var imageURL = NSURL(string: dict.objectForKey("retweeted")?.objectForKey("profile_image_url") as NSString)
                    var imageData = NSData(contentsOfURL: imageURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
                    var image: UIImage?
                    if (error == nil) {
                        image = UIImage(data: imageData!)
                    }
                    dispatch_async(q_main, { () -> Void in
                        if (image != nil) {
                            self.retweetedProfileImageLabel!.image = image
                        }
                    })
                    
                })
            }
            //------------------------------------
            //  nameLabel
            //------------------------------------
            self.nameLabel.textAlignment = NSTextAlignment.Left
            self.nameLabel.textColor = UIColor.blackColor()
            self.nameLabel.text = dict.objectForKey("user")?.objectForKey("name") as NSString
            self.nameLabel.font = UIFont.systemFontOfSize(TimelineViewCell.DefaultFontSize)
            
            
            //------------------------------------
            //  screenNameLabel
            //------------------------------------
            self.screenNameLabel.textAlignment = NSTextAlignment.Left
            self.screenNameLabel.textColor = UIColor.grayColor()
            let screen_name = dict.objectForKey("user")?.objectForKey("screen_name") as NSString
            self.screenNameLabel.text = "@" + screen_name
            self.screenNameLabel.font = UIFont.systemFontOfSize(TimelineViewCell.DefaultFontSize)
            //------------------------------------
            //  bodyLabel
            //------------------------------------
            
            var error = NSError?()
            
            self.bodyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            self.bodyLabel.numberOfLines = 0
            self.bodyLabel.textAlignment = NSTextAlignment.Left
            self.bodyLabel.textColor = UIColor.blackColor()
            self.bodyLabel.text = dict.objectForKey("text") as NSString
            self.bodyLabel.font = UIFont.systemFontOfSize(TimelineViewCell.DefaultFontSize)
            self.bodyLabel.sizeToFit()
            
            
            //------------------------------------
            //  postDetail
            //------------------------------------
            self.postDetailLable.textAlignment = NSTextAlignment.Right
            self.postDetailLable.textColor = UIColor.grayColor()
            self.postDetailLable.text = WhalebirdAPIClient.convertLocalTime(dict.objectForKey("created_at") as NSString)
            self.postDetailLable.font = UIFont.systemFontOfSize(11)
            
            //-------------------------------------
            //  retweeted
            //-------------------------------------
            
            if (retweeted) {
                self.retweetedLabel?.textAlignment = NSTextAlignment.Right
                self.retweetedLabel?.textColor = UIColor.grayColor()
                self.retweetedLabel?.text = "Retweeted by @" + (dict.objectForKey("retweeted")?.objectForKey("screen_name") as String)
                self.retweetedLabel?.font = UIFont.systemFontOfSize(13)
            }
            self.retweetedLabel?.frame.origin.y = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height
        }
    }
}
