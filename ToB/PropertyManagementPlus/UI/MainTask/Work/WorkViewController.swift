//
//  WorkViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

/*
import UIKit
import SwiftyJSON
import HandyJSON

class WorkViewController: LinkBaseViewController,UITableViewDataSource,UITableViewDelegate,HomeItemTableViewCellDelegate {

    var topView:UIView?
    var onlineLabel: UILabel!
    var taskDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var roleInfoDataSource : NSMutableArray = NSMutableArray(capacity: 20)
    
    var noCommitInfoDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var roleTitles: NSMutableArray = NSMutableArray(capacity: 20)
    var roleImages : NSMutableArray = NSMutableArray(capacity: 20)
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTitle), name: NSNotification.Name(rawValue: kNotificationCenterHomeChangeState), object: nil)
        
        self.initData()
        self.initContentUI()
        refreshUI()
        
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTitle()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func refreshContent() {
        self.setTitleView(titles: ["工作"])
        if appDelegate.slider.tabBarController != nil {
            appDelegate.slider.tabBarController.customerNavigation.reload(withTitle: "工作")
            appDelegate.slider.tabBarController.customerNavigation.backgroundColor = UIColor.clear
        }
    }
    
    @objc fileprivate func refreshTitle() {
        self.isOnline = false
        self.setTitleView(titles: ["工作"])
        //去掉NavigationBar的背景和横线
        navigationController?.navigationBar.subviews[0].isHidden = true
    }
    
    private func refreshUI() {
        
        let normalHeader = NormalAnimator.normalAnimator()
        normalHeader.lastRefreshTimeKey = "exampleHeader1"
        
        contentTableView?.zj_addRefreshHeader(normalHeader, refreshHandler: {[weak self] in
            self?.requestData()
        })
        
    }
    
    private func initData() {
        taskDataSource = NSMutableArray(capacity: 20)
        
    }
    
    private func initContentUI () {
        self.initTopView()
        
        contentTableView = UITableView(frame: CGRect(x: 0, y: (topView?.frame.size.height)!, width: kScreenWidth, height: kScreenHeight - (topView?.frame.size.height)! - 44), style: .grouped)
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        contentTableView?.separatorStyle = .none
        
        contentTableView?.separatorInset = .zero
        contentTableView?.layoutMargins = .zero
        if #available(iOS 9.0, *) {
            contentTableView?.cellLayoutMarginsFollowReadableWidth = false
        } else {
            // Fallback on earlier versions
        }
        self.view.addSubview(contentTableView!)
        
    }
    
    private func initTopView(){
        let totalHeight = 3*kWorkBarHeight
        topView = {
            let tempTopView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: totalHeight))
            
            tempTopView.backgroundColor = kThemeColor
            view.addSubview(tempTopView)
            return tempTopView
            
        }()
        let imageViewWidth:CGFloat = (kScreenWidth/4)
        for index in 0...3{
            let imageView = UIImageView()
            imageView.tintColor = UIColor.white
            imageView.isUserInteractionEnabled = true
            imageView.frame =  CGRect(x: imageViewWidth * CGFloat(index), y: kWorkBarHeight, width: imageViewWidth, height: totalHeight - kWorkBarHeight)
            
            let titleLabel = UILabel(frame:CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y+(totalHeight - kWorkBarHeight)*1.7/3 + 10, width: imageViewWidth, height: 30))
            titleLabel.textColor = UIColor.white
            
            if index==0{
                imageView.image = UIImage(named: "icon_index_sys_normal")
                titleLabel.text = "扫一扫"
            }else if index==1{
                imageView.image = UIImage(named: "icon_sjgx_normal")
                titleLabel.text = "数据加载"
            }else if index==2{
                imageView.image = UIImage(named: "icon_index_add_normal")
                titleLabel.text = "新增"
            }else if index==3{
                let online = LocalStoreData.getOnLine()
                imageView.image = UIImage(named: online ? "icon_on_line": "icon_off_line")
                titleLabel.text = online ? "已开始作业" : "请开始作业"
                titleLabel.textColor = online ? UIColor.white: UIColor.red
                onlineLabel = titleLabel
            }
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            imageView.tag = index
            imageView.contentMode = .center;
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(topButtonClick(sender:)))
            
            imageView .addGestureRecognizer(tap)
            topView?.addSubview(imageView)
            topView?.addSubview(titleLabel)
        }
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else if section == 1 {
            if (noCommitInfoDataSource.count == 0) {
                return 1
            }
            return noCommitInfoDataSource.count
        }
        return self.taskDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90.0
        }
        if (indexPath.section == 1 && noCommitInfoDataSource.count == 0) {
            return 25;
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.001
        }
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35.0))
        
        
        let lineView = UIView(frame: CGRect(x: 10, y: 0, width: 2, height: 35.0))
        lineView.backgroundColor = kThemeColor
        
        
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35.0))
        contentLabel.backgroundColor = UIColor.groupTableViewBackground
        contentLabel.textColor = kMarkColor
        contentLabel.font = UIFont.boldSystemFont(ofSize: 17)
        contentLabel.text = (section == 1 ? "  未提交信息": "  待办任务")
        
        contentLabel.addSubview(lineView)
        
        return contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        if indexPath.section == 0 {
            
            var homeItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if homeItemTableViewCell == nil {
                
                homeItemTableViewCell = HomeItemTableViewCell(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 90.0), lineNumber: indexPath.row,roles: self.roleInfoDataSource , type: 1)
                homeItemTableViewCell?.selectionStyle = .none
                (homeItemTableViewCell as! HomeItemTableViewCell).delegate = self
                
                homeItemTableViewCell?.separatorInset = .zero
                homeItemTableViewCell?.layoutMargins = .zero
                homeItemTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            return homeItemTableViewCell!
        }
        
        if (indexPath.section == 1 && noCommitInfoDataSource.count == 0) {
            
            let normalCellIdentifier = "normalCellIdentifier"
            
            var tableViewCell = tableView.dequeueReusableCell(withIdentifier: normalCellIdentifier);
            if (tableViewCell == nil) {
                tableViewCell = UITableViewCell(style: .default, reuseIdentifier: normalCellIdentifier)
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 25))
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 15.0)
                label.textColor = UIColor.gray
                label.text = "暂时无内容"
                tableViewCell?.contentView.addSubview(label)
            }
            
            return tableViewCell!
        }
        
        var taskNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskNumberTableViewCell == nil {
            
            taskNumberTableViewCell = Bundle.main.loadNibNamed("TaskNumberTableViewCell", owner: nil, options: nil)?.first as! TaskNumberTableViewCell
            
            taskNumberTableViewCell?.separatorInset = .zero
            taskNumberTableViewCell?.layoutMargins = .zero
            taskNumberTableViewCell?.preservesSuperviewLayoutMargins = false
        }
        
        let tempCell: TaskNumberTableViewCell = (taskNumberTableViewCell as! TaskNumberTableViewCell)
        
        tempCell.accessoryType = .disclosureIndicator
        
        if (indexPath.section == 2) {
            
            let model: GetTaskInfoModel = self.taskDataSource[indexPath.row] as! GetTaskInfoModel
            tempCell.nameLabel.text = model.name
            tempCell.numberLabel.text = model.num
            
        }else {
            
            let dict = noCommitInfoDataSource[indexPath.row] as! NSDictionary
            let key = dict.allKeys.first as! String
            if (key.compare("RepairNoCommit") == .orderedSame) {
                tempCell.nameLabel.text = "维修"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_wxrw@2x")
            } else if (key.compare("EventCustomer") == .orderedSame) {
                tempCell.nameLabel.text = "客户事件"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_khsj@2x")
            } else if (key.compare("WareHouseIn") == .orderedSame) {
                tempCell.nameLabel.text = "入仓单"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_ckrc@2x")
            } else if (key.compare("WareHouseOut") == .orderedSame) {
                tempCell.nameLabel.text = "出仓单"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_ckcc@2x")
            } else if key == "EquipmentPatrol" {
                tempCell.nameLabel.text = "设备巡检"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_sbxj@2x")
            } else if key == "SafePatrol" {
                tempCell.nameLabel.text = "安全巡更"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_aqxg@2x")
            } else if key == "SafeCheck" {
                tempCell.nameLabel.text = "安全检查"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_aqjc@2x")
            }
            else {
                tempCell.nameLabel.text = "投诉"
                tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_tscl@2x")
            }
            tempCell.leftConstraint.constant = 50
            if (key.compare("EventCustomer") == .orderedSame
                || key.compare("WareHouseIn") == .orderedSame
                || key.compare("WareHouseOut") == .orderedSame
                || key == "EquipmentPatrol"
                || key == "SafePatrol"
                || key == "SafeCheck") {
                let countSource = dict[key] as! NSArray
                tempCell.numberLabel.text = String(countSource.count)
            }else {
                tempCell.numberLabel.text = dict.allValues.first as? String
            }
        }
        
        return taskNumberTableViewCell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if LocalStoreData.getOnLine() == false {
            LocalToastView.toast(text: "请开始作业！")
            return;
        }
        
        if (indexPath.section == 2) {
            //let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //appDelegate.slider.tabBarController.selectedIndex = 1
            
            //流程修改，任务列表
            
            let task:TaskViewController = TaskViewController()
            
            let model: GetTaskInfoModel = self.taskDataSource[indexPath.row] as! GetTaskInfoModel
            task.taskTag = NSString(string: model.tag!)
            task.taskNumber = NSString(string: model.num!)
            self.push(viewController: task)
            
            
        }else if(indexPath.section == 1){
            
            if (noCommitInfoDataSource.count == 0) {
                return;
            }
            
            
            let dict = noCommitInfoDataSource[indexPath.row] as! NSDictionary
            let key = dict.allKeys.first as! String
            
            if (key.compare("RepairNoCommit") == .orderedSame) {
                //维修
                self.push(viewController: RepairTaskViewController())
                
            }else if (key.compare("EventCustomer") == .orderedSame) {
                
                let eventList = EventListViewController()
                eventList.eventType = .eventCustomer
                self.push(viewController: eventList)
                
            }else if (key.compare("WareHouseIn") == .orderedSame) {
                
                let eventList = EventListViewController()
                eventList.eventType = .warehouseIn
                self.push(viewController: eventList)
                
            }else if (key.compare("WareHouseOut") == .orderedSame) {
                
                let eventList = EventListViewController()
                eventList.eventType = .warehouseOut
                self.push(viewController: eventList)
                
            } else if key == "EquipmentPatrol" {
                let vc = ManagementIndexEquipmentPatrolViewController()
                vc.managementIndexEquipmentPatrolType = .equipmentPatrol
                self.push(viewController: vc)
            } else if key == "SafePatrol" {
                let vc = ManagementIndexEquipmentPatrolViewController()
                vc.managementIndexEquipmentPatrolType = .safePatrol
                self.push(viewController: vc)
            } else if key == "SafeCheck" {
                let unCommitVC = SafeCheckUnCommitViewController()
                self.push(viewController: unCommitVC)
            } else {
                //"投诉"
                self.push(viewController: ComplaintHandlingViewController())
            }
            
            
        }
        
    }
    
    @objc func topButtonClick(sender : UITapGestureRecognizer){
        
        let imageView:UIImageView = sender.view as! UIImageView
        
        switch imageView.tag{
        case 0:
            
            let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
            self.push(viewController: qrcodeVC)
            
        case 1:
            self.push(viewController: DataSynchronizationViewController())
        case 2:
            
            let alertVC: LSAlertViewController = LSAlertViewController.alert(withTitle: "选择新增对象", message: "", placeHolder: "", type: CKAlertViewType(rawValue: UInt(3))!)
            
            alertVC.itemImages = NSArray(array: roleImages) as! [Any]
            
            for (index, name) in roleTitles.enumerated() {
                
                let alertAction = CKAlertAction(title: name as! String, handler: { (action) in
                    self.perform(#selector(self.addItem(type:)), with: String(index))
                })
                alertVC.addAction(alertAction)
            }
            
            self.present(alertVC, animated: false, completion: {() in })
            
            print("\(sender.view?.tag)")
        case 3:
            imageView.isUserInteractionEnabled = false
            lineSet(sender: sender)
        default:
            print("\(sender.view?.tag)")
        }
        
    }
    
    @objc func addItem(type: String) {
        
        if (type.compare("0") == .orderedSame) {
            
            let viewController = RepairTaskAddViewController()
            viewController.isHomePage = true
            appDelegate.slider.tabbarNavigationController!.pushViewController(viewController, animated: true)
            
        }else if (type.compare("1") == .orderedSame) {
            
            let complaintHandlingAddVC = ComplaintHandlingAddViewController()
            complaintHandlingAddVC.isHomePage = true
            appDelegate.slider.tabbarNavigationController!.pushViewController(complaintHandlingAddVC, animated: true)
            
        }else if (type.compare("2") == .orderedSame) {
            LocalToastView.toast(text: "IOS端尚未开放，尽请期待！")
        }else if (type.compare("3") == .orderedSame) {
            LocalToastView.toast(text: "IOS端尚未开放，尽请期待！")
        }
    }
    
    override func requestData() {
        
        //未提交信息
        
        var sql = " WHERE Category = 'NoCommit'"
        let noCommitCount = String(GetRepaireListModel.find(byCriteria: sql).count)
        let noCommitDict = NSMutableDictionary(capacity: 10)
        
        noCommitInfoDataSource = NSMutableArray(capacity: 20)
        
        if (noCommitCount.compare("0") != .orderedSame) {
            noCommitDict["RepairNoCommit"] = noCommitCount
            noCommitInfoDataSource.add(noCommitDict)
        }
        
        sql = " WHERE Category = 'NoSend'"
        let noSend = String(AddComplaintFormModel.find(byCriteria: sql).count)
        let noSendDict = NSMutableDictionary(capacity: 10)
        
        if (noSend.compare("0") != .orderedSame) {
            noSendDict["ComplaintNoCommit"] = noSend
            noCommitInfoDataSource.add(noSendDict)
        }
        
        //出仓、入仓、客户事件
        
        //客户事件
        let eventCustomerSource = NSMutableArray(array: AddCustomerEventModel.findAll())
        let eventCustomerNoCommitDict = NSMutableDictionary(capacity: 10)
        if (eventCustomerSource.count != 0) {
            eventCustomerNoCommitDict["EventCustomer"] = eventCustomerSource
            noCommitInfoDataSource.add(eventCustomerNoCommitDict)
        }
        
        //出仓、入仓
        let seperateArray = WarehouseInOutListModel.findAll()
        let wareHouseInSource = NSMutableArray(capacity: 10)
        let wareHouseInNoCommitDict = NSMutableDictionary(capacity: 10)
        let wareHouseOutSource = NSMutableArray(capacity: 10)
        let wareHouseOutNoCommitDict = NSMutableDictionary(capacity: 10)
        for model in seperateArray! {
            
            let tempModel: WarehouseInOutListModel = model as! WarehouseInOutListModel
            
            if (tempModel.WarehouseID != nil) {
                if (tempModel.IsWarehouseRecepit?.compare("1") == .orderedSame) {
                    wareHouseInSource.add(model)
                }else if (tempModel.IsWarehouseRecepit?.compare("0") == .orderedSame){
                    wareHouseOutSource.add(model)
                }
            }
            
        }
        
        if (wareHouseInSource.count != 0) {
            wareHouseInNoCommitDict["WareHouseIn"] = wareHouseInSource
            noCommitInfoDataSource.add(wareHouseInNoCommitDict)
        }
        if (wareHouseOutSource.count != 0) {
            wareHouseOutNoCommitDict["WareHouseOut"] = wareHouseOutSource
            noCommitInfoDataSource.add(wareHouseOutNoCommitDict)
        }
        
        //设备巡检
        let equipSQL =  " WHERE isCommit = '0'"
        let equipmentSource = NSMutableArray(array: EquipmentPatrolGroupModel.find(byCriteria: equipSQL))
        let equipmentNoCommitDict = NSMutableDictionary(capacity: 10)
        
        if (equipmentSource.count != 0) {
            equipmentNoCommitDict["EquipmentPatrol"] = equipmentSource
            noCommitInfoDataSource.add(equipmentNoCommitDict)
        }
        
        //安全巡检
        let safeSource = NSMutableArray(array: SafePatrolModel.findAll())
        let safeNoCommitDict = NSMutableDictionary(capacity: 10)
        
        if (safeSource.count != 0) {
            safeNoCommitDict["SafePatrol"] = safeSource
            noCommitInfoDataSource.add(safeNoCommitDict)
        }
        
        if SafeCheckResultModel.findAllExceptions(["Contents"]).count != 0 {
            let uncommit = SafeCheckUnCommitViewController()
            let source = uncommit.fetchSortDatas()
            //安全检查
            let safeCheckSource = NSMutableArray(array: source)
            let safeCheckNoCommitDict = NSMutableDictionary(capacity: 10)
            if (source.count != 0) {
                safeCheckNoCommitDict["SafeCheck"] = safeCheckSource
                noCommitInfoDataSource.add(safeCheckNoCommitDict)
            }
        }
        
        requestTaskListData()
        requestLoadAppRolesData()
    }
    
    func requestTaskListData() {
        
        LoadView.storeLabelText = "正在加载"
        
        let getTaskInfosAPICmd = GetTaskInfosAPICmd()
        getTaskInfosAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getTaskInfosAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        getTaskInfosAPICmd.loadView = LoadView()
        getTaskInfosAPICmd.loadParentView = self.view
        getTaskInfosAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.taskDataSource.removeAllObjects()
                for (_,tempDict) in dict["infos"] {
                    
                    if let getTaskInfoModel:GetTaskInfoModel = JSONDeserializer<GetTaskInfoModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                        self.taskDataSource.add(getTaskInfoModel)
                    }
                    
                }
                
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
            self.stopFresh()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
        
    }
    
    func requestLoadAppRolesData() {
        
        let roles = RoleInfoModel.findAll()
        
        self.roleInfoDataSource = NSMutableArray(capacity: 20)
        
        for model in roles! {
            let roleModel = model as! RoleInfoModel
            let dict = NSMutableDictionary(capacity: 2)
            dict["Name"] = roleModel.Name
            dict["Code"] = roleModel.Code
            self.roleInfoDataSource.add(dict)
        }
        self.initRoleInfos()
        
        self.contentTableView?.reloadData()
        
        let loadAppRolesAPICmd = LoadAppRolesAPICmd()
        loadAppRolesAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        loadAppRolesAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","ostype":2]
        loadAppRolesAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                RoleInfoModel.delete(roles)
                
                for (_,tempDict) in dict["roleInfo"] {
                    
                    if let roleInfoModel:RoleInfoModel = RoleInfoModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        roleInfoModel.save()
                    }
                }
                
                self.roleInfoDataSource.removeAllObjects()
                self.roleInfoDataSource = NSMutableArray(array: dict["roleInfo"].arrayObject!)
//                self.roleInfoDataSource.add(["Name":"车辆资料","Code":"CLZL"])
//                self.roleInfoDataSource.add(["Name":"设备资料","Code":"SBZL"])
//                self.roleInfoDataSource.add(["Name":"知识库","Code":"ZSK"])
//                self.roleInfoDataSource.add(["Name":"租控表","Code":"ZKB"])
//                self.roleInfoDataSource.add(["Name":"突发事件","Code":"TFSJ"])
//                self.roleInfoDataSource.add(["Name":"客户事件","Code":"KHSJ"])
//                self.roleInfoDataSource.add(["Name":"客户意向","Code":"YXKH"])
//                self.roleInfoDataSource.add(["Name":"能耗抄表","Code":"NHCB"])
//                self.roleInfoDataSource.add(["Name":"经营指标","Code":"JYZB"])
//                self.roleInfoDataSource.add(["Name":"设备巡检","Code":"SBXJ"])
//                self.roleInfoDataSource.add(["Name":"安全巡检","Code":"AQXJ"])
//                self.roleInfoDataSource.add(["Name":"仓库入仓","Code":"CKRC"])
//                self.roleInfoDataSource.add(["Name":"仓库出仓","Code":"CKCC"])
//                self.roleInfoDataSource.add(["Name":"上门收费","Code":"SMSF"])
                self.initRoleInfos()
                
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: "获取功能信息失败！")
            }
            self.stopFresh()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
        
    }
    
    func initRoleInfos() {
        
        self.roleImages.removeAllObjects()
        self.roleTitles.removeAllObjects()
        
        //"能耗抄表","突发事件","设备巡检","安全巡检",
        //"NHCB","TFSJ","SBXJ","AQXJ",
        let array = ["维修任务","投诉处理","客户事件","突发事件","业户资料","车辆资料","设备资料","知识库","租控表","客户事件","客户意向","仓库入仓","仓库出仓","经营指标"]
        let images = ["WXRW","TSCL","KHSJ","TFSJ","YHZL","CLZL","SBZL","ZSK","ZKB","KHSJ","YXKH","CKRC","CKCC","JYZB"]
        for (index, name) in images.enumerated() {
            for dict in self.roleInfoDataSource {
                let tempDict = dict as! NSDictionary
                if ((tempDict["Code"] as! String).hasPrefix(name)) {
                    self.roleTitles.add(array[index])
                    self.roleImages.add(name)
                }
            }
        }
        
    }
    
    func lineSet(sender : UITapGestureRecognizer) {
        
        let onlineState = LocalStoreData.getOnLine()
        
        let imageView:UIImageView = sender.view as! UIImageView
        
        let online = OnOrOutLineAPICmd()
        online.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        online.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","OnLine":!onlineState]
        online.transactionWithSuccess({ (response) in
            
            imageView.image = UIImage(named: (onlineState ? "icon_off_line":"icon_on_line"))
            self.onlineLabel.text = onlineState ? "请开始作业" : "已开始作业"
            self.onlineLabel.textColor = onlineState ? UIColor.red: UIColor.white
            
            imageView.isUserInteractionEnabled = true
          
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                LocalToastView.toast(text: (onlineState ? "停止作业成功":"开始作业成功"))
                LocalStoreData.setUserDefaultsData((onlineState ? "FALSE":"TRUE"), forKey: LocalStoreData.OnLine)
                
                NotificationCenter.default.post(name: kNotificationCenterChangeState as NSNotification.Name, object: nil)

                
            }else {
                LocalToastView.toast(text: (onlineState ? "停止作业失败":"开始作业失败"))
                LocalStoreData.setUserDefaultsData("FALSE", forKey: LocalStoreData.OnLine)
            }
            
        }) { (response) in
            imageView.isUserInteractionEnabled = true
            LocalToastView.toast(text: DisNetWork)
            LocalStoreData.setUserDefaultsData("FALSE", forKey: LocalStoreData.OnLine)
        }
        
    }
    
    func clickItem(_ title: String!) {
        
        if LocalStoreData.getOnLine() == false {
            LocalToastView.toast(text: "请先开始作业！")
            return;
        }
        
        
        switch title {
        case "more":
            
            let tempRoles = NSMutableArray(capacity: 20)
            
            for (index,_) in self.roleInfoDataSource.enumerated() {
                if (index >= 7) {
                    tempRoles.add(self.roleInfoDataSource[index])
                }
            }
            
            let moreVC = MoreViewController()
            moreVC.roleInfoDataSource = tempRoles
            
            self.push(viewController: moreVC)
        default:
            self.clickItemExtentsion(title)
            break
        }
    }
    

}
 */

