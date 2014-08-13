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
        //user_default.setValue(self.twitterAccounts[buttonIndex - 1], forKey: "account")
    }

}
