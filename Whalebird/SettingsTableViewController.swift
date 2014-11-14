//
//  SettingsTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/25.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Accounts
import Social

class SettingsTableViewController: UITableViewController, UIActionSheetDelegate {
    
    var twitterAccounts: NSArray!
    var userstreamFlag: Bool = false
    var notificationForegroundFlag: Bool = true
    var notificationBackgroundFlag: Bool = true
    var notificationReplyFlag: Bool = true
    var notificationFavFlag: Bool = false
    var notificationRTFlag: Bool = false
    var notificationDMFlag: Bool = false
    var deviceToken = String?()
    
    var account: ACAccount!
    var accountStore: ACAccountStore!
    
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
        return 5
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
            cellCount = 5
            break
        case 3:
            cellCount = 2
            break
        case 4:
            cellCount = 1
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
            sectionTitle = "通知詳細設定"
            break
        case 3:
            sectionTitle = "表示設定"
            break
        case 4:
            sectionTitle = "Userstream"
            break
        default:
            sectionTitle = ""
            break
        }
        return sectionTitle
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var sectionTitle = String?()
        switch(section) {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            sectionTitle = "※再起動後に反映されます"
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
                cellTitle = "プロフィール"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                break
            default:
                break
            }
            break
        case 1:
            switch(indexPath.row) {
            case 0:
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
            case 1:
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
            default:
                break
            }
            break
        case 2:
            switch(indexPath.row) {
            case 0:
                cellTitle = "起動中の通知方法"
                var userDefault = NSUserDefaults.standardUserDefaults()
                var notificationType = userDefault.integerForKey("notificationType") as Int
                switch(notificationType) {
                case 1:
                    cellDetailTitle = "アラート表示"
                    break
                case 2:
                    cellDetailTitle = "ヘッダー通知"
                    break
                default:
                    cellDetailTitle = "アラート表示"
                    break
                }
                break
            case 1:
                cellTitle = "リプライ通知"
                var notificationReplySwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                if (userDefault.objectForKey("notificationReplyFlag") != nil) {
                    self.notificationReplyFlag = userDefault.boolForKey("notificationReplyFlag")
                }
                notificationReplySwitch.on = self.notificationReplyFlag
                notificationReplySwitch.addTarget(self, action: "tappedNotificationReplySwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = notificationReplySwitch
                break
            case 2:
                cellTitle = "Fav通知"
                var notificationFavSwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                self.notificationFavFlag = userDefault.boolForKey("notificationFavFlag")
                notificationFavSwitch.on = self.notificationFavFlag
                notificationFavSwitch.addTarget(self, action: "tappedNotificationFavSwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = notificationFavSwitch
                break
            case 3:
                cellTitle = "RT通知"
                var notificationRTSwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                self.notificationRTFlag = userDefault.boolForKey("notificationRTFlag")
                notificationRTSwitch.on = self.notificationRTFlag
                notificationRTSwitch.addTarget(self, action: "tappedNotificationRTSwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = notificationRTSwitch
                break
            case 4:
                cellTitle = "DM通知"
                var notificationDMSwitch = UISwitch(frame: CGRect.zeroRect)
                var userDefault = NSUserDefaults.standardUserDefaults()
                self.notificationDMFlag = userDefault.boolForKey("notificationDMFlag")
                notificationDMSwitch.on = self.notificationDMFlag
                notificationDMSwitch.addTarget(self, action: "tappedNotificationDMSwitch", forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = notificationDMSwitch
                break
            default:
                break
            }
            break
        case 3:
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
        case 4:
            switch(indexPath.row) {
            case 0:
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
        default:
            break
        }
        
        cell.textLabel.text = cellTitle
        cell.detailTextLabel?.text = cellDetailTitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                var loginViewController = LoginViewController()
                self.navigationController!.pushViewController(loginViewController, animated: true)
                break
            case 1:
                var profileViewController = ProfileViewController()
                self.navigationController!.pushViewController(profileViewController, animated: true)
                break
            default:
                break
            }
            break
        case 1:
            switch(indexPath.row) {
            case 0:
                break
            case 1:
                break
            default:
                break
            }
            break
        case 2:
            switch(indexPath.row) {
            case 0:
                self.stackNotificationType()
                break
            default:
                break
            }
            break
        case 3:
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

    
    func stackNotificationType() {
        var notificationTypeSheet = UIActionSheet(title: "通知方法選択", delegate: self, cancelButtonTitle: "キャンセル", destructiveButtonTitle: nil)
        notificationTypeSheet.tag = 1
        notificationTypeSheet.addButtonWithTitle("アラート表示")
        notificationTypeSheet.addButtonWithTitle("ヘッダー通知")
        notificationTypeSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        notificationTypeSheet.showInView(self.view)
    }
    
    func stackDisplayNameType() {
        // TODO: 設定をviewに反映させる
        var nameTypeSheet = UIActionSheet(title: "表示名選択", delegate: self, cancelButtonTitle: "キャンセル", destructiveButtonTitle: nil)
        nameTypeSheet.tag = 2
        nameTypeSheet.addButtonWithTitle("スクリーンネーム")
        nameTypeSheet.addButtonWithTitle("名前")
        nameTypeSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        nameTypeSheet.showInView(self.view)
    }
    
    func stackDisplayTimeType() {
        // TODO: 設定をViewに反映させる
        var timeTypeSheet = UIActionSheet(title: "時刻表示名選択", delegate: self, cancelButtonTitle: "キャンセル", destructiveButtonTitle: nil)
        timeTypeSheet.tag = 3
        timeTypeSheet.addButtonWithTitle("絶対時刻")
        timeTypeSheet.addButtonWithTitle("相対時刻")
        timeTypeSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        timeTypeSheet.showInView(self.view)
    }
    
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch(actionSheet.tag) {
        case 0:
            break
        case 1:
            if (buttonIndex > 0 && buttonIndex <= 2) {
                var userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setInteger(buttonIndex, forKey: "notificationType")
                tableView.reloadData()
            }
            break
        case 2:
            if (buttonIndex > 0 && buttonIndex <= 2) {
                var userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setInteger(buttonIndex, forKey: "displayNameType")
                tableView.reloadData()
            }
            break
        case 3:
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
        if (self.userstreamFlag) {
            // trueだった場合は問答無用で切る
            userDefault.setBool(!self.userstreamFlag, forKey: "userstreamFlag")
            self.userstreamFlag = !self.userstreamFlag
            UserstreamAPIClient.sharedClient.stopStreaming({ () -> Void in
            })
        } else {
            // userdefaultに保存してあるusernameと同じ名前のaccountsを発掘してきてuserstreamを発火
            self.accountStore = ACAccountStore()
            var twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)!
            self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted, error) -> Void in
                if (error != nil) {
                    println(error)
                }
                if (!granted) {
                    var alertController = UIAlertController(title: "Permission Error", message: "アカウントへのアクセス権限がありません", preferredStyle: UIAlertControllerStyle.Alert)
                    var closeAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(closeAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                var twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
                if (twitterAccounts.count > 0) {
                    let username = userDefault.stringForKey("username")
                    var selected_account: ACAccount!
                    for aclist in twitterAccounts {
                        if (username == aclist.username) {
                            selected_account = aclist as ACAccount
                        }
                    }
                    if (selected_account == nil) {
                        self.tableView.reloadData()
                        self.accountAlert()
                    } else {
                        userDefault.setBool(!self.userstreamFlag, forKey: "userstreamFlag")
                        self.userstreamFlag = !self.userstreamFlag
                    }
                } else {
                    self.tableView.reloadData()
                    self.accountAlert()
                }
            }

        }
    }
    
    func tappedNotificationForegroundSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationForegroundFlag, forKey: "notificationForegroundFlag")
        self.notificationForegroundFlag = !self.notificationForegroundFlag
    }
    
    func tappedNotificationBackgroundSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationBackgroundFlag, forKey: "notificationBackgroundFlag")
        self.notificationBackgroundFlag = !self.notificationBackgroundFlag
        self.syncWhalebirdServer()
    }
    
    func tappedNotificationReplySwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationReplyFlag, forKey: "notificationReplyFlag")
        self.notificationReplyFlag = !self.notificationReplyFlag
        self.syncWhalebirdServer()
    }
    
    func tappedNotificationFavSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationFavFlag, forKey: "notificationFavFlag")
        self.notificationFavFlag = !self.notificationFavFlag
        self.syncWhalebirdServer()
    }
    
    func tappedNotificationRTSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationRTFlag, forKey: "notificationRTFlag")
        self.notificationRTFlag = !self.notificationRTFlag
        self.syncWhalebirdServer()
    }
    
    func tappedNotificationDMSwitch() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(!self.notificationDMFlag, forKey: "notificationDMFlag")
        self.notificationDMFlag = !self.notificationDMFlag
        self.syncWhalebirdServer()
    }
    
    func syncWhalebirdServer() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        self.deviceToken = userDefault.stringForKey("deviceToken")
        var params: Dictionary<String, AnyObject>
        if (self.deviceToken != nil) {
            params = [
                "notification" : self.notificationBackgroundFlag,
                "reply" : self.notificationReplyFlag,
                "retweet" : self.notificationRTFlag,
                "favorite" : self.notificationFavFlag,
                "direct_message" : self.notificationDMFlag,
                "device_token" : self.deviceToken!
            ]
        } else {
            params = [
                "notification" : self.notificationBackgroundFlag,
                "reply" : self.notificationReplyFlag,
                "retweet" : self.notificationRTFlag,
                "favorite" : self.notificationFavFlag,
                "direct_message" : self.notificationDMFlag
            ]
        }
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/update_settings.json", params: parameter) { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                println(operation)
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func accountAlert() {
        var alertController = UIAlertController(title: "Account not found", message: "iPhoneの設定からtwitterアカウントを登録してください", preferredStyle: UIAlertControllerStyle.Alert)
        let closeAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        alertController.addAction(closeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
