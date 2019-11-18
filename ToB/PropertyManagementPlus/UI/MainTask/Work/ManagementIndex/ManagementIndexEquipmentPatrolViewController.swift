//
//  ManagementIndexEquipmentPatrolViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

enum ManagementIndexEquipmentPatrolType {
    //经营指标
    case managementIndex
    //设备巡检
    case equipmentPatrol
    //安全巡更
    case safePatrol
}

class ManagementIndexEquipmentPatrolViewController: BaseTableViewController,DatePickerDelegate,FJFloatingViewDelegate,ScanResultDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    fileprivate var myAlarmListTopView = MyAlarmListTopView()
    fileprivate var lSDatePicker = LSDatePicker()
    fileprivate var projectCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
    fileprivate var buildCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
    fileprivate var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    var tempDataSource:NSMutableArray = NSMutableArray();
    var todayTime = ""
    var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var dataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var dInfoDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var buildIndex = 0
    var pProjectCode = ""
    var roomIndex = 0
    var pBuildingCode = ""
    var managementIndexEquipmentPatrolType = ManagementIndexEquipmentPatrolType.managementIndex
    fileprivate var safePatrolIsFirstTip = false
    fileprivate var safePatrolSelectNumber = -1
    fileprivate var equipmentPatrolSelectNumber = -1
    fileprivate var equipmentIsLoaded = false
    fileprivate var equipTitles = ["删除当前未上传",
                                   "删除今日未上传",
                                   "删除今日巡检",
                                   "删除所有未上传",
                                   "删除所有巡检"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        navigationController?.navigationBar.setBackgroundImage(BaseTool.createImage(with: UIColor.clear), for: .default)
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.equipmentHeight(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            //cell?.selectionStyle = .none
        }
        
        if let subViews = cell?.contentView.subviews {
            for subView in subViews {
                if subView is SafePatrolDetailView {
                    subView.removeFromSuperview()
                }
            }
        }
        
        var safePatrolDetailView = SafePatrolDetailView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: self.equipmentHeight(indexPath: indexPath)), width: 50.0, count: 4)
        
        if (managementIndexEquipmentPatrolType == .managementIndex) {
            
            let dict = dataSource[indexPath.row] as! NSDictionary
            var imageColor = "icon_kpi_"
            let lightContent = dict["KPILight"] as! NSString
            
            imageColor.append(lightContent as String)
            
            safePatrolDetailView?.reload(withTitles: [String(indexPath.row + 1),dict["KPIName"] ?? "",dict["KPIValue"] ?? "",dict["KPIMemo"] ?? ""], image:imageColor, colors:[UIColor.darkText,UIColor.darkText,UIColor.darkText,UIColor.darkText])
            
        }else if (managementIndexEquipmentPatrolType == .safePatrol) {
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(safePatrolLongPress(longPress:)))
            cell?.contentView.isUserInteractionEnabled = true
            cell?.contentView.addGestureRecognizer(longPress)
            
            safePatrolDetailView = SafePatrolDetailView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44.0), width: kScreenWidth/4.0, count: 4)
            let model = dataSource[indexPath.row] as! SafePatrolModel
            
            var startTime = ""
            if let time = model.StartTime {
                let times = time.components(separatedBy: " ")[1].components(separatedBy: ":")
                startTime = times[0].appending(":").appending(times[1])
            }
            var color = UIColor.black
            if let currentState = model.CurrentState {
                if currentState == "未完成"
                    || currentState == "未提交" {
                    color = UIColor.red
                }
            }
            safePatrolDetailView?.reload(withTitles: [
                model.SecuchkProjectName ?? "",
                model.LineName ?? "",
                startTime,
                model.CurrentState ?? ""], image:"", colors:[UIColor.darkText,UIColor.darkText,UIColor.darkText,color])
            cell?.contentView.tag = indexPath.row + 1
        } else if managementIndexEquipmentPatrolType == .equipmentPatrol {
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(equipmentPatrolLongPress(longPress:)))
            cell?.contentView.isUserInteractionEnabled = true
            cell?.contentView.addGestureRecognizer(longPress)
            
            //设备巡检
            let dinfoModel = dataSource[indexPath.row] as! EquipmentPatrolGroupDInfosModel
            
            var count = 0
            var noCommitCount = 0
            
            
            for model in dInfoDataSource {
                if let infoModel = model as? EquipmentPatrolGroupModel {
                    if dinfoModel.PollingPK == infoModel.PollingPK {
                        count = count + 1
                        if infoModel.isCommit == "0" {
                            noCommitCount = noCommitCount + 1
                        }
                    }
                }
            }
            
            safePatrolDetailView?.reload(withTitles: [String(indexPath.row + 1),dinfoModel.PollingName ?? "", String(count), String(noCommitCount)], image:"", colors:[UIColor.darkText,UIColor.darkText,UIColor.darkText,UIColor.red])
            
        }
        safePatrolDetailView?.delegate = self
        safePatrolDetailView?.tag = indexPath.row + 1000
        cell?.contentView.addSubview(safePatrolDetailView!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didselect(indexPath: indexPath)
    }
    
    func createUI() {
        
        if (managementIndexEquipmentPatrolType == .managementIndex) {
            self.setTitleView(titles: ["经营指标" as NSString])
            
            projectCell.frame = CGRect(x: 0, y: 114, width: kScreenWidth, height: 44.0)
            projectCell.nameLabel.text = "楼盘"
            self.view.addSubview(projectCell)
            
            let tapGesProjectCell = UITapGestureRecognizer(target: self, action: #selector(tapGesprojectCell(_:)))
            projectCell.addGestureRecognizer(tapGesProjectCell)
            
            let lineView = UIView(frame: CGRect(x: 0, y: 43.5, width: kScreenWidth, height: 1))
            lineView.backgroundColor = UIColor.groupTableViewBackground
            projectCell.addSubview(lineView)
            
            buildCell.frame = CGRect(x: 0, y: 114 + projectCell.frame.size.height, width: kScreenWidth, height: 44.0)
            buildCell.nameLabel.text = "楼阁"
            self.view.addSubview(buildCell)
            
            let tapGesBuildCell = UITapGestureRecognizer(target: self, action: #selector(tapGesBuildCell(_:)))
            
            buildCell.addGestureRecognizer(tapGesBuildCell)
            
            projectCell.contentLabel.text = "全部"
            buildCell.contentLabel.text = "全部"
            
        }else if (managementIndexEquipmentPatrolType == .safePatrol) {
            self.setTitleView(titles: ["安全巡更" as NSString])
        }
        else {
            self.setTitleView(titles: ["设备巡检" as NSString])
        }
        
        myAlarmListTopView = Bundle.main.loadNibNamed("MyAlarmListTopView", owner: self, options: nil)?.first as! MyAlarmListTopView
        myAlarmListTopView.tag = 7777
        myAlarmListTopView.isUserInteractionEnabled = true
        myAlarmListTopView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50 + 64)
        
        
        var itemHeight: CGFloat = 44.0 * 2;
        
        var managementItemView = ManagementItemView(frame: CGRect(x: 0, y: myAlarmListTopView.frame.size.height + itemHeight, width: kScreenWidth, height: 40), titles: ["序号","指标名称","指标值","说明"], width:50)
        
        if (managementIndexEquipmentPatrolType == .equipmentPatrol) {
            itemHeight = 0;
            managementItemView = ManagementItemView(frame: CGRect(x: 0, y: myAlarmListTopView.frame.size.height, width: kScreenWidth, height: 40), titles: ["序号","巡检点","巡检次数","未提交"], width:50)
        }else if (managementIndexEquipmentPatrolType == .safePatrol) {
            itemHeight = 0;
            managementItemView = ManagementItemView(frame: CGRect(x: 0, y: myAlarmListTopView.frame.size.height, width: kScreenWidth, height: 40), titles: ["巡检项目","巡检路线","开始时间","状态"], width:kScreenWidth/4.0)
        }
        self.view.addSubview(managementItemView!)
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: myAlarmListTopView.frame.size.height + itemHeight + (managementItemView?.frame.size.height)!, width: kScreenWidth, height: kScreenHeight), hasHeader: false, hasFooter: false)
        
        self.view.addSubview(myAlarmListTopView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(selectTime))
        myAlarmListTopView.timeLabel.isUserInteractionEnabled = true
        myAlarmListTopView.timeLabel.addGestureRecognizer(tapGes)
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFmt.string(from: Date())
        let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
        todayTime = dateForeStr as! String;
        myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateStr)
        
        let actionTapGes = UITapGestureRecognizer(target: self, action: #selector(actionSelectTime(tap:)))
        
        myAlarmListTopView.foreImageView.isUserInteractionEnabled = true
        myAlarmListTopView.foreImageView.tag = 123
        myAlarmListTopView.foreImageView.addGestureRecognizer(actionTapGes)
        
        let backActionTapGes = UITapGestureRecognizer(target: self, action: #selector(actionSelectTime(tap:)))
        myAlarmListTopView.backImageView.isUserInteractionEnabled = true
        myAlarmListTopView.backImageView.tag = 125
        myAlarmListTopView.backImageView.addGestureRecognizer(backActionTapGes)
        
        floatingView.iconImageView.image = UIImage(named: "icon_sys_pressed")
        
        if (managementIndexEquipmentPatrolType == .equipmentPatrol) {
            
            floatingView.delegate = self
            self.view.addSubview(floatingView)
            
            buttonAction(titles: ["返回","更新标准"], actions: [#selector(pop),#selector(equipmentPatrolUpdate)], target: self)
        }else if (managementIndexEquipmentPatrolType == .safePatrol) {
            
            floatingView.delegate = self
            self.view.addSubview(floatingView)
        }
        else {
            buttonHeightAction(startY: kScreenHeight - 50, titles: ["返回"], actions: [#selector(pop)], target: self)
        }
        
    }
    
    func datePickerDelegateEnterAction(withDataPicker picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        todayTime = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue);
        lSDatePicker.tempHintsLabel.text = todayTime + ",星期" + getWeekDay(dateTime: value)
        
        myAlarmListTopView.timeLabel.text = lSDatePicker.tempHintsLabel.text
        
        //reloadAlrmData()
    }
    
    func selectItemPickerDelegate(_ picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        todayTime = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue);
        
        lSDatePicker.tempHintsLabel.text = todayTime + ",星期" + getWeekDay(dateTime: value)
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
        
        if managementIndexEquipmentPatrolType == .safePatrol || managementIndexEquipmentPatrolType == .equipmentPatrol {
            //安全巡检
            loadData()
        }
    }
    
    //MARK: FJFloatingViewDelegate
    
    func floatingViewClick() {
        self.startXJRequestdataAction()
        /*
        let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
        qrcodeVC.scanDelegate = self
        self.push(viewController: qrcodeVC)
         */
    }
    
    @objc func equipmentPatrolUpdate() {
        if (managementIndexEquipmentPatrolType == .safePatrol) {
            self.requestData()
        }else if (managementIndexEquipmentPatrolType == .equipmentPatrol){
            //设备巡检
            self.requestData()
        }
    }
    
    @objc func equipmentPatrolCommit() {
        
        let infos = NSMutableArray(capacity: 20)
        
        for model in dInfoDataSource {
            
            let groupModel = model as! EquipmentPatrolGroupModel
            
            if groupModel.isCommit == "1" {
                continue
            }
            
            let infoItem = NSMutableDictionary(dictionary: groupModel.yy_modelToJSONObject() as! NSDictionary)
            infoItem.removeObject(forKey: "jsonContent")
            infoItem.removeObject(forKey: "isCommit")
            infoItem.removeObject(forKey: "pk")
            infoItem["Contents"] = BaseTool.dictionary(withJsonString: groupModel.jsonContent)
            
            infos.add(infoItem)
        }
        
        
        LoadView.storeLabelText = "正在提交设备巡检"
        
        let addInspectionPlanAPICmd = AddInspectionPlanAPICmd()
        addInspectionPlanAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        addInspectionPlanAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "", "Infos": BaseTool.toJson(infos)]
        addInspectionPlanAPICmd.loadView = LoadView()
        addInspectionPlanAPICmd.loadParentView = self.view
        addInspectionPlanAPICmd.transactionWithSuccess({ (response) in
            
            print(response)
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                
                
                for model in self.dInfoDataSource {
                    
                    let groupModel = model as! EquipmentPatrolGroupModel
                    groupModel.isCommit = "1"
                    groupModel.update()
                    
                }
                
                self.loadData()
                LocalToastView.toast(text: "提交成功")
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    func getWeekDay(dateTime:String) -> String{
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFmt.date(from: dateTime)
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
    
    func loadData() {
        
        self.customerDataSource.removeAllObjects()
        
        if (managementIndexEquipmentPatrolType == .safePatrol) {
            //安全巡更
            
            if ((UserDefaults.standard.object(forKey: QuerySecuchkLinesKey)) != nil) {
                self.dataSource = NSMutableArray(array: SafePatrolModel.findAll().filter({ (model) -> Bool in
                    let safePatorlModel = model as! SafePatrolModel
                    return (safePatorlModel.StartTime?.hasPrefix(todayTime))!
                }))
                
                self.contentTableView?.reloadData()
                
                if !safePatrolIsFirstTip {
                    safePatrolIsFirstTip = true
                    startXJAction()
                }
                
//                if self.dataSource.count == 0 {
//                    floatingView.isHidden = true
//                } else {
//                    floatingView.isHidden = false
//                }
                
            }else {
                let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "未下载巡检路线，是否更新巡检路线？", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "稍后加载", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                })
                let confirmAction = UIAlertAction(title: "立即加载", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    self.requestData()
                })
                tipAlertView.addAction(cancelAction)
                tipAlertView.addAction(confirmAction)
                self.present(tipAlertView, animated: true, completion: {})
            }
            
            if (SafePatrolModel.findAll().count == 0) {
                buttonAction(titles: ["返回","更新路线"], actions: [#selector(pop),#selector(equipmentPatrolUpdate)], target: self)
            }else {
                buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(equipmentPatrolUpdate)], target: self)
            }
            
        } else if managementIndexEquipmentPatrolType == .equipmentPatrol {
            
            equipmentIsLoaded = true
            if EquipmentPatrolGroupDInfosModel.findAll().count != 0 {
                dataSource = NSMutableArray(array: EquipmentPatrolGroupDInfosModel.findAll())
                
                dInfoDataSource = NSMutableArray(array: EquipmentPatrolGroupModel.findAll().filter({ (model) -> Bool in
                    let equipPatorlModel = model as! EquipmentPatrolGroupModel
                    return (equipPatorlModel.FinishTime?.hasPrefix(todayTime))!
                }))
                
                dataSource = NSMutableArray(array: dataSource.sorted(by: { (first, second) -> Bool in
                    let modelF = first as! EquipmentPatrolGroupDInfosModel
                    let modelS = second as! EquipmentPatrolGroupDInfosModel
                    if let pollNameF = modelF.PollingName, let pollNameS = modelS.PollingName {
                        return (pollNameF.compare(pollNameS) == .orderedAscending ? true : false)
                    }
                    return false
                }))
            }
            
            var isExistNoCommit = false
            
            for model in dInfoDataSource {
                if let groupModel = model as? EquipmentPatrolGroupModel {
                    if groupModel.isCommit == "0" {
                        isExistNoCommit = true
                        break
                    }
                }
            }
            
            if !isExistNoCommit {
                if !equipmentIsLoaded {
                    self.requestData()
                }
                buttonAction(titles: ["返回","更新标准"], actions: [#selector(pop),#selector(equipmentPatrolUpdate)], target: self)
            } else {
                buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(equipmentPatrolCommit)], target: self)
            }
            
            self.contentTableView?.reloadData()
            
        } else {
            
            let response = UserDefaults.standard.object(forKey: HouseStructureDataSynchronization)
            
            let dict = JSON(response ?? {})
            let arr = dict["PProjects"]
            for (_,tempDict) in arr {
//                let houseModel:HouseStructureModel = HouseStructureModel();
//                houseModel.setValuesForKeys(tempDict as! [String : Any]);
//                self.customerDataSource.add(houseModel)
                if let houseStructureModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                    self.customerDataSource.add(houseStructureModel)
                }
                
            }
            
            self.requestData()
        }
        
    }
    
    func startXJAction() {
        
        let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "是否立即开始巡检？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "稍后开始", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            //self.scan(result: "ssdssdasdfsdf")
        })
        let confirmAction = UIAlertAction(title: "立即开始", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.startXJRequestdataAction()
        })
        tipAlertView.addAction(cancelAction)
        tipAlertView.addAction(confirmAction)
        self.present(tipAlertView, animated: true, completion: {})
    }
    
    func startXJRequestdataAction() {
        //立即开始巡检
        if (managementIndexEquipmentPatrolType == .safePatrol) {
            let safe = SafePatrolViewController()
            self.push(viewController: safe)
        }else if (managementIndexEquipmentPatrolType == .equipmentPatrol) {
            let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
            qrcodeVC.scanType = .equipmentPatrol
            qrcodeVC.scanDelegate = self
            self.push(viewController: qrcodeVC)
        }
    }
    
    //MARK: ActionSheetDelegate
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if tag == "SafePatrolHandleDeleteStyle" {
            
            //安全巡更
            if buttonIndex == 1 {
                if safePatrolSelectNumber == -1 {
                    return
                }
                let model = self.dataSource[safePatrolSelectNumber - 1] as! SafePatrolModel
                model.deleteObject()
                loadData()
            } else if buttonIndex == 2 || buttonIndex == 3 {
                
                var tip = "确认删除所有未提交？"
                if buttonIndex == 3 {
                    tip = "确认删除所有数据？"
                }
                
                let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: tip, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                })
                let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    if buttonIndex == 3 {
                        SafePatrolModel.clearTable()
                    } else {
                        SafePatrolModel.deleteObjects(byCriteria: " WHERE CurrentState = '未提交'")
                    }
                    self.loadData()
                })
                
                tipAlertView.addAction(confirmAction)
                tipAlertView.addAction(cancelAction)
                self.present(tipAlertView, animated: true, completion: {})
            }
            
            return
        } else if tag == "EquipmentPatrolHandleDeleteStyle" {
            
            var tip = "确认执行["
            tip.append(equipTitles[buttonIndex - 1])
            tip.append("]操作？")
            
            let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: tip, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
                (action: UIAlertAction) -> Void in
            })
            let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                
                let todayFore = self.todayTime.components(separatedBy: " ").first
                switch buttonIndex {
                case 1:
                    for model in self.dInfoDataSource {
                        if let infoModel = model as? EquipmentPatrolGroupModel {
                            if infoModel.isCommit == "0" {
                                infoModel.deleteObject()
                            }
                        }
                    }
                case 2:
                    for model in self.dInfoDataSource {
                        if let infoModel = model as? EquipmentPatrolGroupModel {
                            if let finishTime = infoModel.FinishTime {
                                if infoModel.isCommit == "0" && finishTime.hasPrefix(todayFore!) {
                                    infoModel.deleteObject()
                                }
                            }
                        }
                    }
                case 3:
                    for model in EquipmentPatrolGroupModel.findAll() {
                        if let infoModel = model as? EquipmentPatrolGroupModel {
                            if let finishTime = infoModel.FinishTime {
                                if finishTime.hasPrefix(todayFore!) {
                                    infoModel.deleteObject()
                                }
                            }
                        }
                    }
                case 4:
                    EquipmentPatrolGroupModel.deleteObjects(byCriteria: " WHERE isCommit = '0'")
                case 5:
                    EquipmentPatrolGroupModel.clearTable()
                default:
                    break
                }
                self.loadData()
            })
            
            tipAlertView.addAction(confirmAction)
            tipAlertView.addAction(cancelAction)
            self.present(tipAlertView, animated: true, completion: {})
            
            return
        }
        
        if (buttonIndex == 1) {
            
            if (tag.compare("1357") == .orderedSame) {
                projectCell.contentLabel.text = "全部"
                buildCell.contentLabel.text = "全部"
                pProjectCode = ""
                pBuildingCode = ""
            }else {
                buildCell.contentLabel.text = "全部"
                pBuildingCode = ""
            }
            requestData()
            return
        }
        
        if (tag.compare("1357") == .orderedSame) {
            buildIndex = buttonIndex - 2
        }else {
            roomIndex = buttonIndex - 2
        }
        
        let model = self.customerDataSource[buildIndex] as! HouseStructureModel
        
        print(self.customerDataSource[buildIndex])
        
        if (tag.compare("1357") == .orderedSame) {
            projectCell.contentLabel.text = model.Name ?? ""
            buildCell.contentLabel.text = "全部"
            pProjectCode = model.Code ?? ""
            pBuildingCode = ""
        }else {
            // model.PBuildings?
            let dict = (tempDataSource[roomIndex] as! NSDictionary)
            pBuildingCode = (dict["Code"] as? String)!
            buildCell.contentLabel.text = (tempDataSource[roomIndex] as! NSDictionary)["Name"] as? String
        }
        
        requestData()
    }
    
    //MARK: EmptyDataSource
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        if (managementIndexEquipmentPatrolType == .equipmentPatrol) {
            return -140 
        }
        return -130.0
    }
    
    //MARK: ScanResultDelegate
    
    func scan(result: String) {
        
        //LocalToastView.toast(text: result)
        var isExist = false
        if managementIndexEquipmentPatrolType == .safePatrol {
            let itemResult = DataInfoDetailManager.shareInstance().fetchEquipmentPatrol(withData: UserDefaults.standard.object(forKey: QueryInspectionItemsKey), type: 0, key: result) as NSDictionary
            
            let itemResultSource = NSMutableArray(array: (itemResult["Item"] as! NSArray))
            for sub in itemResultSource {
                if let dict = sub as? NSDictionary {
                    if let no = dict["FlagNo"] as? String, result == no {
                        isExist = true
                        break
                    }
                }
            }
            
        } else if managementIndexEquipmentPatrolType == .equipmentPatrol {
            let itemSource = EquipmentPatrolGroupDInfosModel.findAll()
            for sub in itemSource! {
                if let model = sub as? EquipmentPatrolGroupDInfosModel {
                    if let no = model.FlagNo, result == no {
                        isExist = true
                        break
                    }
                }
            }
        }
        
        if !isExist {
            LocalToastView.toast(text: "该巡检点没有匹配的设备!")
            return;
        }
        let equipmentPatrol = EquipmentPatrolGroupViewController()
        equipmentPatrol.scanResult = result
        self.push(viewController: equipmentPatrol)
    }
    
    //MARK: 选择楼盘
    @objc func tapGesprojectCell(_ view :UIView) {
        
        var titles = Array<Any>()
        var index = 0
        
        titles.insert("全部", at: index)
        index = 1
        for model in self.customerDataSource {
            let tempModel: HouseStructureModel = model as! HouseStructureModel
            titles.insert(tempModel.Name ?? "", at: index)
            index = index + 1
        }
        showActionSheet(title: "选择楼盘", cancelTitle: "取消", titles: titles, tag: "1357")
        
    }
    
    //MARK: 选择楼阁
    @objc func tapGesBuildCell(_ view :UIView) {
        
        var titles = Array<Any>()
        var index = 0
        
        titles.insert("全部", at: index)
        index = 1
        let tempModel = self.customerDataSource[buildIndex] as! HouseStructureModel
        tempDataSource.removeAllObjects()
        let ldArr = NSMutableArray();
        let otherArr = NSMutableArray();
        otherArr.insert("全部", at: 0);
        for tempDict in tempModel.PBuildings! {
            let dic = tempDict as! NSDictionary;
            if (dic.allKeys as NSArray).contains("buildType") {
                let str:String = dic["buildType"] as! String;
                if str == "楼栋" {
                    ldArr.add(tempDict);
                }
                else {
                    tempDataSource.add(tempDict)
                    otherArr.add((tempDict as! NSDictionary)["Name"] ?? "");
                }
            }
            else {
                otherArr.add((tempDict as! NSDictionary)["Name"] ?? "");
                tempDataSource.add(tempDict)
            }
        }
        let arr = ldArr.sorted { (obj1, obj2) -> Bool in
            let dic1 = obj1 as! NSDictionary;
            let dic2 = obj2 as! NSDictionary;
            if dic1["Code"] as! String > dic2["Code"] as! String {
                return true
            }
            else {
                return false
            }
        }
        for tempDict in arr {
            otherArr.insert((tempDict as! NSDictionary)["Name"] ?? "", at: 1)
            tempDataSource.insert(tempDict, at: 0)
        }
        
        titles = otherArr as! [Any];
        
//        for tempDict in tempModel.PBuildings! {
//            let dic = tempDict as! NSDictionary;
//            let str:String = dic["buildType"] as! String;
//            if str == "楼栋" {
//                titles.insert((tempDict as! NSDictionary)["Name"] ?? "", at: 1)
//            }
//            else {
//                titles.insert((tempDict as! NSDictionary)["Name"] ?? "", at: index)
//            }
//            index = index + 1
//        }
        showActionSheet(title: "选择楼阁", cancelTitle: "取消", titles: titles, tag: "1377")
    }

    func noRouteData() {
        
        let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "是否加载路线？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
            (action: UIAlertAction) -> Void in
        })
        let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.requestData()
        })
        tipAlertView.addAction(cancelAction)
        tipAlertView.addAction(confirmAction)
        self.present(tipAlertView, animated: true, completion: {})
        
    }
    
    //MARK:数据加载
    override func requestData() {
        super.requestData()
        
        if (managementIndexEquipmentPatrolType == .safePatrol) {
            //安全巡更
            //QuerySecuchkLinesAPICmd
            
            if (dataSource.count != 0) {
                //提交
                print("提交")
                
                let infos = NSMutableArray(capacity: 20)
                
                for model in self.dataSource {
                    
                    let safePatrolModel = model as! SafePatrolModel
                    
                    if safePatrolModel.CurrentState != "未提交" {
                        continue
                    }
                    
                    let infoItem = NSMutableDictionary(capacity: 20)
                    infoItem["out_trade_no"] = safePatrolModel.out_trade_no ?? ""
                    infoItem["LinePK"] = safePatrolModel.LinePK ?? ""
                    infoItem["StartTime"] = safePatrolModel.StartTime ?? ""
                    infoItem["EndTime"] = safePatrolModel.EndTime ?? ""
                    infoItem["LineCheckState"] = safePatrolModel.LineCheckState ?? ""
                    infoItem["Description"] = safePatrolModel.Description ?? ""
                    
                    let points = NSArray(array: BaseTool.dictionary(withJsonString: safePatrolModel.LinePoints) as! NSArray)
                    infoItem["Points"] = points
                    
                    
                    infos.add(infoItem)
                }
                
                if infos.count == 0 {
                    LocalToastView.toast(text: "已经全部上传完了！")
                    return
                }
                
                LoadView.storeLabelText = "正在提交"
                
                let addSecuchkRecordAPICmd = AddSecuchkRecordAPICmd()
                addSecuchkRecordAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                addSecuchkRecordAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "", "Infos": BaseTool.toJson(infos)]
                addSecuchkRecordAPICmd.loadView = LoadView()
                addSecuchkRecordAPICmd.loadParentView = self.view
                addSecuchkRecordAPICmd.transactionWithSuccess({ (response) in
                    
                    print(response)
                    let dict = JSON(response)
                    
                    print(dict)
                    
                    let resultStatus = dict["result"].string
                    
                    if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                        
                        
                        for model in self.dataSource {
                            
                            let safePatrolModel = model as! SafePatrolModel
                            
                            for sub in dict["infos"].arrayValue {
                                if sub["out_trade_no"].string == safePatrolModel.out_trade_no {
                                    //成功
                                    if safePatrolModel.LineCheckState == "2" {
                                        safePatrolModel.CurrentState = "异常完成"
                                    } else if safePatrolModel.LineCheckState == "3" {
                                        safePatrolModel.CurrentState = "异常终止"
                                    } else {
                                        safePatrolModel.CurrentState = "已提交"
                                    }
                                }
                            }
                            
                            safePatrolModel.saveOrUpdate()
                        }
                        
                        self.contentTableView?.reloadData()
                        LocalToastView.toast(text: "提交成功")
                    }else {
                        LocalToastView.toast(text: dict["msg"].string!)
                    }
                    
                }) { (response) in
                    LocalToastView.toast(text: DisNetWork)
                }
                
            }else {
                
                LoadView.storeLabelText = "正在更新巡检路线"
                
                let querySecuchkLinesAPICmd = QuerySecuchkLinesAPICmd()
                querySecuchkLinesAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                querySecuchkLinesAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
                querySecuchkLinesAPICmd.loadView = LoadView()
                querySecuchkLinesAPICmd.loadParentView = self.view
                querySecuchkLinesAPICmd.transactionWithSuccess({ (response) in
                    
                    print(response)
                    let dict = JSON(response)
                    
                    print(dict)
                    
                    let resultStatus = dict["result"].string
                    
                    if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                        
                        //成功
                        DataInfoDetailManager.shareInstance().storeSafePatrolData((response as! NSDictionary)["Infos"])
                        
                        self.startXJAction()
                        LocalToastView.toast(text: "加载成功")
                    }else {
                        LocalToastView.toast(text: dict["msg"].string!)
                    }
                    
                }) { (response) in
                    LocalToastView.toast(text: DisNetWork)
                }
                
            }
            
            
        }else if (managementIndexEquipmentPatrolType == .managementIndex) {
            //经营指标
            
            //AccountCode=0002&Caldate=2016-05-05&pProjectCode=0101
            LoadView.storeLabelText = "正在加载经营指标信息"
            
            let kPIRecordAPICmd = KPIRecordAPICmd()
            kPIRecordAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            kPIRecordAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "",
                                          "pProjectCode":pProjectCode ,"pBuildingCode":pBuildingCode,"Caldate":todayTime,"version":"1.0"]
            kPIRecordAPICmd.loadView = LoadView()
            kPIRecordAPICmd.loadParentView = self.view
            kPIRecordAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.dataSource = NSMutableArray(array: ((response as! NSDictionary)["infos"] as! NSArray))
                    let frame = self.contentTableView?.frame
                    self.contentTableView?.frame = CGRect(x: (frame?.origin.x)!, y: (frame?.origin.y)!, width: (frame?.size.width)!, height: kScreenHeight - 114 - 44 * 2.0 - 90)
                    self.contentTableView?.separatorStyle = .none
                    self.contentTableView?.reloadData()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }else if (managementIndexEquipmentPatrolType == .equipmentPatrol) {
            
            LoadView.storeLabelText = "正在下载"
            
            let queryInspectionItemsAPICmd = QueryInspectionItemsAPICmd()
            queryInspectionItemsAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            queryInspectionItemsAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            queryInspectionItemsAPICmd.loadView = LoadView()
            queryInspectionItemsAPICmd.loadParentView = self.view
            queryInspectionItemsAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)

                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    UserDefaults.standard.set(dict.rawString(), forKey: QueryInspectionItemsKey)
                    UserDefaults.standard.synchronize()
                    
                    EquipmentPatrolGroupItemModel.clearTable()
                    EquipmentPatrolGroupDInfosModel.clearTable()
                    EquipmentPatrolGroupPInfosModel.clearTable()
                    self.dataSource.removeAllObjects()
                    
                    for (_,tempDict) in dict["items"] {
                        
                        if let itemModel:EquipmentPatrolGroupItemModel = EquipmentPatrolGroupItemModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            itemModel.save()
                        }
                        
                    }
                    
                    for (_,tempDict) in dict["dinfos"] {
                        
                        if let dinfoModel:EquipmentPatrolGroupDInfosModel = EquipmentPatrolGroupDInfosModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.dataSource.add(dinfoModel)
                            dinfoModel.save()
                        }
                        
                    }
                    
                    for (_,tempDict) in dict["pinfos"] {
                        
                        if let pinfoModel:EquipmentPatrolGroupPInfosModel = EquipmentPatrolGroupPInfosModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            pinfoModel.save()
                        }
                        
                    }
                    self.contentTableView?.reloadData()
                    self.startXJAction()
                    LocalToastView.toast(text: "下载成功")
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }
    }
    
    func equipmentHeight(indexPath: IndexPath) -> CGFloat{
        
        if managementIndexEquipmentPatrolType == .managementIndex {
            let dict = dataSource[indexPath.row] as! NSDictionary
            if let memo = dict["KPIMemo"] {
                let height = DataInfoDetailManager.caculateHeight(withContent: memo as! String, font: UIFont.systemFont(ofSize: 15), width: (kScreenWidth - 50)/3.0)
                if height < 44.0 {
                    return 44.0
                }
                return height
            }
        }
        
        return 44.0
    }
}

