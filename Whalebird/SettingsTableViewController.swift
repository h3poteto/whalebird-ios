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
import SVProgressHUD

class SettingsTableViewController: UITableViewController{
    //============================================
    //  instance variables
    //============================================
    var twitterAccounts = NSArray()
    var notificationBackgroundFlag: Bool = true
    var notificationReplyFlag: Bool = true
    var notificationFavFlag: Bool = true
    var notificationRTFlag: Bool = true
    var notificationDMFlag: Bool = true
    var deviceToken = String?("")
    
    var account: ACAccount?
    var accountStore: ACAccountStore?
    
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = NSLocalizedString("Title", tableName: "Settings", comment: "")
        self.tabBarItem.image = UIImage(named: "Settings-Line")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    // 表示時にインジケータを消そう
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
        // ログインからの復帰時に更新する必要がある
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellCount = Int(0)
        switch(section) {
        case 0:
            cellCount = 3
            break
        case 1:
            cellCount = 1
            break
        case 2:
            cellCount = 4
            break
        case 3:
            cellCount = 2
            break
        case 4:
            cellCount = 1
            break
        case 5:
            cellCount = 3
            break
        default:
            break
        }
        return cellCount
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = String?("")
        switch(section) {
        case 0:
            sectionTitle = NSLocalizedString("AccountSetting", tableName: "Settings", comment: "")
            break
        case 1:
            sectionTitle = NSLocalizedString("NotificationSetting", tableName: "Settings", comment: "")
            break
        case 2:
            sectionTitle = NSLocalizedString("DetailNotificationSetting", tableName: "Settings", comment: "")
            break
        case 3:
            sectionTitle = NSLocalizedString("DisplaySetting", tableName: "Settings", comment: "")
            break
        case 4:
            sectionTitle = NSLocalizedString("UpdateTweetSetting", tableName: "Settings", comment: "")
            break
        case 5:
            sectionTitle = NSLocalizedString("About", tableName: "Settings", comment: "")
            break
        default:
            sectionTitle = ""
            break
        }
        return sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let header:UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            header.textLabel!.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var sectionTitle = String?("")
        switch(section) {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            sectionTitle = NSLocalizedString("AfterRestart", tableName: "Settings", comment: "")
            break
        case 4:
            break
        case 5:
            break
        default:
            sectionTitle = ""
            break
        }
        return sectionTitle
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel!.font = UIFont(name: TimelineViewCell.NormalFont, size: 13)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        var cellTitle = String?("")
        var cellDetailTitle = String?("")
        
