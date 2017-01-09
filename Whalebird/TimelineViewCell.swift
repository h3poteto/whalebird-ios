//
//  TimelineViewCell.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SDWebImage

class TimelineViewCell: UITableViewCell {
    
    //===================================
    //  class variables
    //===================================
    static let ImagePadding = CGFloat(7)
    static let ImageSize = CGFloat(50)
    static let DefaultLineHeight = CGFloat(15)
    static let DefaultFontSize = CGFloat(14)
    static let NormalFont = "Avenir-Light"
    static let BoldFont = "Avenir-Heavy"
    static let DummyLabel = UILabel()
    
    
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
    class func estimateCellHeight(_ aDictionary: NSDictionary) -> CGFloat {
        var height = CGFloat(60.0)
        if (aDictionary.object(forKey: "moreID") == nil) {
            let cWindowMaxSize = UIScreen.main.bounds.size
            // bodyLabelの開始位置
            height = TimelineViewCell.ImagePadding * 3 + TimelineViewCell.DefaultLineHeight * 2
            // dummyでbodyLabelを生成
            DummyLabel.frame = CGRect(x: TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4, y: TimelineViewCell.DefaultLineHeight * 2 + TimelineViewCell.ImagePadding * 3, width: cWindowMaxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize), height: TimelineViewCell.DefaultLineHeight)
            DummyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            DummyLabel.numberOfLines = 0
            DummyLabel.textAlignment = NSTextAlignment.left
            DummyLabel.text = aDictionary.object(forKey: "text") as! NSString as String
            DummyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: TimelineViewCell.DefaultFontSize)
            DummyLabel.sizeToFit()
            height += DummyLabel.frame.size.height + TimelineViewCell.ImagePadding
            height += TimelineViewCell.DefaultLineHeight
            // retweeted分の行追加
            if (aDictionary.object(forKey: "retweeted") != nil) {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let cWindowSize = UIScreen.main.bounds
        self.maxSize = cWindowSize.size
        
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
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
    func configureCell(_ aDictionary: NSDictionary) {
        if (aDictionary.object(forKey: "moreID") != nil) {
            self.bodyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.maxSize.width, height: 40))
            self.bodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
            self.bodyLabel.textAlignment = NSTextAlignment.center
            self.bodyLabel.textColor = UIColor.gray
            self.bodyLabel.text = NSLocalizedString("Read more", comment: "")
            self.bodyLabel.backgroundColor = UIColor(red: 0.945, green: 0.946, blue: 0.947, alpha: 1.0)
            self.contentView.addSubview(self.bodyLabel)
            
        } else{
        
            if (aDictionary.object(forKey: "retweeted") != nil ) {
                self.retweeted = true
            }
            let userDefault = UserDefaults.standard
            
            self.profileImage = UIImageView(frame: CGRect(x: TimelineViewCell.ImagePadding, y: TimelineViewCell.ImagePadding, width: TimelineViewCell.ImageSize, height: TimelineViewCell.ImageSize))
            // 角丸にする
            self.profileImage.layer.cornerRadius = 6.0
            self.profileImage.layer.masksToBounds = true
            self.profileImage.layer.borderWidth = 0.0
            self.contentView.addSubview(self.profileImage)
            self.retweetedProfileImageLabel = UIImageView(frame: CGRect(x: TimelineViewCell.ImagePadding + TimelineViewCell.ImageSize * 2.0 / 3.0, y: TimelineViewCell.ImagePadding + TimelineViewCell.ImageSize * 2.0 / 3.0, width: TimelineViewCell.ImageSize * 1.0 / 2.0, height: TimelineViewCell.ImageSize * 1.0 / 2.0))
            if (self.retweeted) {
                // 角丸にする
                self.retweetedProfileImageLabel?.layer.cornerRadius = 6.0
                self.retweetedProfileImageLabel?.layer.masksToBounds = true
                self.retweetedProfileImageLabel?.layer.borderWidth = 0.0
                self.contentView.addSubview(self.retweetedProfileImageLabel!)
            }
            
            
            self.nameLabel = UILabel(frame: CGRect(
                x: TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                y: TimelineViewCell.ImagePadding,
                width: self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                height: TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.nameLabel)
            
            self.screenNameLabel = UILabel(frame: CGRect(
                x: TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                y: TimelineViewCell.DefaultLineHeight + TimelineViewCell.ImagePadding * 2,
                width: self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                height: TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.screenNameLabel)
            
            self.bodyLabel = UILabel(frame: CGRect(
                x: TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                y: TimelineViewCell.DefaultLineHeight * 2 + TimelineViewCell.ImagePadding * 3,
                width: self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                height: TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.bodyLabel)
            
            self.postDetailLable = UILabel(frame: CGRect(
                x: TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 4,
                y: TimelineViewCell.DefaultLineHeight + TimelineViewCell.ImagePadding * 1,
                width: self.maxSize.width - (TimelineViewCell.ImagePadding * 5 + TimelineViewCell.ImageSize),
                height: TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.postDetailLable)
            
            self.retweetedLabel = UILabel(frame: CGRect(
                x: TimelineViewCell.ImageSize + TimelineViewCell.ImagePadding * 5,
                y: 40,
                width: self.maxSize.width - (TimelineViewCell.ImagePadding * 6 + TimelineViewCell.ImageSize),
                height: TimelineViewCell.DefaultLineHeight))
            self.contentView.addSubview(self.retweetedLabel!)
            
            //------------------------------------
            //  background color
            //------------------------------------
            if aDictionary.object(forKey: "unread") as? Bool == true {
                self.contentView.backgroundColor = UIColor(
                    red: 0.878,
                    green: 0.949,
                    blue: 0.969,
                    alpha: 1.0
                )
            } else {
                self.contentView.backgroundColor = UIColor.white
            }

            //------------------------------------
            //  profileImageLabel
            //------------------------------------
            let imageURL = URL(string: (aDictionary.object(forKey: "user") as! NSDictionary).object(forKey: "profile_image_url") as! String)
            self.profileImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "noimage"))
            //------------------------------------
            //  retweetedProfileImageLabel
            //------------------------------------
            if (retweeted) {
                let imageURL = URL(string: (aDictionary.object(forKey: "retweeted") as! NSDictionary).object(forKey: "profile_image_url") as! String)
                self.retweetedProfileImageLabel?.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "Warning"))
            }
            
            let cScreenName = (aDictionary.object(forKey: "user") as! NSDictionary).object(forKey: "screen_name") as! String
            //------------------------------------
            //  nameLabel
            //------------------------------------
            if (userDefault.object(forKey: "displayNameType") != nil && userDefault.integer(forKey: "displayNameType") == 2) {
                self.nameLabel.text = "@" + cScreenName
            } else {
                self.nameLabel.text = (aDictionary.object(forKey: "user") as! NSDictionary).object(forKey: "name") as? String
            }
            self.nameLabel.textAlignment = NSTextAlignment.left
            self.nameLabel.textColor = UIColor.black
            self.nameLabel.font = UIFont(name: TimelineViewCell.BoldFont, size: TimelineViewCell.DefaultFontSize)
            
            
            //------------------------------------
            //  screenNameLabel
            //------------------------------------
            if (userDefault.object(forKey: "displayNameType") != nil && ( userDefault.integer(forKey: "displayNameType") == 2 || userDefault.integer(forKey: "displayNameType") == 3 )) {
            } else {
                self.screenNameLabel.text = "@" + cScreenName
            }
            self.screenNameLabel.textAlignment = NSTextAlignment.left
            self.screenNameLabel.textColor = UIColor.gray
            self.screenNameLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: TimelineViewCell.DefaultFontSize)
            //------------------------------------
            //  bodyLabel
            //------------------------------------
            
