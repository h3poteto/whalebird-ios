//
//  SettingsTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/25.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIActionSheetDelegate {
    
    var twitterAccounts: NSArray!
    var userstreamFlag: Bool = true
    var notificationForegroundFlag: Bool = true
    var notificationBackgroundFlag: Bool = true
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "設定"
        self.tabBarItem.image = UIImage(named: "Settings-Line.png")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let WindowSize = UIScreen.mainScreen().bounds
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellCount = Int(0)
        switch(section) {
        case 0:
            cellCount = 2
            break
        case 1:
            cellCount = 2
            break
        case 2:
            cellCount = 2
            break
        default:
            break
        }
        return cellCount
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = String?()
        switch(section) {
        case 0:
            sectionTitle = "アカウント設定"
            break
        case 1:
            sectionTitle = "通知設定"
            break
        case 2:
            sectionTitle = "表示設定"
            break
        default:
            sectionTitle = ""
            break
        }
        return sectionTitle
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        var cellTitle = String?()
        var cellDetailTitle = String?()
        
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                cellTitle = "アカウント"
                var userDefault = NSUserDefaults.standardUserDefaults()
                cellDetailTitle = userDefault.stringForKey("username")
                break
            case 1:
                cellTitle = "Userstream"
                var userstreamSwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                if (userDefault.objectForKey("userstreamFlag") != nil) {
                    self.userstreamFlag = userDefault.boolForKey("userstreamFlag")
                }
                userstreamSwitch.on = self.userstreamFlag
                userstreamSwitch.addTarget(self, action: "tappedUserstreamSwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = userstreamSwitch
                break
            default:
                break
            }
            break
        case 1:
            switch(indexPath.row) {
            case 0:
                cellTitle = "起動中の通知"
                var notificationForegroundSwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                if (userDefault.objectForKey("notificationForegroundFlag") != nil) {
                    self.notificationForegroundFlag = userDefault.boolForKey("notificationForegroundFlag")
                }
                notificationForegroundSwitch.on = self.notificationForegroundFlag
                notificationForegroundSwitch.addTarget(self, action: "tappedNotificationForegroundSwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = notificationForegroundSwitch
                break
            case 1:
                cellTitle = "バックグラウンド時の通知"
                var notificationBackgroundSwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                if (userDefault.objectForKey("notificationBackgroundFlag") != nil) {
                    self.notificationBackgroundFlag = userDefault.boolForKey("notificationBackgroundFlag")
                }
                notificationBackgroundSwitch.on = self.notificationBackgroundFlag
                notificationBackgroundSwitch.addTarget(self, action: "tappedNotificationBackgroundSwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = notificationBackgroundSwitch
                break
            default:
                break
            }
            break
        case 2:
            switch(indexPath.row) {
            case 0:
                cellTitle = "表示名"
                var userDefault = NSUserDefaults.standardUserDefaults()
                var nameType = userDefault.integerForKey("displayNameType") as Int
                switch(nameType) {
                case 1:
                    cellDetailTitle = "スクリーンネーム"
                    break
                case 2:
                    cellDetailTitle = "名前"
                    break
                default:
                    cellDetailTitle = "スクリーンネーム"
                    break
                }
                break
            case 1:
                cellTitle = "時刻"
                var userDefault = NSUserDefaults.standardUserDefaults()
                var timeType = userDefault.integerForKey("displayTimeType") as Int
                switch(timeType) {
                case 1:
                    cellDetailTitle = "絶対時刻"
                    break
                case 2:
                    cellDetailTitle = "相対時刻"
                    break
                default:
                    cellDetailTitle = "絶対時刻"
                    break
                }
                break
            default:
                break
            }
            break
        default:
            break
        }
        
        cell.textLabel?.text = cellTitle
        cell.detailTextLabel?.text = cellDetailTitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                self.stackAccount()
                break
            case 1:
                break
            default:
                break
            }
            break
        case 1:
            break
        case 2:
            switch(indexPath.row) {
            case 0:
                self.stackDisplayNameType()
                break
            case 1:
                self.stackDisplayTimeType()
                break
            default:
                break
            }
            break
        default:
            break
        }
    }


    
    func stackAccount() {
        TwitterAPIClient.sharedClient.pickUpAccount({accounts in
            // クロージャーの処理は終了後実行されているが，画面への描画プロセスがメインのキューに来ていない
            // 非同期だけどキューを分けて処理をすることで対応
            var q_main = dispatch_get_main_queue()
            if (accounts.count > 0) {
                dispatch_async(q_main, {()->Void in
                    self.twitterAccounts = accounts
                    var accountsSheet = UIActionSheet(title: "アカウント選択", delegate: self, cancelButtonTitle: "キャンセル", destructiveButtonTitle: nil)
                    accountsSheet.tag = 0
                    
                    for pick_account in accounts {
                        accountsSheet.addButtonWithTitle(pick_account.username)
                    }
                    accountsSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
                    accountsSheet.showInView(self.view)
                })
            } else {
                dispatch_async(q_main, {()->Void in
                    // alert表示
                    var alertController = UIAlertController(title: "アカウントが見つかりません", message: "twitterアカウントを設定してください", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        })
    }
    
    func stackDisplayNameType() {
        var nameTypeSheet = UIActionSheet(title: "表示名選択", delegate: self, cancelButtonTitle: "キャンセル", destructiveButtonTitle: nil)
        nameTypeSheet.tag = 1
        nameTypeSheet.addButtonWithTitle("スクリーンネーム")
        nameTypeSheet.addButtonWithTitle("名前")
        nameTypeSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        nameTypeSheet.showInView(self.view)
    }
    
    func stackDisplayTimeType() {
        var timeTypeSheet = UIActionSheet(title: "時刻表示名選択", delegate: self, cancelButtonTitle: "キャンセル", destructiveButtonTitle: nil)
        timeTypeSheet.tag = 2
        timeTypeSheet.addButtonWithTitle("絶対時刻")
        timeTypeSheet.addButtonWithTitle("相対時刻")
        timeTypeSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        timeTypeSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch(actionSheet.tag) {
        case 0:
            var user_default = NSUserDefaults.standardUserDefaults()
            if (buttonIndex <= self.twitterAccounts.count) {
                user_default.setObject(self.twitterAccounts[buttonIndex - 1].username, forKey: "username")
                tableView.reloadData()
/*
                let params: Dictionary<String, String> = [
                    "screen_name" : self.twitterAccounts[buttonIndex - 1].username
                ]
                
                TwitterAPIClient.sharedClient.getUserInfo(NSURL(string: "https://api.twitter.com/1.1/users/show.json"), params: params, callback: { user_info in
                    
                    var error = NSError?()
                    let image_url:NSURL = NSURL.URLWithString(user_info.objectForKey("profile_image_url") as NSString)
                    
                    var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    var q_main: dispatch_queue_t = dispatch_get_main_queue()
                    dispatch_async(q_global, {() in
                        var image = UIImage(data: NSData.dataWithContentsOfURL(image_url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error))

                        dispatch_async(q_main, {() in

                            
                            //  デザイン的に微妙なのでアイコンをtabのメニューに表示するのは廃止
                            UIGraphicsBeginImageContext(CGSizeMake(30, 30))
                            image.drawInRect(CGRectMake(0, 0, 30, 30))
                            var resizeImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            
                            var view_controllers: NSArray = self.tabBarController!.viewControllers!
                            // class名で判定したいけれど，viewControllersからclass名を判定できないのでobjectAtIndexでクリティカル指定
                            var target: UINavigationController! = view_controllers.objectAtIndex(3) as UINavigationController
                            var iconImage = resizeImage.imageWithRenderingMode(.AlwaysOriginal)
                            target.tabBarItem = UITabBarItem(title: "ユーザー", image: iconImage, selectedImage: iconImage)

                        })

                    })
                    
                })
*/
            }
            break
        case 1:
            if (buttonIndex > 0 && buttonIndex <= 2) {
                var userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setInteger(buttonIndex, forKey: "displayNameType")
                tableView.reloadData()
            }
            break
        case 2:
            if (buttonIndex > 0 && buttonIndex <= 2) {
                var userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setInteger(buttonIndex, forKey: "displayTimeType")
                tableView.reloadData()
            }
            break
        default:
            break
        }
    }

    func tappedUserstreamSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.userstreamFlag, forKey: "userstreamFlag")
    }
    
    func tappedNotificationForegroundSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationForegroundFlag, forKey: "notificationForegroundFlag")
    }
    
    func tappedNotificationBackgroundSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationBackgroundFlag, forKey: "notificationBackgroundFlag")
    }
}
