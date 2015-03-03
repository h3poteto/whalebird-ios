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
        static let ImageSize = CGFloat(50)
        static let DefaultLineHeight = CGFloat(15)
        static let DefaultFontSize = CGFloat(14)
        // 共通フォント
        static let NormalFont = "Avenir-Light"
        static let BoldFont = "Avenir-Heavy"
        
        // dummy
        static let DummyLabel = UILabel()
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
    class var NormalFont: String {
        get {
            return ClassProperty.NormalFont
        }
    }
    class var BoldFont: String {
        get {
            return ClassProperty.BoldFont
        }
    }
    class var DummyLabel: UILabel {
        get {
            return ClassProperty.DummyLabel
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
    class func estimateCellHeight(aDictionary: NSDictionary) -> CGFloat {
        var height = CGFloat(60.0)
        if (aDictionary.objectForKey("moreID") == nil) {
            let cWindowMaxSize = UIScreen.mainScreen().bounds.size
            // bodyLabelの開始位置
            height = TimelineViewCell.ImagePadding * 3 + TimelineViewCell.DefaultLineHeight * 2
            // dummyでbodyLabelを生成
            DummyLabel.frame = CGRectMake(TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, TimelineViewCell.DefaultLineHeight * 2 + TimelineViewCell.ImagePadding * 3, cWindowMaxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), TimelineViewCell.DefaultLineHeight)
            DummyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            DummyLabel.numberOfLines = 0
            DummyLabel.textAlignment = NSTextAlignment.Left
            DummyLabel.text = aDictionary.objectForKey("text") as NSString
            DummyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: TimelineViewCell.DefaultFontSize)
            DummyLabel.sizeToFit()
            height += DummyLabel.frame.size.height + TimelineViewCell.ImagePadding
            height += TimelineViewCell.DefaultLineHeight
            // retweeted分の行追加
            if (aDictionary.objectForKey("retweeted") != nil) {
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
        
        let cWindowSize = UIScreen.mainScreen().bounds
        self.maxSize = cWindowSize.size
        
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
    func configureCell(aDictionary: NSDictionary) {
        if (aDictionary.objectForKey("moreID") != nil) {
            self.bodyLabel = UILabel(frame: CGRectMake(0, 0, self.maxSize.width, 40))
            self.bodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
            self.bodyLabel.textAlignment = NSTextAlignment.Center
            self.bodyLabel.textColor = UIColor.grayColor()
            self.bodyLabel.text = "もっと読む"
            self.bodyLabel.backgroundColor = UIColor(red: 0.945, green: 0.946, blue: 0.947, alpha: 1.0)
            self.contentView.addSubview(self.bodyLabel)
            
        } else{
        
            if (aDictionary.objectForKey("retweeted") != nil ) {
                self.retweeted = true
            }
            var userDefault = NSUserDefaults.standardUserDefaults()
            
            self.profileImage = UIImageView(frame: CGRectMake(TimelineViewCell.ImagePadding, TimelineViewCell.ImagePadding, TimelineViewCell.ImageSize, TimelineViewCell.ImageSize))
            self.contentView.addSubview(self.profileImage)
            self.retweetedProfileImageLabel = UIImageView(frame: CGRectMake(TimelineViewCell.ImagePadding + TimelineViewCell.ImageSize * 2.0 / 3.0, TimelineViewCell.ImagePadding + TimelineViewCell.ImageSize * 2.0 / 3.0, TimelineViewCell.ImageSize * 1.0 / 2.0, TimelineViewCell.ImageSize * 1.0 / 2.0))
            if (self.retweeted) {
                self.contentView.addSubview(self.retweetedProfileImageLabel!)
            }
            
            
            self.nameLabel = UILabel(frame: CGRectMake(
                TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                TimelineViewCell.ImagePadding,
                self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.nameLabel)
            
            self.screenNameLabel = UILabel(frame: CGRectMake(
                TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                TimelineViewCell.DefaultLineHeight + TimelineViewCell.ImagePadding * 2,
                self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.screenNameLabel)
            
            self.bodyLabel = UILabel(frame: CGRectMake(
                TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                TimelineViewCell.DefaultLineHeight * 2 + TimelineViewCell.ImagePadding * 3,
                self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.bodyLabel)
            
            self.postDetailLable = UILabel(frame: CGRectMake(
                TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                TimelineViewCell.DefaultLineHeight + TimelineViewCell.ImagePadding * 1,
                self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.postDetailLable)
            
            self.retweetedLabel = UILabel(frame: CGRectMake(
                TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 5,
                40,
                self.maxSize.width - (TimelineViewCell.ImagePadding * 6 + TimelineViewCell.ImageSize),
                TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.retweetedLabel!)
            
            //------------------------------------
            //  profileImageLabel
            //------------------------------------
            var q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            var q_main = dispatch_get_main_queue()
            var imageURL = NSURL(string: aDictionary.objectForKey("user")?.objectForKey("profile_image_url") as NSString)
            //self.profileImage.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "noimage.png"))
            self.profileImage.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "noimage.png"))
            self.profileImage.layer.cornerRadius = 5.0
            self.profileImage.clipsToBounds = true
            //------------------------------------
            //  retweetedProfileImageLabel
            //------------------------------------
            if (retweeted) {
                var imageURL = NSURL(string: aDictionary.objectForKey("retweeted")?.objectForKey("profile_image_url") as NSString)
                self.retweetedProfileImageLabel!.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "Warning.png"))
                self.retweetedProfileImageLabel!.layer.cornerRadius = 2
                self.retweetedProfileImageLabel!.clipsToBounds = true
            }
            
            let cScreenName = aDictionary.objectForKey("user")?.objectForKey("screen_name") as NSString
            //------------------------------------
            //  nameLabel
            //------------------------------------
            if (userDefault.objectForKey("displayNameType") != nil && userDefault.integerForKey("displayNameType") == 2) {
                self.nameLabel.text = "@" + cScreenName
            } else {
                self.nameLabel.text = aDictionary.objectForKey("user")?.objectForKey("name") as NSString
            }
            self.nameLabel.textAlignment = NSTextAlignment.Left
            self.nameLabel.textColor = UIColor.blackColor()
            self.nameLabel.font = UIFont(name: TimelineViewCell.BoldFont, size: TimelineViewCell.DefaultFontSize)
            
            
            //------------------------------------
            //  screenNameLabel
            //------------------------------------
            if (userDefault.objectForKey("displayNameType") != nil && ( userDefault.integerForKey("displayNameType") == 2 || userDefault.integerForKey("displayNameType") == 3 )) {
            } else {
                self.screenNameLabel.text = "@" + cScreenName
            }
            self.screenNameLabel.textAlignment = NSTextAlignment.Left
            self.screenNameLabel.textColor = UIColor.grayColor()
            self.screenNameLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: TimelineViewCell.DefaultFontSize)
            //------------------------------------
            //  bodyLabel
            //------------------------------------
            
            self.bodyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            self.bodyLabel.numberOfLines = 0
            self.bodyLabel.textAlignment = NSTextAlignment.Left
            self.bodyLabel.textColor = UIColor.blackColor()
            self.bodyLabel.text = WhalebirdAPIClient.escapeString(aDictionary.objectForKey("text") as String!) as NSString
            self.bodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: TimelineViewCell.DefaultFontSize)
            self.bodyLabel.sizeToFit()
            
            
            //------------------------------------
            //  postDetail
            //------------------------------------
            self.postDetailLable.textAlignment = NSTextAlignment.Right
            self.postDetailLable.textColor = UIColor.grayColor()
            self.postDetailLable.text = WhalebirdAPIClient.convertLocalTime(aDictionary.objectForKey("created_at") as NSString)
            self.postDetailLable.frame.origin.y = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height
            self.postDetailLable.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
            
            //-------------------------------------
            //  retweeted
            //-------------------------------------
            
            if (retweeted) {
                self.retweetedLabel?.textAlignment = NSTextAlignment.Right
                self.retweetedLabel?.textColor = UIColor.grayColor()
                self.retweetedLabel?.text = "Retweeted by @" + (aDictionary.objectForKey("retweeted")?.objectForKey("screen_name") as String)
                self.retweetedLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
                self.retweetedLabel?.frame.origin.y = self.postDetailLable.frame.origin.y + self.postDetailLable.frame.size.height
                self.retweetedLabel?.center.x = self.maxSize.width / 2.0
            }
        }
    }
}