import UIKit
import SwiftyJSON
import HandyJSON

class WorkViewController: LinkBaseViewController,UITableViewDataSource,UITableViewDelegate,HomeItemTableViewCellDelegate {
    
    var topView:UIView?
    var onlineLabel: UILabel!
    var taskDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var roleInfoDataSource : NSMutableArray = NSMutableArray(capacity: 20)
    var IndicatorsDataSource : NSMutableArray = NSMutableArray(capacity: 20)
    
    var noCommitInfoDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var roleTitles: NSMutableArray = NSMutableArray(capacity: 20)
    var roleImages : NSMutableArray = NSMutableArray(capacity: 20)
    var panels: NSMutableArray  = NSMutableArray();
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTitle), name: NSNotification.Name(rawValue: kNotificationCenterHomeChangeState), object: nil)
        
        self.initData()
        self.initContentUI()
        refreshUI()
        
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTitle()
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationCenterHomeChangeState), object: nil);
    }
    
    @objc func refreshContent() {
        self.setTitleView(titles: ["工作"])
        if appDelegate.slider.tabBarController != nil {
            appDelegate.slider.tabBarController.customerNavigation.reload(withTitle: "工作")
            appDelegate.slider.tabBarController.customerNavigation.backgroundColor = UIColor.clear
        }
    }
    
    @objc fileprivate func refreshTitle() {
        self.isOnline = false
        self.setTitleView(titles: ["工作"])
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        
    }
    
    private func refreshUI() {
        
        let normalHeader = NormalAnimator.normalAnimator()
        normalHeader.lastRefreshTimeKey = "exampleHeader1"
        
        contentTableView?.zj_addRefreshHeader(normalHeader, refreshHandler: {[weak self] in
            self?.requestData()
        })
        
    }
    
    private func initData() {
        taskDataSource = NSMutableArray(capacity: 20)
        
    }
    //MARK:DO 错误
    private func initContentUI () {
        self.initTopView()
        
        contentTableView = UITableView(frame: CGRect(x: 0, y: (topView?.frame.size.height)!, width: kScreenWidth, height: kScreenHeight - (topView?.frame.size.height)! - 44), style: .grouped)
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        contentTableView?.separatorStyle = .none
        
        contentTableView?.separatorInset = .zero
        // 错误位置
        contentTableView?.layoutMargins = .zero
        if #available(iOS 9.0, *) {
            contentTableView?.cellLayoutMarginsFollowReadableWidth = false
        } else {
            // Fallback on earlier versions
        }
        self.view.addSubview(contentTableView!)
        
    }
    
    private func initTopView(){
        let totalHeight = 3*kWorkBarHeight
        topView = {
            let tempTopView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: totalHeight))
            
            tempTopView.backgroundColor = kThemeColor
            view.addSubview(tempTopView)
            return tempTopView
            
        }()
        let imageViewWidth:CGFloat = (kScreenWidth/4)
        for index in 0...3{
            let imageView = UIImageView()
            imageView.tintColor = UIColor.white
            imageView.isUserInteractionEnabled = true
            imageView.frame =  CGRect(x: imageViewWidth * CGFloat(index), y: kWorkBarHeight, width: imageViewWidth, height: totalHeight - kWorkBarHeight)
            
            let titleLabel = UILabel(frame:CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y+(totalHeight - kWorkBarHeight)*1.7/3 + 10, width: imageViewWidth, height: 30))
            titleLabel.textColor = UIColor.white
            
            if index==0{
                imageView.image = UIImage(named: "icon_index_sys_normal")
                titleLabel.text = "扫一扫"
            }else if index==1{
                imageView.image = UIImage(named: "icon_sjgx_normal")
                titleLabel.text = "数据加载"
            }else if index==2{
                imageView.image = UIImage(named: "icon_index_add_normal")
                titleLabel.text = "新增"
            }else if index==3{
                let online = LocalStoreData.getOnLine()
                imageView.image = UIImage(named: online ? "icon_on_line": "icon_off_line")
                titleLabel.text = online ? "已开始作业" : "请开始作业"
                titleLabel.textColor = online ? UIColor.white: UIColor.red
                onlineLabel = titleLabel
            }
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            imageView.tag = index
            imageView.contentMode = .center;
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(topButtonClick(sender:)))
            
            imageView .addGestureRecognizer(tap)
            topView?.addSubview(imageView)
            topView?.addSubview(titleLabel)
        }
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.panels.count - 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else if section == 1 {
            if (noCommitInfoDataSource.count == 0) {
                return 1
            }
            return noCommitInfoDataSource.count
        }
        else if section == 2 {
            if (self.taskDataSource.count == 0) {
                return 1;
            }
            return self.taskDataSource.count
        }
        else if section == 3{
            if IndicatorsDataSource.count == 0 {
                return 1;
            }
            else {
                if IndicatorsDataSource.count % 2 == 0 {
                    return IndicatorsDataSource.count / 2;
                }
                return IndicatorsDataSource.count / 2 + 1;
            }
        }
        else if section == 4 {
            return 1;
        }
        return 1;
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90.0
        }
        if (indexPath.section == 1 && noCommitInfoDataSource.count == 0) {
            return 25;
        }
        if indexPath.section == 3 {
            if self.IndicatorsDataSource.count == 0 {
                return 25;
            }
            return 81;
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.001
        }
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35.0))
        contentView.backgroundColor = UIColor.white
        
        let lineView = UIView(frame: CGRect(x: 10, y: 0, width: 2, height: 35.0))
        lineView.backgroundColor = kThemeColor
        
        
        let contentLabel = UILabel(frame: CGRect(x: 20, y: 0, width: kScreenWidth - 20, height: 35.0))
        contentLabel.backgroundColor = UIColor.white
        contentLabel.textColor = kMarkColor
        contentLabel.font = UIFont.boldSystemFont(ofSize: 17)
        let model = self.panels[section + 1] as! PanelsModel;
        contentLabel.text = model.panelName;
        contentView.addSubview(lineView)
        contentView.addSubview(contentLabel)
        
        return contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        if indexPath.section == 0 {
            
            var homeItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if homeItemTableViewCell == nil {
                
                homeItemTableViewCell = HomeItemTableViewCell(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 90.0), lineNumber: indexPath.row,roles: self.roleInfoDataSource , type: 1)
                homeItemTableViewCell?.selectionStyle = .none
                (homeItemTableViewCell as! HomeItemTableViewCell).delegate = self
                
                homeItemTableViewCell?.separatorInset = .zero
                homeItemTableViewCell?.layoutMargins = .zero
                homeItemTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            return homeItemTableViewCell!
        }
        
        
        if (indexPath.section == 1  && noCommitInfoDataSource.count == 0 || indexPath.section == 4 || (self.IndicatorsDataSource.count == 0 && indexPath.section == 3) || (indexPath.section == 2 && self.taskDataSource.count == 0)) {
            
            let normalCellIdentifier = "normalCellIdentifier"
            
            var tableViewCell = tableView.dequeueReusableCell(withIdentifier: normalCellIdentifier);
            if (tableViewCell == nil) {
                tableViewCell = UITableViewCell(style: .default, reuseIdentifier: normalCellIdentifier)
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 25))
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 15.0)
                label.textColor = UIColor.gray
                label.text = "暂时无内容"
                tableViewCell?.contentView.addSubview(label)
            }
            
            return tableViewCell!
        }
