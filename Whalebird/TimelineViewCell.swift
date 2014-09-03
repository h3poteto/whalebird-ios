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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var postDetailLable: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let WindowSize = UIScreen.mainScreen().bounds
        self.maxSize = WindowSize.size
        
        profileImage = UIImageView(frame: CGRectMake(ImagePadding, ImagePadding, ImageSize, ImageSize))
        self.contentView.addSubview(profileImage)
        nameLabel = UILabel(frame: CGRectMake(ImageSize + ImagePadding * 4 , ImagePadding, self.maxSize.width - (ImagePadding * 5 + ImageSize), DefaultLineHeigth))
        self.contentView.addSubview(nameLabel)
        screenNameLabel = UILabel(frame: CGRectMake(ImageSize + ImagePadding * 4, DefaultLineHeigth + ImagePadding * 1, self.maxSize.width - (ImagePadding * 5 + ImageSize), DefaultLineHeigth))
        self.contentView.addSubview(screenNameLabel)
        bodyLabel = UILabel(frame: CGRectMake(ImageSize + ImagePadding * 4, DefaultLineHeigth * 2 + ImagePadding * 2, self.maxSize.width - (ImagePadding * 5 + ImageSize), DefaultLineHeigth))
        self.contentView.addSubview(bodyLabel)
        postDetailLable = UILabel(frame: CGRectMake(ImageSize + ImagePadding * 4, 40, self.maxSize.width - (ImagePadding * 5 + ImageSize), DefaultLineHeigth))
        self.contentView.addSubview(postDetailLable)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(dict: NSDictionary) {
        
        
        //------------------------------------
        //  profileImageLabel
        //------------------------------------
        var error = NSError?()
        var image_url = NSURL.URLWithString(dict.objectForKey("user")?.objectForKey("profile_image_url") as NSString)
        profileImage.image = UIImage(data: NSData.dataWithContentsOfURL(image_url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error))
        profileImage.sizeToFit()
        //------------------------------------
        //  nameLabel
        //------------------------------------
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.text = dict.objectForKey("user")?.objectForKey("name") as NSString
        nameLabel.font = UIFont.systemFontOfSize(DefaultFontSize)

        
        //------------------------------------
        //  screenNameLabel
        //------------------------------------
        screenNameLabel.textAlignment = NSTextAlignment.Left
        screenNameLabel.textColor = UIColor.grayColor()
        let screen_name = dict.objectForKey("user")?.objectForKey("screen_name") as NSString
        screenNameLabel.text = "@" + screen_name
        screenNameLabel.font = UIFont.systemFontOfSize(DefaultFontSize)
        //------------------------------------
        //  bodyLabel
        //------------------------------------
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = NSTextAlignment.Left
        bodyLabel.textColor = UIColor.blackColor()
        bodyLabel.text = dict.objectForKey("text") as NSString
        bodyLabel.font = UIFont.systemFontOfSize(DefaultFontSize)
        bodyLabel.sizeToFit()
        
        //------------------------------------
        //  postDetail
        //------------------------------------
        postDetailLable.textAlignment = NSTextAlignment.Left
        postDetailLable.textColor = UIColor.grayColor()
        postDetailLable.text = TwitterAPIClient.createdAtToString(dict.objectForKey("created_at") as NSString)
        postDetailLable.font = UIFont.systemFontOfSize(11)
        postDetailLable.frame.origin.y = bodyLabel.frame.origin.y + bodyLabel.frame.size.height + ImagePadding
        
        self.totalHeight  = ImagePadding * 4 + bodyLabel.frame.size.height + nameLabel.frame.size.height + screenNameLabel.frame.size.height + postDetailLable.frame.size.height
    }
    
    func cellHeight() -> CGFloat {
        if (self.totalHeight > 60) {
            return self.totalHeight
        } else {
            return 60
        }
    }
    

}