        switch((indexPath as NSIndexPath).section) {
        case 0:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                cellTitle = NSLocalizedString("AccountName", tableName: "Settings", comment: "")
                let userDefault = UserDefaults.standard
                cellDetailTitle = userDefault.string(forKey: "username")
                break
            case 1:
                cellTitle = NSLocalizedString("DisconnectAccount", tableName: "Settings", comment: "")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            case 2:
                cellTitle = NSLocalizedString("Profile", tableName: "Settings", comment: "")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                break
            default:
                break
            }
            break
        case 1:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                cellTitle = NSLocalizedString("BackgroundNotification", tableName: "Settings", comment: "")
                let notificationBackgroundSwitch = UISwitch(frame: CGRect.zero)
                let userDefault = UserDefaults.standard
                if (userDefault.object(forKey: "notificationBackgroundFlag") != nil) {
                    self.notificationBackgroundFlag = userDefault.bool(forKey: "notificationBackgroundFlag")
                }
                notificationBackgroundSwitch.isOn = self.notificationBackgroundFlag
                notificationBackgroundSwitch.addTarget(self, action: #selector(SettingsTableViewController.tappedNotificationBackgroundSwitch), for: UIControlEvents.touchUpInside)
                cell.accessoryView = notificationBackgroundSwitch
                break
            default:
                break
            }
            break
        case 2:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                cellTitle = NSLocalizedString("ReplyNotification", tableName: "Settings", comment: "")
                let notificationReplySwitch = UISwitch(frame: CGRect.zero)
                let userDefault = UserDefaults.standard
                if (userDefault.object(forKey: "notificationReplyFlag") != nil) {
                    self.notificationReplyFlag = userDefault.bool(forKey: "notificationReplyFlag")
                }
                notificationReplySwitch.isOn = self.notificationReplyFlag
                notificationReplySwitch.addTarget(self, action: #selector(SettingsTableViewController.tappedNotificationReplySwitch), for: UIControlEvents.touchUpInside)
                cell.accessoryView = notificationReplySwitch
                break
            case 1:
                cellTitle = NSLocalizedString("FavoriteNotification", tableName: "Settings", comment: "")
                let notificationFavSwitch = UISwitch(frame: CGRect.zero)
                let userDefault = UserDefaults.standard
                if (userDefault.object(forKey: "notificationFavFlag") != nil) {
                    self.notificationFavFlag = userDefault.bool(forKey: "notificationFavFlag")
                }
                notificationFavSwitch.isOn = self.notificationFavFlag
                notificationFavSwitch.addTarget(self, action: #selector(SettingsTableViewController.tappedNotificationFavSwitch), for: UIControlEvents.touchUpInside)
                cell.accessoryView = notificationFavSwitch
                break
            case 2:
                cellTitle = NSLocalizedString("RetweetNotification", tableName: "Settings", comment: "")
                let notificationRTSwitch = UISwitch(frame: CGRect.zero)
                let userDefault = UserDefaults.standard
                if (userDefault.object(forKey: "notificationRTFlag") != nil) {
                    self.notificationRTFlag = userDefault.bool(forKey: "notificationRTFlag")
                }
                notificationRTSwitch.isOn = self.notificationRTFlag
                notificationRTSwitch.addTarget(self, action: #selector(SettingsTableViewController.tappedNotificationRTSwitch), for: UIControlEvents.touchUpInside)
                cell.accessoryView = notificationRTSwitch
                break
            case 3:
                cellTitle = NSLocalizedString("DMNotification", tableName: "Settings", comment: "")
                let notificationDMSwitch = UISwitch(frame: CGRect.zero)
                let userDefault = UserDefaults.standard
                if (userDefault.object(forKey: "notificationDMFlag") != nil) {
                    self.notificationDMFlag = userDefault.bool(forKey: "notificationDMFlag")
                }
                notificationDMSwitch.isOn = self.notificationDMFlag
                notificationDMSwitch.addTarget(self, action: #selector(SettingsTableViewController.tappedNotificationDMSwitch), for: UIControlEvents.touchUpInside)
                cell.accessoryView = notificationDMSwitch
                break
            default:
                break
            }
            break
        case 3:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                cellTitle = NSLocalizedString("DisplayName", tableName: "Settings", comment: "")
                let userDefault = UserDefaults.standard
                let nameType = userDefault.integer(forKey: "displayNameType") as Int
                switch(nameType) {
                case 1:
                    cellDetailTitle = NSLocalizedString("DisplayNameTypeBoth", tableName: "Settings", comment: "")
                    break
                case 2:
                    cellDetailTitle = NSLocalizedString("DisplayNameTypeScreen", tableName: "Settings", comment: "")
                    break
                case 3:
                    cellDetailTitle = NSLocalizedString("DisplayNameTypeName", tableName: "Settings", comment: "")
                    break
                default:
                    cellDetailTitle = NSLocalizedString("DisplayNameTypeBoth", tableName: "Settings", comment: "")
                    break
                }
                break
            case 1:
                cellTitle = NSLocalizedString("Time", tableName: "Settings", comment: "")
                let userDefault = UserDefaults.standard
                let timeType = userDefault.integer(forKey: "displayTimeType") as Int
                switch(timeType) {
                case 1:
                    cellDetailTitle = NSLocalizedString("DisplayTimeTypeAbsolute", tableName: "Settings", comment: "")
                    break
                case 2:
                    cellDetailTitle = NSLocalizedString("DisplayTimeTypeRelative", tableName: "Settings", comment: "")
                    break
                default:
                    cellDetailTitle = NSLocalizedString("DisplayTimeTypeAbsolute", tableName: "Settings", comment: "")
                    break
                }
                break
            default:
                break
            }
            break
        case 4:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                cellTitle = NSLocalizedString("Position", tableName: "Settings", comment: "")
                let userDefault = UserDefaults.standard
                let timeType = userDefault.integer(forKey: "afterUpdatePosition") as Int
                switch(timeType) {
                case 1:
                    cellDetailTitle = NSLocalizedString("PositionTypeTop", tableName: "Settings", comment: "")
                    break
                case 2:
                    cellDetailTitle = NSLocalizedString("PositionTypeCurrent", tableName: "Settings", comment: "")
                    break
                default:
                    cellDetailTitle = NSLocalizedString("PositionTypeTop", tableName: "Settings", comment: "")
                    break
                }
                break
            default:
                break
            }
            break
        case 5:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                cellTitle = NSLocalizedString("Contact", tableName: "Settings", comment: "")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                break
            case 1:
                cellTitle = NSLocalizedString("Help", tableName: "Settings", comment: "")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                break
            case 2:
                cellTitle = NSLocalizedString("@whalebirdorg", tableName: "Settings", comment: "")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                break
            default:
                break
            }
            break
        default:
            break
        }
        
        cell.textLabel?.text = cellTitle
        cell.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
        cell.detailTextLabel?.text = cellDetailTitle
        cell.detailTextLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch((indexPath as NSIndexPath).section) {
        case 0:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                let loginViewController = LoginViewController()
                self.navigationController?.pushViewController(loginViewController, animated: true)
                break
            case 1:
                let alertController = UIAlertController(title: NSLocalizedString("DisconnectAccountTitle", tableName: "Settings", comment: ""), message: NSLocalizedString("DisconnectAccountMessage", tableName: "Settings", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let cOkAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: { (aAction) -> Void in
                    self.removeAccountInfo()
                })
                let cCloseAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cCloseAction)
                alertController.addAction(cOkAction)
                self.present(alertController, animated: true, completion: nil)
                break
            case 2:
                let userDefault = UserDefaults.standard
                if let username = userDefault.string(forKey: "username") {
                    let profileViewController = ProfileViewController(aScreenName: username)
                    profileViewController.myself = true
                    self.navigationController?.pushViewController(profileViewController, animated: true)
                }
                break
            default:
                break
            }
            break
        case 1:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                break
            default:
                break
            }
            break
        case 2:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                break
            default:
                break
            }
            break
        case 3:
            switch((indexPath as NSIndexPath).row) {
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
        case 4:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                self.stackAfterUpdateType()
                break
            default:
                break
            }
            break
        case 5:
            switch((indexPath as NSIndexPath).row) {
            case 0:
                let inquiryView = WebViewController(aOpenURL: "inquiries/new", aTitle: NSLocalizedString("Contact", tableName: "Settings", comment: ""))
                self.navigationController?.pushViewController(inquiryView, animated: true)
                break
            case 1:
                let helpView = WebViewController(aOpenURL: "helps", aTitle: NSLocalizedString("Help", tableName: "Settings", comment: ""))
                self.navigationController?.pushViewController(helpView, animated: true)
                break
            case 2:
                let reply = NewTweetViewController(aTweetBody: "@whalebirdorg ", aReplyToID: nil, aTopCursor: nil)
                self.navigationController?.pushViewController(reply, animated: true)
                break
            default:
                break
            }
            break
        default:
            break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func stackDisplayNameType() {
        
        let nameTypeSheet = UIAlertController(title: NSLocalizedString("DisplayName", tableName: "Settings", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let nameAndScreenAction = UIAlertAction(title: NSLocalizedString("DisplayNameTypeBoth", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(1, forKey: "displayNameType")
            self.tableView.reloadData()
        }
        let screenAction = UIAlertAction(title: NSLocalizedString("DisplayNameTypeScreen", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(2, forKey: "displayNameType")
            self.tableView.reloadData()
        }
        let nameAction = UIAlertAction(title: NSLocalizedString("DisplayNameTypeName", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(3, forKey: "displayNameType")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        nameTypeSheet.addAction(nameAndScreenAction)
        nameTypeSheet.addAction(screenAction)
        nameTypeSheet.addAction(nameAction)
        nameTypeSheet.addAction(cancelAction)
        self.present(nameTypeSheet, animated: true, completion: nil)
    }
    
    func stackDisplayTimeType() {
        
        let timeTypeSheet = UIAlertController(title: NSLocalizedString("Time", tableName: "Settings", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let absoluteTimeAction = UIAlertAction(title: NSLocalizedString("DisplayTimeTypeAbsolute", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(1, forKey: "displayTimeType")
            self.tableView.reloadData()
        }
        let relativeTimeAction = UIAlertAction(title: NSLocalizedString("DisplayTimeTypeRelative", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(2, forKey: "displayTimeType")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        timeTypeSheet.addAction(absoluteTimeAction)
        timeTypeSheet.addAction(relativeTimeAction)
        timeTypeSheet.addAction(cancelAction)
        self.present(timeTypeSheet, animated: true, completion: nil)
    }
    
    func stackAfterUpdateType() {
        let updateTypeSheet = UIAlertController(title: NSLocalizedString("Position", tableName: "Settings", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let topAction = UIAlertAction(title: NSLocalizedString("PositionTypeTop", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(1, forKey: "afterUpdatePosition")
            self.tableView.reloadData()
        }
        let currentAction = UIAlertAction(title: NSLocalizedString("PositionTypeCurrent", tableName: "Settings", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            let userDefault = UserDefaults.standard
            userDefault.set(2, forKey: "afterUpdatePosition")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        updateTypeSheet.addAction(topAction)
        updateTypeSheet.addAction(currentAction)
        updateTypeSheet.addAction(cancelAction)
        self.present(updateTypeSheet, animated: true, completion: nil)
    }

    
    @objc func tappedNotificationBackgroundSwitch() {
        let userDefault = UserDefaults.standard
        userDefault.set(!self.notificationBackgroundFlag, forKey: "notificationBackgroundFlag")

        self.notificationBackgroundFlag = !self.notificationBackgroundFlag
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func tappedNotificationReplySwitch() {
        let userDefault = UserDefaults.standard
        userDefault.set(!self.notificationReplyFlag, forKey: "notificationReplyFlag")
        self.notificationReplyFlag = !self.notificationReplyFlag
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func tappedNotificationFavSwitch() {
        let userDefault = UserDefaults.standard
        userDefault.set(!self.notificationFavFlag, forKey: "notificationFavFlag")
        self.notificationFavFlag = !self.notificationFavFlag
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func tappedNotificationRTSwitch() {
        let userDefault = UserDefaults.standard
        userDefault.set(!self.notificationRTFlag, forKey: "notificationRTFlag")
        self.notificationRTFlag = !self.notificationRTFlag
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func tappedNotificationDMSwitch() {
        let userDefault = UserDefaults.standard
        userDefault.set(!self.notificationDMFlag, forKey: "notificationDMFlag")
        self.notificationDMFlag = !self.notificationDMFlag
        SVProgressHUD.showDismissableLoad(with: NSLocalizedString("Cancel", comment: ""))
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) -> Void in
            SVProgressHUD.dismiss()
        }
    }
    
    func removeAccountInfo() {
        let userDefault = UserDefaults.standard
        
        // whalebirdからのログアウト
        let params = Dictionary<String, AnyObject>()
        WhalebirdAPIClient.sharedClient.deleteSsessionAPI("users/sign_out.json", params: params) { (operation) -> Void in
            // sessionの削除
            WhalebirdAPIClient.sharedClient.removeSession()
            
            // timelineやlist情報もすべて削除する必要がある
            userDefault.set(nil, forKey: "username")
            self.tableView.reloadData()
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let controllers = appDelegate.rootController.viewControllers {
                    for navController in controllers {
                        if let targetController = (navController as? UINavigationController)!.topViewController {
                            if targetController.isKind(of: TimelineTableViewController.self) {
                                (targetController as! TimelineTableViewController).clearData()
                            }
                            if targetController.isKind(of: ReplyTableViewController.self) {
                                (targetController as! ReplyTableViewController).clearData()
                            }
                            if targetController.isKind(of: DirectMessageTableViewController.self) {
                                (targetController as! DirectMessageTableViewController).clearData()
                            }
                            if targetController.isKind(of: ListTableViewController.self) {
                                (targetController as! ListTableViewController).clearData()
                            }
                        }
                    }
                }
            }
        }
    }
}