extension ManagementIndexEquipmentPatrolViewController {
    @objc func safePatrolLongPress(longPress: UILongPressGestureRecognizer) {
        safePatrolSelectNumber = (longPress.view?.tag)!
        showActionSheet(title: "选择操作对象", cancelTitle: "取消", titles: ["删除当前","删除所有未提交","删除所有"], tag: "SafePatrolHandleDeleteStyle")
    }
    
    @objc func equipmentPatrolLongPress(longPress: UILongPressGestureRecognizer) {
        equipmentPatrolSelectNumber = (longPress.view?.tag)!
        showActionSheet(title: "选择操作对象", cancelTitle: "取消", titles: equipTitles, tag: "EquipmentPatrolHandleDeleteStyle")
    }
    
    func didselect(indexPath: IndexPath) {
        
        if (managementIndexEquipmentPatrolType == .safePatrol) {
            
            let model = dataSource[indexPath.row] as! SafePatrolModel
            
            let source = NSMutableArray(array: UserDefaults.standard.object(forKey: QuerySecuchkLinesKey) as! NSArray)
            
            var detailDict = NSDictionary()
            
            let secuchkProjectPK = model.SecuchkProjectPK!
            let linePK = model.LinePK!
            for dict in source {
                let tempDict = dict as! NSDictionary
                let pk = tempDict["SecuchkProjectPK"] as! NSString
                if (pk.compare(secuchkProjectPK) == .orderedSame) {
                    let array = tempDict["Lines"] as! NSArray
                    for subDict in array {
                        let subPk = (subDict as! NSDictionary)["LinePK"] as! NSString
                        if (subPk.compare(linePK) == .orderedSame) {
                            detailDict = NSDictionary(dictionary: subDict as! NSDictionary)
                            break
                        }
                    }
                }
            }
            
            //            //跳转
            let detail = SafePatrolDetailViewController()
            detail.safePatrolModel = model
            detail.info = detailDict
            detail.projectInfo = model.yy_modelToJSONObject() as! NSDictionary
            detail.isPop = true
            //            detail.linePK = dict["LinePK"] as! String
            //            detail.secuchkProjectPK = dict["SecuchkProjectPK"] as! String
            self.push(viewController: detail)
            
        } else if managementIndexEquipmentPatrolType == .equipmentPatrol {
            //设备巡检
            let equipmentDetail = EquipmentPatrolDetailViewController()
            
            let dinfoModel = dataSource[indexPath.row] as! EquipmentPatrolGroupDInfosModel
            equipmentDetail.dInfoModel = dinfoModel
            
            var count = 0
            
            for model in dInfoDataSource {
                if let infoModel = model as? EquipmentPatrolGroupModel {
                    if dinfoModel.PollingPK == infoModel.PollingPK {
                        count = count + 1
                    }
                }
            }
            
            if count == 0 {
                LocalToastView.toast(text: "没有巡检内容，不可查看")
                return
            }
            
            self.push(viewController: equipmentDetail)
            
        }
    }
}

extension ManagementIndexEquipmentPatrolViewController: SafePatrolDetailViewDelegate {
    func selectSafePatrolDetailViewItem(_ tag: Int) {
        didselect(indexPath: IndexPath(row: tag, section: 0))
    }
}
