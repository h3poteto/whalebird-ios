//
//  AppDelegate.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var rootController: UITabBarController!
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        var notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        
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
        self.rootController.setViewControllers(controllers, animated: true)
        self.window?.addSubview(self.rootController.view)
        self.window?.makeKeyAndVisible()
        // TODO: 認証前なら設定画面に飛ばす
        
        // RemoteNotificationからの復帰処理
        if (launchOptions != nil) {
            var userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as NSDictionary!
            if (userInfo.objectForKey("aps")?.objectForKey("category") as String == "reply") {
                var detailView = TweetDetailViewController(
                    aTweetID: userInfo.objectForKey("id_str") as String,
                    aTweetBody: userInfo.objectForKey("text") as String,
                    aScreenName: userInfo.objectForKey("screen_name") as String,
                    aUserName: userInfo.objectForKey("name") as String,
                    aProfileImage: userInfo.objectForKey("profile_image_url") as String,
                    aPostDetail: userInfo.objectForKey("created_at") as String,
                    aRetweetedName: nil,
                    aRetweetedProfileImage: nil
                )
                
                // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                (self.rootController.selectedViewController as UINavigationController).pushViewController(detailView, animated: true)
            } else if(userInfo.objectForKey("aps")?.objectForKey("category") as String == "direct_message") {
                var messageViewController = MessageDetailViewController(
                    aMessageID: userInfo.objectForKey("id") as String,
                    aMessageBody: userInfo.objectForKey("text") as String,
                    aScreeName: userInfo.objectForKey("screen_name") as String,
                    aUserName: userInfo.objectForKey("name") as String,
                    aProfileImage: userInfo.objectForKey("profile_image_url") as String,
                    aPostDetail: userInfo.objectForKey("created_at") as String)
                
                (self.rootController.selectedViewController as UINavigationController).pushViewController(messageViewController, animated: true)
            }
        }
        
        
        // SVProgressHUDの表示スタイル設定
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hudTapped", name: SVProgressHUDDidReceiveTouchEventNotification, object: nil)
        SVProgressHUD.appearance().hudBackgroundColor = UIColor.blackColor()
        SVProgressHUD.appearance().hudForegroundColor = UIColor.whiteColor()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
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
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println(userInfo)
        var userDefault = NSUserDefaults.standardUserDefaults()
        var message = (userInfo["aps"] as NSDictionary).objectForKey("alert") as String
        var category = (userInfo["aps"] as NSDictionary).objectForKey("category") as String
        if (application.applicationState == UIApplicationState.Active && (userDefault.objectForKey("notificationForegroundFlag") == nil || userDefault.boolForKey("notificationForegroundFlag"))) {
            if (userDefault.integerForKey("notificationType") == 2 ) {
                // wbによる通知
                var notice = WBSuccessNoticeView.successNoticeInView(self.window, title: message)
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            } else {
                // デフォルトはアラート通知
                switch(category) {
                case "reply":
                    var alertController = UIAlertController(title: "Reply", message: message, preferredStyle: .Alert)
                    let cOpenAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: {action in
                        var detailViewController = TweetDetailViewController(
                            aTweetID: userInfo["id"] as String,
                            aTweetBody: userInfo["text"] as String,
                            aScreenName: userInfo["screen_name"] as String,
                            aUserName: userInfo["name"] as String,
                            aProfileImage: userInfo["profile_image_url"] as String,
                            aPostDetail: userInfo["created_at"] as String,
                            aRetweetedName: nil,
                            aRetweetedProfileImage: nil
                        )
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as UINavigationController).pushViewController(detailViewController, animated: true)
                    })
                    let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: {action in
                    })
                    alertController.addAction(cOpenAction)
                    alertController.addAction(cOkAction)
                    self.rootController.presentViewController(alertController, animated: true, completion: nil)
                    break
                case "direct_message":
                    var alertController = UIAlertController(title: "DirectMessage", message: message, preferredStyle: .Alert)
                    let cOpenAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        var messageViewController = MessageDetailViewController(
                            aMessageID: userInfo["id"] as String,
                            aMessageBody: userInfo["text"] as String,
                            aScreeName: userInfo["screen_name"] as String,
                            aUserName: userInfo["name"] as String,
                            aProfileImage: userInfo["profile_image_url"] as String,
                            aPostDetail: userInfo["created_at"] as String)
                        (self.rootController.selectedViewController as UINavigationController).pushViewController(messageViewController, animated: true)
                    })
                    let cOkAction = UIAlertAction(title: "閉じる", style: .Default, handler: { (action) -> Void in
                    })
                    alertController.addAction(cOpenAction)
                    alertController.addAction(cOkAction)
                    self.rootController.presentViewController(alertController, animated: true, completion: nil)
                    break
                default:
                    break
                
                }
            }
        } else {
            switch(category) {
            case "reply":
                var detailViewController = TweetDetailViewController(
                    aTweetID: userInfo["id"] as String,
                    aTweetBody: userInfo["text"] as String,
                    aScreenName: userInfo["screen_name"] as String,
                    aUserName: userInfo["name"] as String,
                    aProfileImage: userInfo["profile_image_url"] as String,
                    aPostDetail: userInfo["created_at"] as String,
                    aRetweetedName: nil,
                    aRetweetedProfileImage: nil
                )
                
                // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                (self.rootController.selectedViewController as UINavigationController).pushViewController(detailViewController, animated: true)
                break
            case "direct_message":
                var messageViewController = MessageDetailViewController(
                    aMessageID: userInfo["id"] as String,
                    aMessageBody: userInfo["text"] as String,
                    aScreeName: userInfo["screen_name"] as String,
                    aUserName: userInfo["name"] as String,
                    aProfileImage: userInfo["profile_image_url"] as String,
                    aPostDetail: userInfo["created_at"] as String)
                (self.rootController.selectedViewController as UINavigationController).pushViewController(messageViewController, animated: true)
                break
            default:
                break
            }
        }
    }
    
    func hudTapped() {
        WhalebirdAPIClient.sharedClient.cancelRequest()
        SVProgressHUD.dismiss()
    }
}

