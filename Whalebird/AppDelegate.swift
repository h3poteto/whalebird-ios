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
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, UNUserNotificationCenterDelegate {
    var rootController: UITabBarController!
    var window: UIWindow?
    var alertPosition: CGFloat = 0.0


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
                guard error == nil else {
                    // error handling
                    return
                }

                if granted {
                    // デバイストークンを発行
                    // TODO: ここテストが落ちる
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            let center = UNUserNotificationCenter.current()
            center.delegate = self
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
            let tabBarFontDict = [NSAttributedStringKey.font: tabBarFont]
            UITabBarItem.appearance().setTitleTextAttributes(tabBarFontDict, for: UIControlState())
            UITabBarItem.appearance().setTitleTextAttributes(tabBarFontDict, for: UIControlState.selected)
        }
        if let navBarFont: UIFont = UIFont(name: TimelineViewCell.BoldFont, size: 16) {
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: navBarFont]
        }
        if let barButtonFont: UIFont = UIFont(name: TimelineViewCell.NormalFont, size: 16) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: barButtonFont], for: UIControlState())
        }

        // SVProgressHUDの表示スタイル設定
        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setForegroundColor(UIColor.white)

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
        let controllers = [timelineNavigationController, replyNavigationController, listNavigationController, directMessageNavigationController, settingsNavigationController]
        self.rootController.setViewControllers((controllers), animated: true)
        self.window?.rootViewController = self.rootController
        self.window?.makeKeyAndVisible()
        
        if let navigationController = self.rootController.selectedViewController as? UINavigationController {
            self.alertPosition = navigationController.navigationBar.frame.origin.y + navigationController.navigationBar.frame.size.height
        }


        // 認証前なら設定画面に飛ばす
        let userDefault = UserDefaults.standard
        if ( userDefault.object(forKey: "username") == nil) {
            let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: NSLocalizedString("AccountErrorTitle", tableName: "AppDelegate", comment: ""), message: NSLocalizedString("AccountErrorMessage", tableName: "AppDelegate", comment: ""))
            notice?.alpha = 0.8
            notice?.originY = self.alertPosition
            notice?.show()
            let loginSettingsView = SettingsTableViewController()
            if let selectedController = self.rootController.selectedViewController as? UINavigationController {
                selectedController.pushViewController(loginSettingsView, animated: true)
            }
        } else {
             let endNotice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title:
             NSLocalizedString("EndNoticeTitle", tableName: "AppDelegate", comment: ""), message:
             NSLocalizedString("EndNoticeMessage", tableName: "AppDelegate", comment: ""))
             endNotice?.alpha = 0.8
             endNotice?.originY = self.alertPosition
             endNotice?.show()

            if (userDefault.object(forKey: "EndNotice") == nil) {
                let alertController = UIAlertController(title: NSLocalizedString("EndNoticeTitle", tableName: "AppDelegate", comment: ""), message: NSLocalizedString("EndNoticeMessage", tableName: "AppDelegate", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let cOkAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: { (aAction) -> Void in
                    userDefault.set(true, forKey: "EndNotice")
                })
                alertController.addAction(cOkAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }

        
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

    // https://qiita.com/mshrwtnb/items/3135e931eedc97479bb5
    // フォアグラウンド時の通知
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // 通知復帰時の処理
    // アプリが起動していない状態からの通知復帰でもここが呼ばれる
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
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
        completionHandler()
    }
}

extension SVProgressHUD {
    public static func showDismissableLoad(with status: String) {
        let nc = NotificationCenter.default
        nc.addObserver(
            self, selector: #selector(hudTapped(_:)),
            name: NSNotification.Name.SVProgressHUDDidTouchDownInside,
            object: nil
        )
        SVProgressHUD.show(withStatus: status)
        SVProgressHUD.setDefaultMaskType(.clear)
    }

    @objc static func hudTapped(_ notification: Notification) {
        WhalebirdAPIClient.sharedClient.cancelRequest()
        SVProgressHUD.dismiss()
    }
}


