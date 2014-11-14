//
//  TimelineViewCell.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TimelineViewCell: UITableViewCell {
    
    var totalHeight = CGFloat(60)
    var maxSize = CGSize()
    let ImagePadding  = CGFloat(5)
    let ImageSize = CGFloat(40)
    let DefaultLineHeigth = CGFloat(15)
    let DefaultFontSize = CGFloat(13)
    
    var nameLabel: UILabel!
    var screenNameLabel: UILabel!
    var profileImage: UIImageView!
    var bodyLabel: UILabel!
    var postDetailLable: UILabel!
    
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
        
        self.profileImage = nil
        self.nameLabel = nil
        self.screenNameLabel = nil
        self.bodyLabel = nil
        self.postDetailLable = nil
    }
    //--------------------------------------------
    // cell は再利用される
    // configureCellはcellForRowAtIndexで呼ばれるので，描画されるたびに要素を全て作り直す
    //--------------------------------------------
    // TODO: RTの表示設定
    func configureCell(dict: NSDictionary) {
        var userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImage = UIImageView(frame: CGRectMake(self.ImagePadding, self.ImagePadding, self.ImageSize, self.ImageSize))
        self.contentView.addSubview(self.profileImage)
        self.nameLabel = UILabel(frame: CGRectMake(self.ImageSize + self.ImagePadding * 4 , self.ImagePadding, self.maxSize.width - (self.ImagePadding * 5 + self.ImageSize), self.DefaultLineHeigth))
        if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 3 ) {
            self.contentView.addSubview(self.nameLabel)
        }
        self.screenNameLabel = UILabel(frame: CGRectMake(self.ImageSize + self.ImagePadding * 4, self.DefaultLineHeigth + self.ImagePadding * 1, self.maxSize.width - (self.ImagePadding * 5 + self.ImageSize), self.DefaultLineHeigth))
        if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 2 ) {
            self.contentView.addSubview(self.screenNameLabel)
        }
        self.bodyLabel = UILabel(frame: CGRectMake(self.ImageSize + self.ImagePadding * 4, self.DefaultLineHeigth * 2 + self.ImagePadding * 2, self.maxSize.width - (self.ImagePadding * 5 + self.ImageSize), self.DefaultLineHeigth))
        self.contentView.addSubview(self.bodyLabel)
        self.postDetailLable = UILabel(frame: CGRectMake(self.ImageSize + self.ImagePadding * 4, 40, self.maxSize.width - (self.ImagePadding * 5 + self.ImageSize), self.DefaultLineHeigth))
        self.contentView.addSubview(self.postDetailLable)
        
        
        //------------------------------------
        //  profileImageLabel
        // TODO: SDWebImageによるキャッシュ
        //------------------------------------
        var q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        var q_main = dispatch_get_main_queue()
        dispatch_async(q_global, { () -> Void in
            var error = NSError?()
            var image_url = NSURL(string: dict.objectForKey("user")?.objectForKey("profile_image_url") as NSString)
            var image = UIImage(data: NSData(contentsOfURL: image_url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)!)
            dispatch_async(q_main, { () -> Void in
                self.profileImage.image = image
                self.profileImage.sizeToFit()
            })
        })
        //------------------------------------
        //  nameLabel
        //------------------------------------
        self.nameLabel.textAlignment = NSTextAlignment.Left
        self.nameLabel.textColor = UIColor.blackColor()
        self.nameLabel.text = dict.objectForKey("user")?.objectForKey("name") as NSString
        self.nameLabel.font = UIFont.systemFontOfSize(self.DefaultFontSize)

        
        //------------------------------------
        //  screenNameLabel
        //------------------------------------
        self.screenNameLabel.textAlignment = NSTextAlignment.Left
        self.screenNameLabel.textColor = UIColor.grayColor()
        let screen_name = dict.objectForKey("user")?.objectForKey("screen_name") as NSString
        self.screenNameLabel.text = "@" + screen_name
        self.screenNameLabel.font = UIFont.systemFontOfSize(self.DefaultFontSize)
        //------------------------------------
        //  bodyLabel
        //------------------------------------
        self.bodyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.bodyLabel.numberOfLines = 0
        self.bodyLabel.textAlignment = NSTextAlignment.Left
        self.bodyLabel.textColor = UIColor.blackColor()
        self.bodyLabel.text = dict.objectForKey("text") as NSString
        self.bodyLabel.font = UIFont.systemFontOfSize(self.DefaultFontSize)
        self.bodyLabel.sizeToFit()
        
        //------------------------------------
        //  postDetail
        //------------------------------------
        self.postDetailLable.textAlignment = NSTextAlignment.Left
        self.postDetailLable.textColor = UIColor.grayColor()
        self.postDetailLable.text = dict.objectForKey("created_at") as NSString
        self.postDetailLable.font = UIFont.systemFontOfSize(11)
        self.postDetailLable.frame.origin.y = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height + self.ImagePadding
        
        self.totalHeight  = self.ImagePadding * 4 + self.bodyLabel.frame.size.height + self.nameLabel.frame.size.height + self.screenNameLabel.frame.size.height + self.postDetailLable.frame.size.height
    }
    
    func cellHeight() -> CGFloat {
        if (self.totalHeight > 60) {
            return self.totalHeight
        } else {
            return 60
        }
    }
    

}
