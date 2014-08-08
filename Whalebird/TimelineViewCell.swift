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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(dict: NSDictionary) {
        let WindowSize = UIScreen.mainScreen().bounds
        self.maxSize = WindowSize.size
        
        
        //------------------------------------
        //  profileImageLabel
        //------------------------------------
        var error = NSError?()
        var image_url = NSURL(fileURLWithPath: dict.objectForKey("user").objectForKey("profile_image_url") as NSString)
        profileImage = UIImageView(frame: CGRectMake(ImagePadding, ImagePadding, ImageSize, ImageSize))
        profileImage = UIImageView(image: UIImage(data: NSData.dataWithContentsOfURL(image_url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)))
        self.contentView.addSubview(profileImage)
//        profileImage.sizeToFit()
        //------------------------------------
        //  nameLabel
        //------------------------------------
        nameLabel = UILabel(frame: CGRectMake(ImageSize + ImagePadding * 2 , ImagePadding, 100, 50))
        println(dict)
        nameLabel.text = dict.objectForKey("user").objectForKey("name") as NSString
        nameLabel.font = UIFont.systemFontOfSize(13)
        nameLabel.sizeToFit()
        
        //------------------------------------
        //  screenNameLabel
        //------------------------------------
        //------------------------------------
        //  bodyLabel
        //------------------------------------
        self.contentView.addSubview(nameLabel)
        self.totalHeight  = profileImage.frame.size.height + ImageSize * 2
    }
    
    func cellHeight() -> CGFloat {
        return self.totalHeight
    }
    

}
