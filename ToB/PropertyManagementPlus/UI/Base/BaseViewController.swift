//
//  BaseViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/7.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum EventType {
    //客户事件
    case eventCustomer
    //突发事件
    case eventSudden
    //入仓
    case warehouseIn
    //出仓
    case warehouseOut
    //客户意向
    case customerIntent
    //能耗抄表
    case energyMeterUnit
    //跟进记录
    case customerComeIn
    //客户需求资料
    case customerNeedInfo
}

let bottomActionTag = 7777333

open class BaseViewController: UIViewController,ActionSheetDelegate {
    
    
    var isShowEmptyData: Bool = true
    var noDataTitle: String = "暂无任何数据"
    var noDataImgName: String = "NoData"
    var noDataDetailTitle: String = ""
    var btnTitle: String = ""
    var btnImgName: String = ""
    
    var segmentView: SMSegmentView!
    var margin: CGFloat = 50.0
    var appDelegate : AppDelegate!
    var isOnline: Bool = false
    
    var reachability: Reachability = Reachability.forInternetConnection()
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: NSNotification.Name.reachabilityChanged,object: reachability)
        
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        if (BaseTool.isExistenceNetwork() == false) {
            netDisconnet()
        }
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = false
        }
        
        let textAttributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18),NSAttributedStringKey.foregroundColor:UIColor.white]
        
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = kThemeColor
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent;
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate.slider.tabbarHidden()
        
        appDelegate.slider.tabbarNavigationController.isNavigationBarHidden = false
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = false
        }
        navigationController?.navigationBar.barTintColor = kThemeColor
        navigationController?.navigationBar.setBackgroundImage(BaseTool.createImage(with: kThemeColor), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let item = UIBarButtonItem(image: UIImage(named: "ryback_topBar_Icon_white"), style: .done, target: self, action: #selector(pop))
        self.navigationItem.leftBarButtonItem = item
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.reachabilityChanged,object: reachability)
    }
    
    
    open func setTitleView(titles: [NSString])  {
        
        if self.isOnline {
            //上线
            
            /*
             Init SMsegmentView
             Set divider colour and width here if there is a need
             */
            initSegmentView(titles: titles)
            if appDelegate.slider.tabBarController != nil {
               appDelegate.slider.tabBarController.customerNavigation.reload(withCustomerView: self.segmentView)
            }
            self.navigationItem.titleView = self.segmentView
            
        }else {
            //下线
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = .center
            
            titleLabel.text = titles[0] as String
            if appDelegate.slider.tabBarController != nil {
                appDelegate.slider.tabBarController.customerNavigation.reload(withTitle: titles[0] as String)
            }
            self.navigationItem.titleView = titleLabel
        }
        
    }
    
    // SMSegment selector for .ValueChanged
    @objc open func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        /*
         Replace the following line to implement what you want the app to do after the segment gets tapped.
         */
        print("Select segment at index: \(segmentView.selectedSegmentIndex)")
    }
    
    open func buttonAction(titles: NSArray, actions: NSArray, target: UIViewController) {
        
        self.view.viewWithTag(bottomActionTag)?.removeFromSuperview()
        
        var startY = kScreenHeight - kNavbarHeight - 50
        if target.navigationController?.navigationBar.subviews.count != 0 {
            if let view = target.navigationController?.navigationBar.subviews[0], view.isHidden {
                startY = kScreenHeight - 50
            }
        }
        
        let bottomView = UIView(frame: CGRect(x: 0, y: startY, width: kScreenWidth, height: 50))
        bottomView.tag = bottomActionTag
        bottomView.backgroundColor = UIColor.clear
        
        for (index, name) in titles.enumerated() {
            let width = kScreenWidth / (CGFloat(titles.count) * 1.0)
            print(name)
            let button = createTitleButton(frame: CGRect(x: width*CGFloat(index), y: 0, width: width, height: 50), title: name as! String, titleColor: UIColor.white, backGroundColor: kThemeColor, textAlignment: .center, target: target, action: actions[index] as? Selector)
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = UIColor.white.cgColor
            button.tag = index + 1
            bottomView.addSubview(button)
        }
        
        self.view.addSubview(bottomView)
        
    }
    
    open func buttonHeightAction(startY: CGFloat, titles: NSArray, actions: NSArray, target: UIViewController) {
        
        self.view.viewWithTag(bottomActionTag)?.removeFromSuperview()
        
        let bottomView = UIView(frame: CGRect(x: 0, y: startY, width: kScreenWidth, height: 50))
        bottomView.tag = bottomActionTag
        bottomView.backgroundColor = UIColor.clear
        
        for (index, name) in titles.enumerated() {
            let width = kScreenWidth / (CGFloat(titles.count) * 1.0)
            print(name)
            let button = createTitleButton(frame: CGRect(x: width*CGFloat(index), y: 0, width: width, height: 50), title: name as! String, titleColor: UIColor.white, backGroundColor: kThemeColor, textAlignment: .center, target: target, action: actions[index] as? Selector)
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = UIColor.white.cgColor
            button.tag = index + 1
            bottomView.addSubview(button)
        }
        
        self.view.addSubview(bottomView)
        
    }
    
    open func createButton(frame: CGRect, title: String, titleColor: UIColor,backGroundColor: UIColor,textAlignment: NSTextAlignment,image: UIImage?,target: Any?, action: Selector?) -> UIButton {
        
        let button = createTitleButton(frame: frame, title: title, titleColor: titleColor, backGroundColor: backGroundColor, textAlignment: textAlignment, target: target, action: action)
        button.setImage(image, for: .normal)
        return button
    }
    
    open func createTitleButton(frame: CGRect, title: String, titleColor: UIColor,backGroundColor: UIColor,textAlignment: NSTextAlignment,target: Any?, action: Selector?) -> UIButton {
        
        let button = UIButton(frame: frame)
        button.setTitleColor(titleColor, for: .normal)
        //button.backgroundColor = backGroundColor
        button.setBackgroundImage(BaseTool.createImage(with: backGroundColor), for: .normal)
        button.setBackgroundImage(BaseTool.createImage(with: UIColor(red: 0.0/255.0, green: 160.0/255.0, blue: 234.0/255.0, alpha: 0.8)), for: .highlighted)
        button.titleLabel?.textAlignment = textAlignment
        button.setTitle(title, for: .normal)
        button.addTarget(target, action: action!, for: .touchUpInside)
        return button
    }
    
    open func initSegmentView(titles: [NSString]) {
        
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = UIColor.white
        appearance.segmentOffSelectionColour = kThemeColor
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 12.0)
        appearance.titleOnSelectionColour = appearance.segmentOffSelectionColour
        appearance.titleOffSelectionColour = appearance.segmentOnSelectionColour
        appearance.segmentTouchDownColour = appearance.segmentOffSelectionColour
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 12.0)
        appearance.contentVerticalMargin = 10.0
        
        let segmentFrame = CGRect(x: 0.0, y: 0.0, width: kScreenWidth - self.margin*2, height: 35.0)
        self.segmentView = SMSegmentView(frame: segmentFrame, dividerColour: UIColor(white: 0.95, alpha: 0.3), dividerWidth: 1.0, segmentAppearance: appearance)
        self.segmentView.backgroundColor = UIColor.clear
        
        self.segmentView.layer.cornerRadius = 5.0
        self.segmentView.layer.borderColor = UIColor.white.cgColor
        self.segmentView.layer.borderWidth = 0.5
        
        for titleName in titles{
            // Add segments
            self.segmentView.addSegmentWithTitle(titleName as String, onSelectionImage: UIImage(named: ""), offSelectionImage: UIImage(named: ""))
        }
        
        self.segmentView.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)), for: .valueChanged)
        
        // Set segment with index 0 as selected by default
        self.segmentView.selectedSegmentIndex = 0
        
    }
    
    open func addSegmentView(titles: [NSString]) {
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 115))
        bottomView.backgroundColor = kThemeColor
        bottomView.tag = kSegmentViewTag
        initSegmentView(titles: titles)
        self.segmentView.frame = CGRect(x: 40, y: 0, width: kScreenWidth - 80, height: 40)
        bottomView.addSubview(self.segmentView)
        
        self.view.addSubview(bottomView)
    }
    
    @objc open func pop() {
        appDelegate.slider.tabbarNavigationController!.popViewController(animated: true)
        if appDelegate.slider.tabBarController != nil {
            appDelegate.slider.tabBarController.show()
        }
    }
    
    //tabbar页面push操作
    open func push(viewController: BaseViewController) {
        appDelegate.slider.tabbarNavigationController!.pushViewController(viewController, animated: true)
    }
    
    //tabbar页面push操作
    open func pushNormalViewController(viewController: UIViewController) {
        appDelegate.slider.tabbarNavigationController!.pushViewController(viewController, animated: true)
    }
    
    //普通页面push操作
    open func pushChild(viewController: BaseViewController) {
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    //Alert视图
    
    open func alert(title: NSString, message: NSString, buttonAction: NSArray, buttonNames: NSArray, type: NSInteger) {
        
        let alertVC: LSAlertViewController = LSAlertViewController.alert(withTitle: title as String!, message: message as String!, placeHolder: "", type: CKAlertViewType(rawValue: UInt(type))!)
        
        for (index, name) in buttonNames.enumerated() {
            
            let alertAction = CKAlertAction(title: name as! String, handler: { (action) in
                self.perform(buttonAction[index] as! Selector)
            })
            alertVC.addAction(alertAction)
        }
        
        self.present(alertVC, animated: false, completion: nil)
        
    }
    
    open func showActionSheet(title: String ,cancelTitle: String, titles: [Any], tag: String) {
        
        let actionSheet = ActionSheet.shareManager()
        actionSheet?.tag = tag
        actionSheet?.delegate = self
        actionSheet?.sheet(withTitle: title, cancelButtonTitle: cancelTitle, otherButtonTitleArray: titles)
    }
    
    open func formateTime(time: String) -> String{
        if (time.compare(kEmptyTimeKey) == .orderedSame) {
            return ""
        }
        return time
    }
    
    //打电话
    open func dailNumber(phoneNumber: String) {
        UIApplication.shared.openURL(NSURL(string :"tel://"+"\(phoneNumber)")! as URL)
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        _ = note.object as! Reachability
        
        if BaseTool.isExistenceNetwork() == true{
            //netConnect()
        } else {
            netDisconnet()
        }
    }
    
    open func netDisconnet() {
        
    }
    
    open func netConnect() {
        
    }
    
    func setIQKeyboardOff() {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
    func setIQKeyBoardOn() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
}
