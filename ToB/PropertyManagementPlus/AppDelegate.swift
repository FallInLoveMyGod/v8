//
//  AppDelegate.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import IQKeyboardManagerSwift

let kAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UIAlertViewDelegate {

    @objc var window: UIWindow?
    @objc var slider: SliderViewController!
    @objc var userDeviceToken: String = ""
//    var channelId: String = ""
    @objc var registrationID: String = ""
    @objc var isLoginSuccess: Bool = false
    @objc var isForceLandscape: Bool = false
    
    //语音
    var speech: YSSpeech = YSSpeech()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
//        let f = NSMutableDictionary();
//        f.setValue("gg", forKey: "mmb");
//
//        let dd = ["a":"b","c":[f,["n":",m"]]] as! NSDictionary;
//        let ab = dd.yy_modelToJSONData()
//        let cd = dd.yy_modelToJSONString()
//        let ef = JSON(ab)
//        let hh = dd.yy_modelToJSONObject()
//        print(dd)
        
        if (LocalStoreData.getIsRepairOn() == nil) {
            LocalStoreData.setUserDefaultsData("NO", forKey: LocalStoreData.IsRepairOn)
        }
        
        let loginInfo = LocalStoreData.getLoginInfo()
        
        if LocalStoreData.getUserInfo() != nil && loginInfo != nil {
            isLoginSuccess = true
            loginSuccess()
        } else {
            isLoginSuccess = false
            logoutSuccess()
        }
        
        setKeyboard()
        
        window?.makeKeyAndVisible()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        BaseTool.registerUserNotification(with: application, launchOptions: launchOptions)
        
//        let center = NotificationCenter.default
//        center.addObserver(self, selector: #selector(networkDidReceiveMessage(_ :)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
//
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (self.isForceLandscape) {
            return UIInterfaceOrientationMask.landscape;
        }
        return UIInterfaceOrientationMask.portrait;
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loginSuccess() {
        
        slider = SliderViewController()
        window?.rootViewController = slider
        
        //同步本地信息
        JKDBHelper.shareInstance().changeDB(withDirectoryName: LocalStoreData.getUserInfo()?.upk)
        // 不用数据同步
//        DataSynchronizationManager.synchronizationAllData()
        
        let loginInfo = LocalStoreData.getLoginInfo()
        vertify(custCode: (loginInfo?.accountCode)!)
        
    }
    
    func logoutSuccess() {
        window?.rootViewController = LoginViewController()
    }
    
    //MARK：推送配置
    @objc func notificationAction(loginState: Int) {
        
        /*
         86016586@qq.com
         Zengjh168
         */
        
        if loginState == 1 {
            isLoginSuccess = true
        } else {
            isLoginSuccess = false
        }
        
        if registrationID == "" {
            return
        }
        
        let loginInfo = LocalStoreData.getLoginInfo()
        let userInfo = LocalStoreData.getUserInfo()
        
        
        let updataJGPushAPICmd = UpdataJGPushAPICmd()
        updataJGPushAPICmd.parameters = ["AppFlag": "LSPMTOBV8APK20160001", "AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","RegistrationId":registrationID ,"type":loginState,"OSType":"4", "Alias":""]
        updataJGPushAPICmd.loadView = LoadView()
        updataJGPushAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
            }else {
                
            }
            
        }) { (response) in
//            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    func vertify(custCode: String) {
        
        let vertifyCode = VertifyCodeAPI()
        vertifyCode.baseUrl = KHost
        vertifyCode.parameters = ["custCode":custCode,"version":"8.1.1"]
        vertifyCode.loadView = LoadView()
        vertifyCode.transactionWithSuccess({ (response) in
            
            //https://github.com/SwiftyJSON/SwiftyJSON
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                //LocalToastView.toast(text: "验证成功")
                LocalStoreData.setUserDefaultsData(JSON(dict["clientInfo"][0].object).rawString(), forKey: LocalStoreData.ClientInfoKey)
                LocalStoreData.setUserDefaultsData(custCode, forKey: LocalStoreData.CustCode)
                LocalStoreData.setUserDefaultsData("0", forKey: LocalStoreData.IsUse)
                LocalStoreData.setUserDefaultsData("NO", forKey: LocalStoreData.Applicense)
                
                let applicense = String(describing: dict["clientInfo"][0]["Applicense"])
                
                var formate = false
                if (applicense.compare("") == .orderedSame) {
                    formate = true
                    LocalStoreData.setUserDefaultsData("YES", forKey: LocalStoreData.Applicense)
                }else {
                    
                    let index = applicense.index(applicense.startIndex, offsetBy: 1)
                    
                    if (applicense.substring(to: index).compare("1") == .orderedSame) {
                        formate = true
                        LocalStoreData.setUserDefaultsData("YES", forKey: LocalStoreData.Applicense)
                    }
                    
                }
                
                NotificationCenter.default.post(name: kNotificationCenterFreshMyPage as NSNotification.Name, object: nil)
                
                if (formate == false &&  (dict["clientInfo"][0]["UseDays"]).intValue == 0) {
                    //试用天数为0
                    
                    let alertView = UIAlertView(title: "", message: "试用期已过，请联系我们！", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "知道了")
                    alertView.show()
                    
                }else {
                    LocalStoreData.setUserDefaultsData(String(dict["clientInfo"][0]["UseDays"].intValue), forKey: LocalStoreData.IsUse)
                }
                
            }else {
                
                
                
                //LocalToastView.toast(text: "验证失败")
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    //MARK: UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        logoutClearData()
    }
    
    func logoutClearData() {
        LocalStoreData.clearLocalData()
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logoutSuccess()
        delegate.notificationAction(loginState: 2)
    }
    
    func setKeyboard() {
        // ###########
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
//    //自定义消息
//    func networkDidReceiveMessage(_ notification: Notification) {
//        //print(notification.userInfo)
//        //取数据
//    }
    
    func handleMessage(userInfo: [AnyHashable : Any]) {
        //跳转逻辑
        if let info = userInfo as? NSDictionary {
            /*
             { 
             "pushman":"",
             "pushtime":"",
             "msgtitle":"",
             "msgabstract":"",
             "pushtype":"",
             "privatecontent":{} }
             */
            
            var pushType = ""
            
            if let type = info["pushType"] as? String {
                pushType = "\(type)"
            }
            
            var privatecontent = NSDictionary()
            if let content = info["privatecontent"] as? String {
                privatecontent = BaseTool.dictionary(withJsonString: content) as! NSDictionary
                //语音处理
            }
            
            guard privatecontent.count != 0 else {
                return
            }
            
            if let title = info["msgtitle"] as? String {
                if LocalStoreData.getIsAudioReqireOn() == "YES" {
                    speech.speakWords = "你有新的\(title)要处理"
                    speech.startSpeaking()
                }
            }
            //privatecontent:{"billCode":"CJ0000000166","type":"101"}
            //msgtitle:1个亿
            //pushType:4
            switch pushType {
            case "0":
                break
            case "1":
                //维修任务
                var billPK = ""
                if let billpk = privatecontent["billpk"] as? String {
                    billPK = billpk
                }
                if let type = privatecontent["type"] as? String {
                    
                    let repair = RepairTaskDetailViewController()
                    repair.selectIndex = 0
                    repair.notificationBillPK = billPK
                    switch type {
                    case "101":
                        repair.titleContent = "维修任务-未派单"
                        repair.contentType = "1"
                        repair.category = "NoSend"
                    case "102":
                        repair.titleContent = "维修任务-未完成"
                        repair.contentType = "2"
                        repair.category = "NoComplete"
                    case "105":
                        repair.titleContent = "维修任务-未回访"
                        repair.contentType = "5"
                        repair.category = "NoReCall"
                    case "106":
                        repair.titleContent = "维修任务-未检验"
                        repair.contentType = "6"
                        repair.category = "NoCheck"
                    case "103":
                        repair.selectIndex = -1
                        repair.contentType = "4"
                        repair.titleContent = "待抢列表"
                    default:
                        break
                    }
                    
                    if type == "104" {
                        
                    } else {
                        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + .milliseconds((Int)(0.2*1000)), execute: {
                            self.slider.tabbarNavigationController.pushViewController(repair, animated: true)
                        })
                    }
                }
                
            case "2":
                //客户联系单
                var billPK = ""
                if let billpk = privatecontent["billpk"] as? String {
                    billPK = billpk
                }
                if let type = privatecontent["type"] as? String {
                    let link = LinkListViewController()
                    link.notificationBillCode = billPK
                    link.notificationType = type
                    DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + .milliseconds((Int)(0.2*1000)), execute: {
                        self.slider.tabbarNavigationController.pushViewController(link, animated: true)
                    })
                    
                }
                
            case "3":
                //巡检任务提醒
                let vc = ManagementIndexEquipmentPatrolViewController()
                vc.managementIndexEquipmentPatrolType = .equipmentPatrol
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + .milliseconds((Int)(0.2*1000)), execute: {
                    self.slider.tabbarNavigationController.pushViewController(vc, animated: true)
                })
                
            case "4":
                //投诉处理
                //ComplaintHandlingViewController()
                let complaint = ComplaintHandlingViewController()
                if let billCode = privatecontent["billCode"] as? String {
                    complaint.notificationBillCode = billCode
                }
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + .milliseconds((Int)(0.2*1000)), execute: {
                    self.slider.tabbarNavigationController.pushViewController(complaint, animated: true)
                })
                
            default:
                break
            }
        }
    }
    
}

extension AppDelegate {
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}

extension AppDelegate: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        // ###########
    }
    
    
    //MARK: 推送
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //iOS6及以下系统，收到通知
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //iOS7及以上系统，收到通知
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        //iOS10 收到远程通知
        print(response.notification.request.content.userInfo)
        handleMessage(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        //iOS10 前台收到远程通知
        print(notification.request.content.userInfo)
        //本地通知
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
}

