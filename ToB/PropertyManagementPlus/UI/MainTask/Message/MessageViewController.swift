//
//  MessageViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class MessageViewController: LinkBaseViewController,UITableViewDelegate,UITableViewDataSource,DatePickerDelegate {

    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var selectIndex: NSInteger = 0
    
    var myMSGListDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var myAlarmListDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var allMyAlarmListDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var myAlarmListTopView = MyAlarmListTopView()
    var lSDatePicker = LSDatePicker()
    var todayTime = ""
    var messageTitle = "我的消息"
    var alertTitle = "业务预警"
    var isNotificationRefreshContent = false
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRefreshContent), name: kNotificationCenterChangeState as NSNotification.Name, object: nil)
        self.initContentUI()
        addFresh()
        
        refreshContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        
        
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.slider.tabbarShow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.segmentView.removeFromSuperview();
        self.segmentView = nil;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if (self.selectIndex == 1) {
            return self.myAlarmListDataSource.count
        }
        return self.myMSGListDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.selectIndex == 1) {
            return 110.0
        }
        return 125.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.selectIndex == 1 && section == 0) {
            return 60
        }
        return 10.0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if ((self.selectIndex == 0 && section == self.myMSGListDataSource.count - 1)
            || (self.selectIndex == 1 && section == self.myAlarmListDataSource.count - 1)) {
            return 60
        }
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var myMSGListTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (selectIndex == 0) {
            
            if myMSGListTableViewCell == nil {
                
                myMSGListTableViewCell = Bundle.main.loadNibNamed("MyMSGListTableViewCell", owner: nil, options: nil)?.first as! MyMSGListTableViewCell
                myMSGListTableViewCell?.selectionStyle = .none
                
                myMSGListTableViewCell?.separatorInset = .zero
                myMSGListTableViewCell?.layoutMargins = .zero
                myMSGListTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            let tempCell: MyMSGListTableViewCell = (myMSGListTableViewCell as! MyMSGListTableViewCell)
            
            let model = self.myMSGListDataSource[indexPath.section] as! GetMyMSGListModel
            
            tempCell.titleNameLabel.text = model.Tittle
            if (model.Tittle?.compare("") == .orderedSame) {
                tempCell.titleNameLabel.text = "暂无"
            }
            tempCell.typeLabel.text = model.Type
            tempCell.sendTimeLabel.text =  model.SendTime?.components(separatedBy: "T").joined(separator: " ")
            tempCell.sendPersonLabel.text = model.SendPerson
            tempCell.contentLabel.text = model.Content
            
            if (String(model.IsCheck!).compare("true") == .orderedSame) {
                tempCell.checkStateImageView.isHidden = true
            }else {
                tempCell.checkStateImageView.isHidden = false
                tempCell.checkStateImageView.image = UIImage(named: "icon_noread")
            }
            
        }else {
            
            if myMSGListTableViewCell == nil {
                
                myMSGListTableViewCell = Bundle.main.loadNibNamed("MyAlarmListTableViewCell", owner: nil, options: nil)?.first as! MyAlarmListTableViewCell
                myMSGListTableViewCell?.selectionStyle = .none
                
                myMSGListTableViewCell?.separatorInset = .zero
                myMSGListTableViewCell?.layoutMargins = .zero
                myMSGListTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            let tempCell: MyAlarmListTableViewCell = (myMSGListTableViewCell as! MyAlarmListTableViewCell)
            let model = self.myAlarmListDataSource[indexPath.section] as! GetMyMSGListModel
            
            tempCell.titleLabel.text = model.Type
            if (model.Type?.compare("") == .orderedSame) {
                tempCell.titleLabel.text = "暂无"
            }
            tempCell.contentLabel.text = model.Content
            tempCell.sendTimeLabel.text =  model.SendTime?.components(separatedBy: "T").joined(separator: " ")
            tempCell.sendPersonLabel.text = model.SendPerson
            
            if (String(model.IsCheck!).compare("true") == .orderedSame) {
                tempCell.iconImageView.isHidden = true
            }else {
                tempCell.iconImageView.isHidden = false
                tempCell.iconImageView.image = UIImage(named: "icon_noread")
            }
        }
        
        
        
        return myMSGListTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var model = GetMyMSGListModel()
        
        if (self.selectIndex == 0) {
            model = self.myMSGListDataSource[indexPath.section] as! GetMyMSGListModel
        }else {
            model = self.myAlarmListDataSource[indexPath.section] as! GetMyMSGListModel
        }
        
        let messageDetail = MessageDetailViewController()
        messageDetail.model = model;
        messageDetail.messageViewController = self
        self.push(viewController: messageDetail)
        
        
    }
    
    override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        selectIndex = segmentView.selectedSegmentIndex
        self.requestData()
    }
    
    @objc func refreshContent() {
        
        self.isOnline = LocalStoreData.getOnLine()
        //self.isOnline = false
        self.setTitleView(titles: [messageTitle as NSString,alertTitle as NSString])
        
    }
    
    @objc func notificationRefreshContent() {
        guard kAppDelegate.slider.tabBarController.selectedViewController == self else {
            return
        }
        isNotificationRefreshContent = true
        refreshContent()
    }
    
    private func initContentUI () {
        
        contentTableView?.isHidden = false
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
    }
    
    private func reloadAlrmData() {
        
        self.myAlarmListDataSource.removeAllObjects()
        
        for model in self.allMyAlarmListDataSource {
            if ((model as! GetMyMSGListModel).SendTime?.hasPrefix(self.todayTime))! == true {
                self.myAlarmListDataSource.add(model)
            }
        }
        self.makeTitle()
        self.contentTableView?.reloadData()
    }
    
    
    override func requestData() {
        
        myAlarmListTopView.isHidden = true
        
        if (!LocalStoreData.getOnLine()) {
            return
        }
        
        super.requestData()
        
        if (selectIndex == 0) {
            
            if navigationController?.navigationBar.subviews.count != 0 {
                navigationController?.navigationBar.subviews[0].isHidden = false
            }

            LoadView.storeLabelText = "正在加载我的信息"
            
            let getMyMSGListAPICmd = GetMyMSGListAPICmd()
            getMyMSGListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getMyMSGListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getMyMSGListAPICmd.loadView = LoadView()
            getMyMSGListAPICmd.loadParentView = self.view
            getMyMSGListAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                //成功
                self.myMSGListDataSource.removeAllObjects()
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    
                    for (_,tempDict) in dict["Records"] {
                        
                        if let getMyMSGListModel:GetMyMSGListModel = JSONDeserializer<GetMyMSGListModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                            self.myMSGListDataSource.add(getMyMSGListModel)
                        }
                        
                    }
                    
                    self.makeTitle()
                    
                    self.tabBarItem.badgeValue = String(self.myMSGListDataSource.count + self.myAlarmListDataSource.count)
                    self.contentTableView?.reloadData()
                    
                }else {
                    if (!self.isNotificationRefreshContent) {
                        LocalToastView.toast(text: dict["msg"].string!)
                    }
                    
                }
                self.stopFresh()
                
            }) { (response) in
                if (!self.isNotificationRefreshContent) {
                    LocalToastView.toast(text: DisNetWork)
                }
                self.stopFresh()
            }
        }else {
            
            //预警
            myAlarmListTopView.isHidden = false
            
            if (self.view.viewWithTag(7777) == nil) {
                
                myAlarmListTopView = Bundle.main.loadNibNamed("MyAlarmListTopView", owner: self, options: nil)?.first as! MyAlarmListTopView
                myAlarmListTopView.tag = 7777
                myAlarmListTopView.isUserInteractionEnabled = true
                myAlarmListTopView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50 + 64)
                self.view.addSubview(myAlarmListTopView)
                
                let tapGes = UITapGestureRecognizer(target: self, action: #selector(selectTime))
                myAlarmListTopView.timeLabel.isUserInteractionEnabled = true
                myAlarmListTopView.timeLabel.addGestureRecognizer(tapGes)
                
                let dateFmt = DateFormatter()
                dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateStr = dateFmt.string(from: Date())
                let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
                todayTime = dateForeStr as! String
                myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateStr)
                
                let actionTapGes = UITapGestureRecognizer(target: self, action: #selector(actionSelectTime(tap:)))
                
                myAlarmListTopView.foreImageView.isUserInteractionEnabled = true
                myAlarmListTopView.foreImageView.tag = 123
                myAlarmListTopView.foreImageView.addGestureRecognizer(actionTapGes)
                
                let backActionTapGes = UITapGestureRecognizer(target: self, action: #selector(actionSelectTime(tap:)))
                myAlarmListTopView.backImageView.isUserInteractionEnabled = true
                myAlarmListTopView.backImageView.tag = 125
                myAlarmListTopView.backImageView.addGestureRecognizer(backActionTapGes)
                
            }
            if navigationController?.navigationBar.subviews.count != 0 {
                navigationController?.navigationBar.subviews[0].isHidden = true
            }
            
            LoadView.storeLabelText = "正在加载业务预警信息"
            
            let getMyAlarmListAPICmd = GetMyAlarmListAPICmd()
            getMyAlarmListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getMyAlarmListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getMyAlarmListAPICmd.loadView = LoadView()
            getMyAlarmListAPICmd.loadParentView = self.view
            getMyAlarmListAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                //成功
                self.myAlarmListDataSource.removeAllObjects()
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    
                    self.allMyAlarmListDataSource.removeAllObjects()
                    for (_,tempDict) in dict["Records"] {
                        
                        if let getMyAlarmListModel:GetMyMSGListModel = JSONDeserializer<GetMyMSGListModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                            if (getMyAlarmListModel.SendTime?.hasPrefix(self.todayTime))! == true {
                                self.myAlarmListDataSource.add(getMyAlarmListModel)
                            }
                            
                            self.allMyAlarmListDataSource.add(getMyAlarmListModel)
                            
                        }
                        
                    }
                    
                    self.makeTitle()
                    
                    self.tabBarItem.badgeValue = String(self.myMSGListDataSource.count + self.myAlarmListDataSource.count)
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    if (!self.isNotificationRefreshContent) {
                        LocalToastView.toast(text: dict["msg"].string!)
                    }
                    
                }
                self.stopFresh()
                
            }) { (response) in
                if (!self.isNotificationRefreshContent) {
                    LocalToastView.toast(text: DisNetWork)
                }
                self.stopFresh()
            }
        }
        
    }
    
    func datePickerDelegateEnterAction(withDataPicker picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        todayTime = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue);
        
        lSDatePicker.tempHintsLabel.text = todayTime + ",星期" + getWeekDay(dateTime: value)
        
        myAlarmListTopView.timeLabel.text = lSDatePicker.tempHintsLabel.text
        
        reloadAlrmData()
    }
    
    func selectItemPickerDelegate(_ picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        todayTime = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue);
        
        lSDatePicker.tempHintsLabel.text = todayTime + ",星期" + getWeekDay(dateTime: value)
        
        reloadAlrmData()
    }
    
    @objc func selectTime() {
        //时间选择器
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日"], scrollDate: nil)
        
        lSDatePicker.delegate = self
        lSDatePicker.setHintsText("")
        let frame = lSDatePicker.tempHintsLabel.frame
        lSDatePicker.tempHintsLabel.frame = CGRect(x: (frame.origin.x), y: (frame.origin.y), width: (frame.size.width) + 70, height: (frame.size.height))
        lSDatePicker.cancelBtn.isHidden = true
        lSDatePicker.resetBtn.isHidden = true
        lSDatePicker.showView(inSelect: appDelegate.window)
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateStr = dateFmt.string(from: Date())
        let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
        lSDatePicker.tempHintsLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateStr)
        
    }
    
    @objc func actionSelectTime(tap: UITapGestureRecognizer) {
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd"
        let time = ((myAlarmListTopView.timeLabel.text?.components(separatedBy: ",星期"))! as [String])[0]
        let date = dateFmt.date(from: time)
        
        let yesterday = Date(timeInterval: -60 * 60 * 24, since: date!)
        let tomorrow = Date(timeInterval: 60 * 60 * 24, since: date!)
        
        if (tap.view?.tag == 123) {
            
            let dateForeStr = dateFmt.string(from: yesterday)
            todayTime = dateForeStr ;
            
            myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateForeStr + " 00:00:00")
            
        }else {
            
            let dateForeStr = dateFmt.string(from: tomorrow)
            todayTime = dateForeStr ;
            
            myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateForeStr + " 00:00:00")
            
        }
        
        reloadAlrmData()
    }
    
    func getWeekDay(dateTime:String) -> String{
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFmt.date(from: dateTime)
        date?.description
        let interval = Int(date!.timeIntervalSince1970) + NSTimeZone.local.secondsFromGMT()
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        
        var week = "一"
        
        if (weekday == 0) {
            week = "日"
        }else if (weekday == 1) {
            week = "一"
        }else if (weekday == 2) {
            week = "二"
        }else if (weekday == 3) {
            week = "三"
        }else if (weekday == 4) {
            week = "四"
        }else if (weekday == 5) {
            week = "五"
        }else if (weekday == 6) {
            week = "六"
        }
        
        return week
        
    }
    
    func makeTitle() {
        var message = self.messageTitle
        var alert = self.alertTitle
        
        if (self.myMSGListDataSource.count != 0) {
            message = self.messageTitle.appending("(").appending(String(self.myMSGListDataSource.count)).appending(")")
        }
        
        if (self.myAlarmListDataSource.count != 0) {
            alert = self.alertTitle.appending("(").appending(String(self.myAlarmListDataSource.count)).appending(")")
        }
        
        self.segmentView.refreshContent(titles: [message,alert])
    }
    
}
