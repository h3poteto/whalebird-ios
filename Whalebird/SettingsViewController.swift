//
//  SettingsViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/13.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Accounts

class SettingsViewController: UIViewController, UIActionSheetDelegate {
    
    var twitterAccounts: NSArray!
    @IBOutlet var accountSelectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let WindowSize = UIScreen.mainScreen().bounds
        
        accountSelectButton = UIButton(frame: CGRectMake(100, 100, 150, 30))
        accountSelectButton.setTitle("Select Account", forState: .Normal)
        accountSelectButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        accountSelectButton.backgroundColor = UIColor.whiteColor()
        accountSelectButton.addTarget(self, action: "stackAccount", forControlEvents: .TouchUpInside)
        accountSelectButton.layer.cornerRadius = 10
        accountSelectButton.layer.borderWidth = 1
        accountSelectButton.layer.borderColor = UIColor.blueColor().CGColor
        accountSelectButton.center = CGPointMake(WindowSize.width / 2.0, 100)
        self.view.addSubview(accountSelectButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func stackAccount() {
        TwitterAPIClient.sharedClient().pickUpAccount { (accounts) in
            if (accounts.count > 0) {
                self.twitterAccounts = accounts
                var accounts_sheet = UIActionSheet(title: "Select Account", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
                for pick_account in accounts {
                    accounts_sheet.addButtonWithTitle(pick_account.username)
                }
                accounts_sheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
                accounts_sheet.showInView(self.view)
            } else {
                // alert表示
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        var user_default = NSUserDefaults.standardUserDefaults()
        user_default.setObject(self.twitterAccounts[buttonIndex - 1].username, forKey: "username")
        
        let params: Dictionary<String, String> = [
            "screen_name" : self.twitterAccounts[buttonIndex - 1].username
        ]
        
        TwitterAPIClient.sharedClient().getUserInfo(NSURL(string: "https://api.twitter.com/1.1/users/show.json"), params: params, callback: { user_info in

            var error = NSError?()
            let image_url:NSURL = NSURL.URLWithString(user_info.objectForKey("profile_image_url") as NSString)
            
            var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            var q_main: dispatch_queue_t = dispatch_get_main_queue()
            dispatch_async(q_global, {() in
                var image = UIImage(data: NSData.dataWithContentsOfURL(image_url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error))
                
                dispatch_async(q_main, {() in
                    UIGraphicsBeginImageContext(CGSizeMake(30, 30))
                    image.drawInRect(CGRectMake(0, 0, 30, 30))
                    var resize_image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    // 未解決：　labelには表示できるのに，なぜかtabbaritemには表示されない
                    var view_controllers: NSArray = self.tabBarController.viewControllers
                    // class名で判定したいけれど，viewControllersからclass名を判定できないのでobjectAtIndexでクリティカル指定
                    var target: UINavigationController! = view_controllers.objectAtIndex(1) as UINavigationController
                    target.tabBarItem = UITabBarItem(title: "Profile", image: resize_image, selectedImage: resize_image)
                })
            })

        })
    }

}
