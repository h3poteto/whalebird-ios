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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var rootController: UITabBarController!
    var window: UIWindow?
    var alertPosition: CGFloat = 0.0


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics()])
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        var notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        

        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        // 共通フォント設定
        if let tabBarFont: UIFont = UIFont(name: TimelineViewCell.NormalFont, size: 10) {
            let tabBarFontDict = [NSFontAttributeName: tabBarFont]
            UITabBarItem.appearance().setTitleTextAttributes(tabBarFontDict, forState: UIControlState.Normal)
            UITabBarItem.appearance().setTitleTextAttributes(tabBarFontDict, forState: UIControlState.Selected)
        }
        if let navBarFont: UIFont = UIFont(name: TimelineViewCell.BoldFont, size: 16) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navBarFont]
        }
        if let barButtonFont: UIFont = UIFont(name: TimelineViewCell.NormalFont, size: 16) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: barButtonFont], forState: UIControlState.Normal)
        }
        var chdic = [
            "yes" : "asumiss"
        ]
        var dic = [
            "name" : "hoge",
            "child" : chdic
        ]
        // tabBar設定
        self.rootController = UITabBarController()
        self.rootController.delegate = self
        var timelineViewController = TimelineTableViewController()
        var timelineNavigationController = UINavigationController(rootViewController: timelineViewController)
        var replyViewController = ReplyTableViewController()
        var replyNavigationController = UINavigationController(rootViewController: replyViewController)
        var listViewController = ListTableViewController()
        var listNavigationController = UINavigationController(rootViewController: listViewController)
        var directMessageViewController = DirectMessageTableViewController()
        var directMessageNavigationController = UINavigationController(rootViewController: directMessageViewController)
        var settingsViewController = SettingsTableViewController(style: UITableViewStyle.Grouped)
        var settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        var controllers = NSArray(array: [timelineNavigationController, replyNavigationController, listNavigationController, directMessageNavigationController, settingsNavigationController])
        self.rootController.setViewControllers(controllers as [AnyObject], animated: true)
        self.window?.addSubview(self.rootController.view)
        self.window?.makeKeyAndVisible()
        
        if let navigationController = self.rootController.selectedViewController as? UINavigationController {
            self.alertPosition = navigationController.navigationBar.frame.origin.y + navigationController.navigationBar.frame.size.height
        }
        
        // RemoteNotificationからのアプリ起動処理
        if (launchOptions != nil) {
            if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                if (userInfo["aps"] as? [NSObject : AnyObject])?["category"] as? String == "reply" {
                    var tweetModel = TweetModel(notificationDict: userInfo)
                    var detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                    NotificationUnread.decrementUnreadBadge()
                    // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                    (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailView, animated: true)
                } else if (userInfo["aps"] as? [NSObject : AnyObject])?["category"] as? String == "direct_message" {
                    var messageModel = MessageModel(notificationDict: userInfo)
                    var messageViewController = MessageDetailViewController(aMessageModel: messageModel)
                    
                    NotificationUnread.decrementUnreadBadge()
                    (self.rootController.selectedViewController as! UINavigationController).pushViewController(messageViewController, animated: true)
                } else if (userInfo["aps"] as? [NSObject : AnyObject])?["category"] as? String == "retweet" {
                    if (userInfo["id"] != nil) {
                        var tweetModel = TweetModel(notificationDict: userInfo)
                        var detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailView, animated: true)
                    }
                } else if (userInfo["aps"] as? [NSObject : AnyObject])?["category"] as? String == "favorite" {
                    if (userInfo["id"] != nil) {
                        var tweetModel = TweetModel(notificationDict: userInfo)
                        var detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailView, animated: true)
                    }
                }
            }

        }
        
        // iOS7以下を切り捨てる
        if greaterThanOrEqual(8, minorVersion: 0, patchVersion: 0) {
        } else {
            println("システムバージョン < iOS 8.0.0")
            var systemAlert = UIAlertController(title: "iOSのアップデートをしてください", message: "対応OSはiOS8.0以上です", preferredStyle: UIAlertControllerStyle.Alert)
            var closeAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            })
            systemAlert.addAction(closeAction)
            self.rootController.presentViewController(systemAlert, animated: true, completion: nil)
        }
        
        // 認証前なら設定画面に飛ばす
        var userDefault = NSUserDefaults.standardUserDefaults()
        if ( userDefault.objectForKey("username") == nil) {
            var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
            notice.alpha = 0.8
            notice.originY = self.alertPosition
            notice.show()
            var loginSettingsView = SettingsTableViewController()
            self.rootController.presentedViewController
            if let selectedController = self.rootController.selectedViewController as? UINavigationController {
                selectedController.pushViewController(loginSettingsView, animated: true)
            }
        }
        
        
        // SVProgressHUDの表示スタイル設定
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hudTapped:", name: SVProgressHUDDidReceiveTouchEventNotification, object: nil)
        SVProgressHUD.setBackgroundColor(UIColor.blackColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        
        FriendsList.sharedClient.saveFirendsInCache()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        WhalebirdAPIClient.encodeClipboardURL()
        FriendsList.sharedClient.saveFirendsInCache()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // <>と" "(空白)を取る
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(deviceTokenString, forKey: "deviceToken")
        println(deviceTokenString)
        WhalebirdAPIClient.sharedClient.syncPushSettings { (operation) -> Void in
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println(userInfo)
        var userDefault = NSUserDefaults.standardUserDefaults()
        if let aps = userInfo["aps"] as? NSDictionary {
            if let message = aps.objectForKey("alert") as? String, let category = aps.objectForKey("category") as? String {
                if (application.applicationState == UIApplicationState.Active && (userDefault.objectForKey("notificationForegroundFlag") == nil || userDefault.boolForKey("notificationForegroundFlag"))) {
                    // 起動中の通知
                    
                    if (userDefault.integerForKey("notificationType") == 2 ) {
                        // wbによる通知
                        var notice = WBSuccessNoticeView.successNoticeInView(self.window, title: message)
                        notice.alpha = 0.8
                        notice.originY = self.alertPosition
                        notice.show()
                    } else {
                        // デフォルトはアラート通知
                        switch(category) {
                        case "reply":
                            var alertController = UIAlertController(title: "Reply", message: message, preferredStyle: .Alert)
                            let cOpenAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: {action in
                                var tweetModel = TweetModel(notificationDict: userInfo)
                                var detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)

                                NotificationUnread.decrementUnreadBadge()
                                // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                                (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                            })
                            let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: {action in
                            })
                            alertController.addAction(cOkAction)
                            alertController.addAction(cOpenAction)
                            self.rootController.presentViewController(alertController, animated: true, completion: nil)
                            break
                        case "direct_message":
                            var alertController = UIAlertController(title: "DirectMessage", message: message, preferredStyle: .Alert)
                            let cOpenAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                var messageModel = MessageModel(notificationDict: userInfo)
                                var messageViewController = MessageDetailViewController(aMessageModel: messageModel)
                                NotificationUnread.decrementUnreadBadge()
                                (self.rootController.selectedViewController as! UINavigationController).pushViewController(messageViewController, animated: true)
                            })
                            let cOkAction = UIAlertAction(title: "閉じる", style: .Default, handler: { (action) -> Void in
                            })
                            alertController.addAction(cOkAction)
                            alertController.addAction(cOpenAction)
                            self.rootController.presentViewController(alertController, animated: true, completion: nil)
                            break
                        case "favorite":
                            // wbによる通知
                            var notice = WBSuccessNoticeView.successNoticeInView(self.window, title: message)
                            notice.alpha = 0.8
                            notice.originY = self.alertPosition
                            notice.show()
                            break
                        case "retweet":
                            // wbによる通知
                            var notice = WBSuccessNoticeView.successNoticeInView(self.window, title: message)
                            notice.alpha = 0.8
                            notice.originY = self.alertPosition
                            notice.show()
                            break
                        default:
                            break
                            
                        }
                    }
                } else if (application.applicationState != UIApplicationState.Active) {
                    // 起動済みで通知から復旧した時
                    switch(category) {
                    case "reply":
                        var tweetModel = TweetModel(notificationDict: userInfo)
                        var detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                        
                        NotificationUnread.decrementUnreadBadge()
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                        break
                    case "direct_message":
                        var messageModel = MessageModel(notificationDict: userInfo)
                        var messageViewController = MessageDetailViewController(aMessageModel: messageModel)
                        NotificationUnread.decrementUnreadBadge()
                        (self.rootController.selectedViewController as! UINavigationController).pushViewController(messageViewController, animated: true)
                        break
                    case "favorite":
                        if (userInfo["id"] != nil) {
                            var tweetModel = TweetModel(notificationDict: userInfo)
                            var detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
                            // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                            (self.rootController.selectedViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
                        }
                        break
                    case "retweet":
                        if (userInfo["id"] != nil) {
                            var tweetModel = TweetModel(notificationDict: userInfo)
                            var detailViewController = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: nil, aParentIndex: nil)
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
    
    func hudTapped(notification: NSNotification) {
        WhalebirdAPIClient.sharedClient.cancelRequest()
        SVProgressHUD.dismiss()
    }
    
    func greaterThanOrEqual(majorVersion: Int, minorVersion: Int, patchVersion: Int) -> Bool {
        // NSProcessInfo#isOperatingSystemAtLeastVersion による判別
        if NSProcessInfo().respondsToSelector("isOperatingSystemAtLeastVersion:") {
            let version = NSOperatingSystemVersion(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
            return NSProcessInfo().isOperatingSystemAtLeastVersion(version)
        }
        // UIDevice#systemVersion による判別
        let targetVarsion = shortedVersionNumber("\(majorVersion).\(minorVersion).\(patchVersion)")
        let systemVersion: String = shortedVersionNumber(UIDevice.currentDevice().systemVersion)
        return systemVersion.compare(targetVarsion, options: .NumericSearch) != NSComparisonResult.OrderedAscending
    }
    
    func shortedVersionNumber(version: String) -> String  {
        let suffix = ".0"
        var shortedVersion = version
        while shortedVersion.hasSuffix(suffix) {
            let endIndex = count(shortedVersion) - count(suffix)
            let range = Range(start:advance(shortedVersion.startIndex, 0), end: advance(shortedVersion.startIndex, endIndex))
            shortedVersion = shortedVersion.substringWithRange(range)
        }
        return shortedVersion;
    }
}


