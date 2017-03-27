 //
//  AppDelegate.swift
//  viossvc
//
//  Created by yaowang on 2016/10/29.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
 
import XCGLogger
import SVProgressHUD
import Fabric
import Crashlytics
import AddressBook

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, GeTuiSdkDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as? String {
            CurrentUserHelper.shared.deviceToken = token
        }
        
        Fabric.with([Crashlytics.self])
        self.appearance()
        self.geTuiServiceRegister()
        self.umappServiceRegister()
        self.mapServiceRegister()
        
        return true
    }
    
    func geTuiServiceRegister() {
        // 注册消息推送
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () in
            var appid = "d2YVUlrbRU6yF0PFQJfPkA"
            var appkey =  "yEIPB4YFxw64Ag9yJpaXT9"
            var appSecret = "TMQWRB2KrG7QAipcBKGEyA"
            if let id = NSBundle.mainBundle().bundleIdentifier {
                if id == "com.yundian.assistant" {
                    appid = "ym6gRyDFK08iP0seFqYmm3"
                    appkey = "Ut4rL2IDMP8Gj0biBFc3UA"
                    appSecret = "NlDoS6zaEt8Uguav5ZKrE7"
                }
                
            }
            
            GeTuiSdk.startSdkWithAppId(appid, appKey: appkey, appSecret: appSecret, delegate: self)
            
            let notifySettings = UIUserNotificationSettings.init(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notifySettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        })
    }
    
    private func appearance() {
        let navigationBar:UINavigationBar = UINavigationBar.appearance() as UINavigationBar
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        navigationBar.translucent = false
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:.Default)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        UITableView.appearance().backgroundColor = AppConst.Color.C6
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
//        SVProgressHUD.setBackgroundColor = UIColor.darkGrayColor
    }
    
    private func umappServiceRegister() {
        MobClick.setCrashReportEnabled(false)
        UMAnalyticsConfig.sharedInstance().appKey = AppConst.UMAppkey
        UMAnalyticsConfig.sharedInstance().channelId = ""
        MobClick.startWithConfigure(UMAnalyticsConfig.sharedInstance())
        //version标识
        let version: String? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
        MobClick.setAppVersion(version)
        //日志加密设置
        MobClick.setEncryptEnabled(true)
        //使用集成测试服务
        MobClick.setLogEnabled(true)
    }
    
    private func mapServiceRegister() {
        var key = "46a4db80f23354f30107c349fa55387a"
        if let id = NSBundle.mainBundle().bundleIdentifier {
            if id == "com.yundian.enterprise.assistant" {
                key = "fee316e0f09979b349bfd4f9e225c907"
            } else if id == "com.yundian.assistant" {
                key = "46a4db80f23354f30107c349fa55387a"
            }else if id == "com.yundian.enterprise.trip" {
                key = "4bb6a0b7762c3f6881048a57d9d64bef"
            }
        }
        
        AMapServices.sharedServices().apiKey = key
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        
        XCGLogger.debug("\(token)")
        CurrentUserHelper.shared.deviceToken = token
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "DeviceToken")
        #if true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () in
                GeTuiSdk.registerDeviceToken(token)
            })
        #endif
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        SVProgressHUD.showWainningMessage(WainningMessage: "\(error)", ForDuration: 1.5, completion: nil)
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
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