//             else if (indexPath.section == 2 || noCommitInfoDataSource.count != 0) {
        else if (indexPath.section <= 2) {
            var taskNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if taskNumberTableViewCell == nil {
                
                taskNumberTableViewCell = Bundle.main.loadNibNamed("TaskNumberTableViewCell", owner: nil, options: nil)?.first as! TaskNumberTableViewCell
                
                taskNumberTableViewCell?.separatorInset = .zero
                taskNumberTableViewCell?.layoutMargins = .zero
                taskNumberTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            let tempCell: TaskNumberTableViewCell = (taskNumberTableViewCell as! TaskNumberTableViewCell)
            
            tempCell.accessoryType = .disclosureIndicator
            
            if (indexPath.section == 2 ) {
                
                let model: GetTaskInfoModel = self.taskDataSource[indexPath.row] as! GetTaskInfoModel
                tempCell.nameLabel.text = model.name
                tempCell.numberLabel.text = model.num
            }
                
            else if (indexPath.section == 1){
                
                let dict = noCommitInfoDataSource[indexPath.row] as! NSDictionary
                let key = dict.allKeys.first as! String
                if (key.compare("RepairNoCommit") == .orderedSame) {
                    tempCell.nameLabel.text = "维修"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_wxrw@2x")
                } else if (key.compare("EventCustomer") == .orderedSame) {
                    tempCell.nameLabel.text = "客户事件"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_khsj@2x")
                } else if (key.compare("WareHouseIn") == .orderedSame) {
                    tempCell.nameLabel.text = "入仓单"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_ckrc@2x")
                } else if (key.compare("WareHouseOut") == .orderedSame) {
                    tempCell.nameLabel.text = "出仓单"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_ckcc@2x")
                } else if key == "EquipmentPatrol" {
                    tempCell.nameLabel.text = "设备巡检"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_sbxj@2x")
                } else if key == "SafePatrol" {
                    tempCell.nameLabel.text = "安全巡更"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_aqxg@2x")
                } else if key == "SafeCheck" {
                    tempCell.nameLabel.text = "安全检查"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_aqjc@2x")
                }
                else {
                    tempCell.nameLabel.text = "投诉"
                    tempCell.imageView?.image = UIImage(named: "HomeItemViewIcons.bundle/index_tscl@2x")
                }
                tempCell.leftConstraint.constant = 50
                if (key.compare("EventCustomer") == .orderedSame
                    || key.compare("WareHouseIn") == .orderedSame
                    || key.compare("WareHouseOut") == .orderedSame
                    || key == "EquipmentPatrol"
                    || key == "SafePatrol"
                    || key == "SafeCheck") {
                    let countSource = dict[key] as! NSArray
                    tempCell.numberLabel.text = String(countSource.count)
                }else {
                    tempCell.numberLabel.text = dict.allValues.first as? String
                }
            }
            return taskNumberTableViewCell!
        }
        else if (indexPath.section == 3 && self.IndicatorsDataSource.count != 0) {
            let identifyIndicator = "HomeIndicatorCell";
            var cell:HomeIndicatorCell! = (tableView.dequeueReusableCell(withIdentifier: identifyIndicator) as? HomeIndicatorCell);
            if cell == nil {
                cell = HomeIndicatorCell.init(style: .default, reuseIdentifier: identifyIndicator) as HomeIndicatorCell;
                cell.selectionStyle = UITableViewCellSelectionStyle.none;
            }
            
            if (indexPath.row != self.IndicatorsDataSource.count / 2  || self.IndicatorsDataSource.count % 2 == 0) {
                if (IndicatorsDataSource.count == 0) {
                    return UITableViewCell();
                }
                cell.dataSource = [self.IndicatorsDataSource[indexPath.row * 2],self.IndicatorsDataSource[indexPath.row * 2 + 1] ];
                cell.leftView.indicatorItemClick = {
                    index in
                    let vc = HomeIndicatorDetailVC();
                    vc.clickIndex = indexPath.row * 2 + 1;
                    vc.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                    vc.accountCode = self.loginInfo?.accountCode ?? ""
                    vc.upk = self.userInfo?.upk ?? ""
                    vc.panelType = "5"
                    self.navigationController?.pushViewController(vc, animated: true);
                }
                cell.rightView.indicatorItemClick = {
                    index in
                    let vc = HomeIndicatorDetailVC();
                    vc.clickIndex = indexPath.row * 2 + 2;
                    vc.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                    vc.accountCode = self.loginInfo?.accountCode ?? ""
                    vc.upk = self.userInfo?.upk ?? ""
                    vc.panelType = "5"
                    self.navigationController?.pushViewController(vc, animated: true);
                }
            }
            else {
                cell.dataSource = [self.IndicatorsDataSource[indexPath.row * 2]];
                cell.leftView.indicatorItemClick = {
                    index in
                    let vc = HomeIndicatorDetailVC();
                    vc.clickIndex = indexPath.row * 2 + 2;
                    vc.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                    vc.accountCode = self.loginInfo?.accountCode ?? ""
                    vc.upk = self.userInfo?.upk ?? ""
                    vc.panelType = "5"
                    self.navigationController?.pushViewController(vc, animated: true);
                }
            }
            
            return cell;
        }
        else {
            return UITableViewCell();
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if LocalStoreData.getOnLine() == false {
            LocalToastView.toast(text: "请开始作业！")
            return;
        }
        
        if (indexPath.section == 2) {
            //let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //appDelegate.slider.tabBarController.selectedIndex = 1
            
            //流程修改，任务列表
            
            if (self.taskDataSource.count == 0) {
                return;
            }
            
            let model: GetTaskInfoModel = self.taskDataSource[indexPath.row] as! GetTaskInfoModel
            if (model.tag == "2" || model.tag == "1") {
                let task:TaskViewController = TaskViewController()
                task.taskTag = NSString(string: model.tag!)
                task.taskNumber = NSString(string: model.num!)
                self.push(viewController: task)
            }
            else if (model.tag == "4") {
                // 抢单列表
                let viewController = RepairTaskDetailViewController()
                viewController.selectIndex = -1
                viewController.contentType = "4"
                viewController.titleContent = "待抢列表"
                push(viewController: viewController)
            }
            else {
                let vc = RepairTaskDetailViewController();
                var contentType = "";
                if model.tag == "3" {
                    contentType = "1";
                }
                else if model.tag == "5" {
                    contentType = "2";
                }
                else if model.tag == "6" {
                    contentType = "12";
                }
                else if model.tag == "7" {
                    contentType = "6";
                }
                else if model.tag == "8" {
                    contentType = "5";
                }
                vc.selectIndex = 0;
                vc.contentType = contentType;
                vc.titleContent = "维修任务-" + model.name! as NSString?;
                push(viewController: vc);
            }
        }else {
            
            if (noCommitInfoDataSource.count == 0) {
                return;
            }
            
            let dict = noCommitInfoDataSource[indexPath.row] as! NSDictionary
            let key = dict.allKeys.first as! String
            
            if (key.compare("RepairNoCommit") == .orderedSame) {
                //维修
                self.push(viewController: RepairTaskViewController())
                
            }else if (key.compare("EventCustomer") == .orderedSame) {
                
                let eventList = EventListViewController()
                eventList.eventType = .eventCustomer
                self.push(viewController: eventList)
                
            }else if (key.compare("WareHouseIn") == .orderedSame) {
                
                let eventList = EventListViewController()
                eventList.eventType = .warehouseIn
                self.push(viewController: eventList)
                
            }else if (key.compare("WareHouseOut") == .orderedSame) {
                
                let eventList = EventListViewController()
                eventList.eventType = .warehouseOut
                self.push(viewController: eventList)
                
            } else if key == "EquipmentPatrol" {
                let vc = ManagementIndexEquipmentPatrolViewController()
                vc.managementIndexEquipmentPatrolType = .equipmentPatrol
                self.push(viewController: vc)
            } else if key == "SafePatrol" {
                let vc = ManagementIndexEquipmentPatrolViewController()
                vc.managementIndexEquipmentPatrolType = .safePatrol
                self.push(viewController: vc)
            } else if key == "SafeCheck" {
                let unCommitVC = SafeCheckUnCommitViewController()
                self.push(viewController: unCommitVC)
            } else {
                //"投诉"
                self.push(viewController: ComplaintHandlingViewController())
            }
        }
    }
    
    @objc func topButtonClick(sender : UITapGestureRecognizer){
        
        let imageView:UIImageView = sender.view as! UIImageView
        
        switch imageView.tag{
        case 0:
            
            let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
            self.push(viewController: qrcodeVC)
            
        case 1:
            self.push(viewController: DataSynchronizationViewController())
        case 2:
            
            let alertVC: LSAlertViewController = LSAlertViewController.alert(withTitle: "选择新增对象", message: "", placeHolder: "", type: CKAlertViewType(rawValue: UInt(3))!)
            
            alertVC.itemImages = NSArray(array: roleImages) as! [Any]
            
            for (index, name) in roleTitles.enumerated() {
                
                let alertAction = CKAlertAction(title: name as! String, handler: { (action) in
                    self.perform(#selector(self.addItem(type:)), with: String(index))
                })
                alertVC.addAction(alertAction)
            }
            
            self.present(alertVC, animated: false, completion: {() in })
            
            print("\(sender.view?.tag)")
        case 3:
            imageView.isUserInteractionEnabled = false
            lineSet(sender: sender)
        default:
            print("\(sender.view?.tag)")
        }
        
    }
    
    @objc func addItem(type: String) {
        
        if (type.compare("0") == .orderedSame) {
            
            let viewController = RepairTaskAddViewController()
            viewController.isHomePage = true
            appDelegate.slider.tabbarNavigationController!.pushViewController(viewController, animated: true)
            
        }else if (type.compare("1") == .orderedSame) {
            
            let complaintHandlingAddVC = ComplaintHandlingAddViewController()
            complaintHandlingAddVC.isHomePage = true
            appDelegate.slider.tabbarNavigationController!.pushViewController(complaintHandlingAddVC, animated: true)
            
        }else if (type.compare("2") == .orderedSame) {
            LocalToastView.toast(text: "IOS端尚未开放，尽请期待！")
        }else if (type.compare("3") == .orderedSame) {
            LocalToastView.toast(text: "IOS端尚未开放，尽请期待！")
        }
    }
    
    override func requestData() {
        
        //未提交信息
        
        var sql = " WHERE Category = 'NoCommit'"
        let noCommitCount = String(GetRepaireListModel.find(byCriteria: sql).count)
        let noCommitDict = NSMutableDictionary(capacity: 10)
        
        noCommitInfoDataSource = NSMutableArray(capacity: 20)
        
        if (noCommitCount.compare("0") != .orderedSame) {
            noCommitDict["RepairNoCommit"] = noCommitCount
            noCommitInfoDataSource.add(noCommitDict)
        }
        
        sql = " WHERE Category = 'NoSend'"
        let noSend = String(AddComplaintFormModel.find(byCriteria: sql).count)
        let noSendDict = NSMutableDictionary(capacity: 10)
        
        if (noSend.compare("0") != .orderedSame) {
            noSendDict["ComplaintNoCommit"] = noSend
            noCommitInfoDataSource.add(noSendDict)
        }
        
        //出仓、入仓、客户事件
        
        //客户事件
        let eventCustomerSource = NSMutableArray(array: AddCustomerEventModel.findAll())
        let eventCustomerNoCommitDict = NSMutableDictionary(capacity: 10)
        if (eventCustomerSource.count != 0) {
            eventCustomerNoCommitDict["EventCustomer"] = eventCustomerSource
            noCommitInfoDataSource.add(eventCustomerNoCommitDict)
        }
        
        //出仓、入仓
        let seperateArray = WarehouseInOutListModel.findAll()
        let wareHouseInSource = NSMutableArray(capacity: 10)
        let wareHouseInNoCommitDict = NSMutableDictionary(capacity: 10)
        let wareHouseOutSource = NSMutableArray(capacity: 10)
        let wareHouseOutNoCommitDict = NSMutableDictionary(capacity: 10)
        for model in seperateArray! {
            
            let tempModel: WarehouseInOutListModel = model as! WarehouseInOutListModel
            
            if (tempModel.WarehouseID != nil) {
                if (tempModel.IsWarehouseRecepit?.compare("1") == .orderedSame) {
                    wareHouseInSource.add(model)
                }else if (tempModel.IsWarehouseRecepit?.compare("0") == .orderedSame){
                    wareHouseOutSource.add(model)
                }
            }
            
        }
        
        if (wareHouseInSource.count != 0) {
            wareHouseInNoCommitDict["WareHouseIn"] = wareHouseInSource
            noCommitInfoDataSource.add(wareHouseInNoCommitDict)
        }
        if (wareHouseOutSource.count != 0) {
            wareHouseOutNoCommitDict["WareHouseOut"] = wareHouseOutSource
            noCommitInfoDataSource.add(wareHouseOutNoCommitDict)
        }
        
        //设备巡检
        let equipSQL =  " WHERE isCommit = '0'"
        let equipmentSource = NSMutableArray(array: EquipmentPatrolGroupModel.find(byCriteria: equipSQL))
        let equipmentNoCommitDict = NSMutableDictionary(capacity: 10)
        
        if (equipmentSource.count != 0) {
            equipmentNoCommitDict["EquipmentPatrol"] = equipmentSource
            noCommitInfoDataSource.add(equipmentNoCommitDict)
        }
        
        //安全巡检
        let safeSource = NSMutableArray(array: SafePatrolModel.findAll())
        let safeNoCommitDict = NSMutableDictionary(capacity: 10)
        
        if (safeSource.count != 0) {
            safeNoCommitDict["SafePatrol"] = safeSource
            noCommitInfoDataSource.add(safeNoCommitDict)
        }
        
        if SafeCheckResultModel.findAllExceptions(["Contents"]).count != 0 {
            let uncommit = SafeCheckUnCommitViewController()
            let source = uncommit.fetchSortDatas()
            //安全检查
            let safeCheckSource = NSMutableArray(array: source)
            let safeCheckNoCommitDict = NSMutableDictionary(capacity: 10)
            if (source.count != 0) {
                safeCheckNoCommitDict["SafeCheck"] = safeCheckSource
                noCommitInfoDataSource.add(safeCheckNoCommitDict)
            }
        }
        
        requestTaskListData()
        requestLoadAppRolesData()
        requestIndicatorsData()
    }
    
    func requestTaskListData() {
        
        LoadView.storeLabelText = "正在加载"
        
        let getTaskInfosAPICmd = GetTaskInfosAPICmd()
        getTaskInfosAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getTaskInfosAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","version":"8.2","panelType":"5"]
        getTaskInfosAPICmd.loadView = LoadView()
        getTaskInfosAPICmd.loadParentView = self.view
        getTaskInfosAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.taskDataSource.removeAllObjects()
                for (_,tempDict) in dict["infos"] {
                    
                    if let getTaskInfoModel:GetTaskInfoModel = JSONDeserializer<GetTaskInfoModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                        self.taskDataSource.add(getTaskInfoModel)
                    }
                    
                }
                
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
            self.stopFresh()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
        
    }
    
    func requestLoadAppRolesData() {
        
        let roles = RoleInfoModel.findAll()
        
        self.roleInfoDataSource = NSMutableArray(capacity: 20)
        
        for model in roles! {
            let roleModel = model as! RoleInfoModel
            let dict = NSMutableDictionary(capacity: 2)
            dict["Name"] = roleModel.Name
            dict["Code"] = roleModel.Code
            self.roleInfoDataSource.add(dict)
        }
        self.initRoleInfos()
        
        self.contentTableView?.reloadData()
        
        let loadAppRolesAPICmd = LoadAppRolesAPICmd()
        loadAppRolesAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        loadAppRolesAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","ostype":2,"version":"8.2"]
        loadAppRolesAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                RoleInfoModel.delete(roles)
                self.panels.removeAllObjects();
                for (_,tempDict) in dict["panels"] {
                    if let panel:PanelsModel = PanelsModel.yy_model(withJSON:tempDict.rawString() ?? {}) {
                        self.panels.add(panel);
                    }
                    
                }
                
                for (_,tempDict) in dict["roleInfo"] {
                    
                    if let roleInfoModel:RoleInfoModel = RoleInfoModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        roleInfoModel.save()
                    }
                }
                
                self.roleInfoDataSource.removeAllObjects()
                self.roleInfoDataSource = NSMutableArray(array: dict["roleInfo"].arrayObject!)
                //                self.roleInfoDataSource.add(["Name":"车辆资料","Code":"CLZL"])
                //                self.roleInfoDataSource.add(["Name":"设备资料","Code":"SBZL"])
                //                self.roleInfoDataSource.add(["Name":"知识库","Code":"ZSK"])
                //                self.roleInfoDataSource.add(["Name":"租控表","Code":"ZKB"])
                //                self.roleInfoDataSource.add(["Name":"突发事件","Code":"TFSJ"])
                //                self.roleInfoDataSource.add(["Name":"客户事件","Code":"KHSJ"])
                //                self.roleInfoDataSource.add(["Name":"客户意向","Code":"YXKH"])
                //                self.roleInfoDataSource.add(["Name":"能耗抄表","Code":"NHCB"])
                //                self.roleInfoDataSource.add(["Name":"经营指标","Code":"JYZB"])
                //                self.roleInfoDataSource.add(["Name":"设备巡检","Code":"SBXJ"])
                //                self.roleInfoDataSource.add(["Name":"安全巡检","Code":"AQXJ"])
                //                self.roleInfoDataSource.add(["Name":"仓库入仓","Code":"CKRC"])
                //                self.roleInfoDataSource.add(["Name":"仓库出仓","Code":"CKCC"])
                //                self.roleInfoDataSource.add(["Name":"上门收费","Code":"SMSF"])
                self.initRoleInfos()
                
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: "获取功能信息失败！")
            }
            self.stopFresh()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
        
    }
    
    func requestIndicatorsData() {
        self.IndicatorsDataSource.removeAllObjects();
        //        for i in 5...6 {
        //
        //        }
        let getIndicatorsAPICmd = GetIndicatorsAPICmd()
        getIndicatorsAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getIndicatorsAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","panelType":5,"version":"8.2"]
        getIndicatorsAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            print(dict)
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                let infosArr = dict["infos"];
                let infosDic = infosArr[0]
                let viewDateArr = infosDic["viewDate"];
                for (_,tempDic) in viewDateArr {
                    if let model:IndicateModel = IndicateModel.yy_model(withJSON: tempDic.rawString() ?? {}) {
                        self.IndicatorsDataSource.add(model);
                    }
                }
                self.contentTableView?.reloadData()
            }
            else {
                LocalToastView.toast(text: "获取功能信息失败！")
            }
            self.stopFresh()
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
    }
    
    func initRoleInfos() {
        
        self.roleImages.removeAllObjects()
        self.roleTitles.removeAllObjects()
        
        //"能耗抄表","突发事件","设备巡检","安全巡检",
        //"NHCB","TFSJ","SBXJ","AQXJ",
        let array = ["维修任务","投诉处理","客户事件","突发事件","业户资料","车辆资料","设备资料","知识库","租控表","客户事件","客户意向","仓库入仓","仓库出仓","经营指标"]
        let images = ["WXRW","TSCL","KHSJ","TFSJ","YHZL","CLZL","SBZL","ZSK","ZKB","KHSJ","YXKH","CKRC","CKCC","JYZB"]
        for (index, name) in images.enumerated() {
            for dict in self.roleInfoDataSource {
                let tempDict = dict as! NSDictionary
                if ((tempDict["Code"] as! String).hasPrefix(name)) {
                    self.roleTitles.add(array[index])
                    self.roleImages.add(name)
                }
            }
        }
        
    }
    
    func lineSet(sender : UITapGestureRecognizer) {
        
        let onlineState = LocalStoreData.getOnLine()
        
        let imageView:UIImageView = sender.view as! UIImageView
        
        let online = OnOrOutLineAPICmd()
        online.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        online.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","OnLine":!onlineState]
        online.transactionWithSuccess({ (response) in
            
            imageView.image = UIImage(named: (onlineState ? "icon_off_line":"icon_on_line"))
            self.onlineLabel.text = onlineState ? "请开始作业" : "已开始作业"
            self.onlineLabel.textColor = onlineState ? UIColor.red: UIColor.white
            
            imageView.isUserInteractionEnabled = true
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                LocalToastView.toast(text: (onlineState ? "停止作业成功":"开始作业成功"))
                LocalStoreData.setUserDefaultsData((onlineState ? "FALSE":"TRUE"), forKey: LocalStoreData.OnLine)
                
                NotificationCenter.default.post(name: kNotificationCenterChangeState as NSNotification.Name, object: nil)
                
                
            }else {
                LocalToastView.toast(text: (onlineState ? "停止作业失败":"开始作业失败"))
                LocalStoreData.setUserDefaultsData("FALSE", forKey: LocalStoreData.OnLine)
            }
            
        }) { (response) in
            imageView.isUserInteractionEnabled = true
            LocalToastView.toast(text: DisNetWork)
            LocalStoreData.setUserDefaultsData("FALSE", forKey: LocalStoreData.OnLine)
        }
        
    }
    
    func clickItem(_ title: String!) {
        
        if LocalStoreData.getOnLine() == false {
            LocalToastView.toast(text: "请先开始作业！")
            return;
        }
        
        
        switch title {
        case "more":
            
            let tempRoles = NSMutableArray(capacity: 20)
            
            for (index,_) in self.roleInfoDataSource.enumerated() {
                if (index >= 7) {
                    tempRoles.add(self.roleInfoDataSource[index])
                }
            }
            
            let moreVC = MoreViewController()
            moreVC.roleInfoDataSource = tempRoles
            
            self.push(viewController: moreVC)
        default:
            self.clickItemExtentsion(title)
            break
        }
    }
    
    
}

