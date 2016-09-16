//
//  AppDelegate.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import NoticeView
import SVProgressHUD
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var rootController: UITabBarController!
    var window: UIWindow?
    var alertPosition: CGFloat = 0.0


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics()])

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
                guard error == nil else {
                    // error handling
                    return
                }

                if granted {

                    // デバイストークンを発行
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            let types: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert]
            let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerForRemoteNotifications()
            application.registerUserNotificationSettings(notificationSettings)
        }


        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        // 共通フォント設定
        if let tabBarFont: UIFont = UIFont(name: TimelineViewCell.NormalFont, size: 10) {
            let tabBarFontDict = [NSFontAttributeName: tabBarFont]
            UITabBarItem.appearance().setTitleTextAttributes(tabBarFontDict, for: UIControlState())
            UITabBarItem.appearance().setTitleTextAttributes(tabBarFontDict, for: UIControlState.selected)
        }
        if let navBarFont: UIFont = UIFont(name: TimelineViewCell.BoldFont, size: 16) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navBarFont]
        }
        if let barButtonFont: UIFont = UIFont(name: TimelineViewCell.NormalFont, size: 16) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: barButtonFont], for: UIControlState())
        }
        
        // tabBar設定
        self.rootController = UITabBarController()
        self.rootController.delegate = self
        let timelineViewController = TimelineTableViewController()
        let timelineNavigationController = UINavigationController(rootViewController: timelineViewController)
        let replyViewController = ReplyTableViewController()
        let replyNavigationController = UINavigationController(rootViewController: replyViewController)
        let listViewController = ListTableViewController()
        let listNavigationController = UINavigationController(rootViewController: listViewController)
        let directMessageViewController = DirectMessageTableViewController()
        let directMessageNavigationController = UINavigationController(rootViewController: directMessageViewController)
        let settingsViewController = SettingsTableViewController(style: UITableViewStyle.grouped)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        let controllers = NSArray(array: [timelineNavigationController, replyNavigationController, listNavigationController, directMessageNavigationController, settingsNavigationController])
        self.rootController.setViewControllers((controllers as? [UIViewController]), animated: true)
        self.window?.rootViewController = self.rootController
        self.window?.makeKeyAndVisible()
        
        if let navigationController = self.rootController.selectedViewController as? UINavigationController {
            self.alertPosition = navigationController.navigationBar.frame.origin.y + navigationController.navigationBar.frame.size.height
        }
        
        // RemoteNotificationからのアプリ起動処理
        if (launchOptions != nil) {
            if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
                if (userInfo["aps"] as? [AnyHashable: Any])?["category"] as? String == "reply" {
                    let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                    let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                    NotificationUnread.decrementUnreadBadge()
                    // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                    (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailView, animated: true)
                } else if (userInfo["aps"] as? [AnyHashable: Any])?["category"] as? String == "direct_message" {
                    let messageModel = MessageModel(notificationDict: userInfo as [NSObject : AnyObject])
                    let messageViewController = MessageDetailViewController(aMessageModel: messageModel)
                    
                    NotificationUnread.decrementUnreadBadge()
                    (self.rootController.selectedViewController as! UINavigationController).pushViewController(messageViewController, animated: true)
                } else if (userInfo["aps"] as? [AnyHashable: Any])?["category"] as? String == "retweet" {
                    if (userInfo["id"] != nil) {
                        let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                        let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailView, animated: true)
                    }
                } else if (userInfo["aps"] as? [AnyHashable: Any])?["category"] as? String == "favorite" {
                    if (userInfo["id"] != nil) {
                        let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                        let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailView, animated: true)
                    }
                }
            }

        }
        
        // iOS7以下を切り捨てる
        /*
        if greaterThanOrEqual(8, minorVersion: 0, patchVersion: 0) {
        } else {
            print("システムバージョン < iOS 8.0.0")
            let systemAlert = UIAlertController(title: "iOSのアップデートをしてください", message: "対応OSはiOS8.0以上です", preferredStyle: UIAlertControllerStyle.alert)
            let closeAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            })
            systemAlert.addAction(closeAction)
            self.rootController.present(systemAlert, animated: true, completion: nil)
        }
        */
        // 認証前なら設定画面に飛ばす
        let userDefault = UserDefaults.standard
        if ( userDefault.object(forKey: "username") == nil) {
            let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
            notice?.alpha = 0.8
            notice?.originY = self.alertPosition
            notice?.show()
            let loginSettingsView = SettingsTableViewController()
            if let selectedController = self.rootController.selectedViewController as? UINavigationController {
                selectedController.pushViewController(loginSettingsView, animated: true)
            }
        }
        
        
        // SVProgressHUDの表示スタイル設定
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.hudTapped(_:)), name: NSNotification.Name.SVProgressHUDDidReceiveTouchEvent, object: nil)
        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setForegroundColor(UIColor.white)
        
        FriendsList.sharedClient.requestFriends()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        WhalebirdAPIClient.encodeClipboardURL()
        FriendsList.sharedClient.requestFriends()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // <>と" "(空白)を取る
        var token = String(format: "%@", deviceToken as CVarArg) as String
        let characterSet: CharacterSet = CharacterSet.init(charactersIn: "<>")
        token = token.trimmingCharacters(in: characterSet)
        token = token.replacingOccurrences(of: " ", with: "")
        let userDefault = UserDefaults.standard
        userDefault.set(token, forKey: "deviceToken")
        print("deviceToken: \(token)")
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) in
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        let userDefault = UserDefaults.standard
        if let aps = userInfo["aps"] as? NSDictionary {
            if let message = aps.object(forKey: "alert") as? String, let category = aps.object(forKey: "category") as? String {
                if (application.applicationState == UIApplicationState.active && (userDefault.object(forKey: "notificationForegroundFlag") == nil || userDefault.bool(forKey: "notificationForegroundFlag"))) {
                    // 起動中の通知
                    
                    if (userDefault.integer(forKey: "notificationType") == 2 ) {
                        // wbによる通知
                        let notice = WBSuccessNoticeView.successNotice(in: self.window, title: message)
                        notice?.alpha = 0.8
                        notice?.originY = self.alertPosition
                        notice?.show()
                    } else {
                        // デフォルトはアラート通知
                        switch(category) {
                        case "reply":
                            let alertController = UIAlertController(title: "Reply", message: message, preferredStyle: .alert)
                            let cOpenAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.default, handler: {action in
                                let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                                let detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)

                                NotificationUnread.decrementUnreadBadge()
                                // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                                (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                            })
                            let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.default, handler: {action in
                            })
                            alertController.addAction(cOkAction)
                            alertController.addAction(cOpenAction)
                            self.rootController.present(alertController, animated: true, completion: nil)
                            break
                        case "direct_message":
                            let alertController = UIAlertController(title: "DirectMessage", message: message, preferredStyle: .alert)
                            let cOpenAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                let messageModel = MessageModel(notificationDict: userInfo as [NSObject : AnyObject])
                                let messageViewController = MessageDetailViewController(aMessageModel: messageModel)
                                NotificationUnread.decrementUnreadBadge()
                                (self.rootController.selectedViewController as! UINavigationController).pushViewController(messageViewController, animated: true)
                            })
                            let cOkAction = UIAlertAction(title: "閉じる", style: .default, handler: { (action) -> Void in
                            })
                            alertController.addAction(cOkAction)
                            alertController.addAction(cOpenAction)
                            self.rootController.present(alertController, animated: true, completion: nil)
                            break
                        case "favorite":
                            // wbによる通知
                            let notice = WBSuccessNoticeView.successNotice(in: self.window, title: message)
                            notice?.alpha = 0.8
                            notice?.originY = self.alertPosition
                            notice?.show()
                            break
                        case "retweet":
                            // wbによる通知
                            let notice = WBSuccessNoticeView.successNotice(in: self.window, title: message)
                            notice?.alpha = 0.8
                            notice?.originY = self.alertPosition
                            notice?.show()
                            break
                        default:
                            break
                            
                        }
                    }
                } else if (application.applicationState != UIApplicationState.active) {
                    // 起動済みで通知から復旧した時
                    switch(category) {
                    case "reply":
                        let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                        let detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                        
                        NotificationUnread.decrementUnreadBadge()
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                        break
                    case "direct_message":
                        let messageModel = MessageModel(notificationDict: userInfo as [NSObject : AnyObject])
                        let messageViewController = MessageDetailViewController(aMessageModel: messageModel)
                        NotificationUnread.decrementUnreadBadge()
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(messageViewController, animated: true)
                        break
                    case "favorite":
                        if (userInfo["id"] != nil) {
                            let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                            let detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                            // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                            (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                        }
                        break
                    case "retweet":
                        if (userInfo["id"] != nil) {
                            let tweetModel = TweetModel(notificationDict: userInfo as [NSObject : AnyObject])
                            let detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                            // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                            (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }

    }
    
    func hudTapped(_ notification: Notification) {
        WhalebirdAPIClient.sharedClient.cancelRequest()
        SVProgressHUD.dismiss()
    }
    /*
    func greaterThanOrEqual(_ majorVersion: Int, minorVersion: Int, patchVersion: Int) -> Bool {
        // NSProcessInfo#isOperatingSystemAtLeastVersion による判別
        if ProcessInfo().responds(to: #selector(ProcessInfo.isOperatingSystemAtLeast(_:)(_:))) {
            let version = OperatingSystemVersion(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
            return ProcessInfo().isOperatingSystemAtLeast(version)
        }
        // UIDevice#systemVersion による判別
        let targetVarsion = shortedVersionNumber("\(majorVersion).\(minorVersion).\(patchVersion)")
        let systemVersion: String = shortedVersionNumber(UIDevice.current.systemVersion)
        return systemVersion.compare(targetVarsion, options: .numeric) != ComparisonResult.orderedAscending
    }*/
    
    func shortedVersionNumber(_ version: String) -> String  {
        let suffix = ".0"
        var shortedVersion = version
        while shortedVersion.hasSuffix(suffix) {
            let endIndex = shortedVersion.characters.count - suffix.characters.count
            let range = shortedVersion.characters.index(shortedVersion.startIndex, offsetBy: 0) ..< shortedVersion.characters.index(shortedVersion.startIndex, offsetBy: endIndex)
            shortedVersion = shortedVersion.substring(with: range)
        }
        return shortedVersion;
    }
}


