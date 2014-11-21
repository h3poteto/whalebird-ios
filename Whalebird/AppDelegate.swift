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

        // TODO: リファクタリング
        
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
        let controllers = NSArray(array: [timelineNavigationController, replyNavigationController, listNavigationController, directMessageNavigationController, settingsNavigationController])
        self.rootController.setViewControllers(controllers, animated: true)
        self.window?.addSubview(self.rootController.view)
        self.window?.makeKeyAndVisible()
        
        // RemoteNotificationからの復帰処理
        if (launchOptions != nil) {
            var userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as NSDictionary!
            if (userInfo.objectForKey("aps")?.objectForKey("category") as String == "reply") {
                var detailView = TweetDetailViewController(
                    tweet_id: userInfo.objectForKey("id_str") as String,
                    tweet_body: userInfo.objectForKey("text") as String,
                    screen_name: userInfo.objectForKey("screen_name") as String,
                    user_name: userInfo.objectForKey("name") as String,
                    profile_image: userInfo.objectForKey("profile_image_url") as String,
                    post_detail: userInfo.objectForKey("created_at") as String,
                    retweeted_name: nil,
                    retweeted_profile_image: nil
                )
                
                // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                (self.rootController.selectedViewController as UINavigationController).pushViewController(detailView, animated: true)
            } else if(userInfo.objectForKey("aps")?.objectForKey("category") as String == "direct_message") {
                var messageViewController = MessageDetailViewController(
                    MessageID: userInfo.objectForKey("id") as String,
                    MessageBody: userInfo.objectForKey("text") as String,
                    ScreeName: userInfo.objectForKey("screen_name") as String,
                    UserName: userInfo.objectForKey("name") as String,
                    ProfileImage: userInfo.objectForKey("profile_image_url") as String,
                    PostDetail: userInfo.objectForKey("created_at") as String)
                
                (self.rootController.selectedViewController as UINavigationController).pushViewController(messageViewController, animated: true)
            }
        }
        
        
        // SVProgressHUDの表示スタイル設定
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
                    let openAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: {action in
                        var detailViewController = TweetDetailViewController(
                            tweet_id: userInfo["id"] as String,
                            tweet_body: userInfo["text"] as String,
                            screen_name: userInfo["screen_name"] as String,
                            user_name: userInfo["name"] as String,
                            profile_image: userInfo["profile_image_url"] as String,
                            post_detail: userInfo["created_at"] as String,
                            retweeted_name: nil,
                            retweeted_profile_image: nil
                        )
                        
                        // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                        (self.rootController.selectedViewController as UINavigationController).pushViewController(detailViewController, animated: true)
                    })
                    let okAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: {action in
                    })
                    alertController.addAction(openAction)
                    alertController.addAction(okAction)
                    self.rootController.presentViewController(alertController, animated: true, completion: nil)
                    break
                case "direct_message":
                    var alertController = UIAlertController(title: "DirectMessage", message: message, preferredStyle: .Alert)
                    let openAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        var messageViewController = MessageDetailViewController(
                            MessageID: userInfo["id"] as String,
                            MessageBody: userInfo["text"] as String,
                            ScreeName: userInfo["screen_name"] as String,
                            UserName: userInfo["name"] as String,
                            ProfileImage: userInfo["profile_image_url"] as String,
                            PostDetail: userInfo["created_at"] as String)
                        (self.rootController.selectedViewController as UINavigationController).pushViewController(messageViewController, animated: true)
                    })
                    let okAction = UIAlertAction(title: "閉じる", style: .Default, handler: { (action) -> Void in
                    })
                    alertController.addAction(openAction)
                    alertController.addAction(okAction)
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
                    tweet_id: userInfo["id"] as String,
                    tweet_body: userInfo["text"] as String,
                    screen_name: userInfo["screen_name"] as String,
                    user_name: userInfo["name"] as String,
                    profile_image: userInfo["profile_image_url"] as String,
                    post_detail: userInfo["created_at"] as String,
                    retweeted_name: nil,
                    retweeted_profile_image: nil
                )
                
                // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                (self.rootController.selectedViewController as UINavigationController).pushViewController(detailViewController, animated: true)
                break
            case "direct_message":
                var messageViewController = MessageDetailViewController(
                    MessageID: userInfo["id"] as String,
                    MessageBody: userInfo["text"] as String,
                    ScreeName: userInfo["screen_name"] as String,
                    UserName: userInfo["name"] as String,
                    ProfileImage: userInfo["profile_image_url"] as String,
                    PostDetail: userInfo["created_at"] as String)
                (self.rootController.selectedViewController as UINavigationController).pushViewController(messageViewController, animated: true)
                break
            default:
                break
            }
        }
    }

}