            self.bodyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.bodyLabel.numberOfLines = 0
            self.bodyLabel.textAlignment = NSTextAlignment.left
            self.bodyLabel.textColor = UIColor.black
            self.bodyLabel.text = WhalebirdAPIClient.escapeString(aDictionary.object(forKey: "text") as! String)
            self.bodyLabel.font = UIFont(name: TimelineViewCell.NormalFont, size: TimelineViewCell.DefaultFontSize)
            self.bodyLabel.sizeToFit()
            
            
            //------------------------------------
            //  postDetail
            //------------------------------------
            self.postDetailLable.textAlignment = NSTextAlignment.right
            self.postDetailLable.textColor = UIColor.gray
            self.postDetailLable.text = WhalebirdAPIClient.convertLocalTime(aDictionary.object(forKey: "created_at") as! String)
            self.postDetailLable.frame.origin.y = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height
            self.postDetailLable.font = UIFont(name: TimelineViewCell.NormalFont, size: 12)
            
            //-------------------------------------
            //  retweeted
            //-------------------------------------
            
            if (retweeted) {
                self.retweetedLabel?.textAlignment = NSTextAlignment.right
                self.retweetedLabel?.textColor = UIColor.gray
                self.retweetedLabel?.text = "Retweeted by @" + ((aDictionary.object(forKey: "retweeted") as! NSDictionary).object(forKey: "screen_name") as! String)
                self.retweetedLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
                self.retweetedLabel?.sizeToFit()
                self.retweetedLabel?.frame.origin.y = self.postDetailLable.frame.origin.y + self.postDetailLable.frame.size.height
                self.retweetedLabel?.center.x = self.maxSize.width / 2.0
            }
        }
    }
}
