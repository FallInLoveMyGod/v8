//
//  RepairTaskDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

/*
import UIKit
import SwiftyJSON
import HandyJSON

class RepairTaskDetailViewController: BaseTableViewController,FJFloatingViewDelegate {

    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    var qListNames = ["保修地址","保修内容","维修单编号","维修种类","报修人","报修人联系电话"]
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var titleContent: NSString? = ""
    var state: String! = "All"
    var contentType: String! = ""
    var category: String! = ""
    var selectIndex: NSInteger = 0
    
    var qSelectIndex: NSInteger = -1
    var timer: Timer  = Timer()
    var foreListNumber = -1
    
    var repairTaskDetailDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var robListSuccess = false
    
    var notificationBillPK = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: kNotificationCenterFreshRepairTaskDetailList as NSNotification.Name, object: nil)

        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: [titleContent!])
        
        let item = UIBarButtonItem(image: UIImage(named: "ryback_topBar_Icon_white"), style: .done, target: self, action: #selector(pop))
        self.navigationItem.leftBarButtonItem = item;
        
        if (selectIndex == 0 && (titleContent?.contains("未提交"))!) {
            self.localHasHeader = false
            self.localHasFooter = false
        }
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49))
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        if (selectIndex == -1) {
            
            //抢单页面定时刷新
            
            self.startTimer()
            
            floatingView.iconImageView.image = UIImage(named: "icon_qiangdan_normal.png")
            floatingView.delegate = self
            floatingView.isHidden = true
            self.view.addSubview(floatingView)
            
        }
        
        self.requestData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterFreshRepairTaskDetailList as NSNotification.Name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        floatingView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return repairTaskDetailDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectIndex == -1) {
            if (floatingView.isHidden == false && qSelectIndex == section) {
                return 7
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selectIndex == -1) {
            if (floatingView.isHidden == false && qSelectIndex == indexPath.section) {
                return 44.0
            }
        }
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var linkListTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (selectIndex == -1) {
            
            if (floatingView.isHidden == false && qSelectIndex == indexPath.section) {
                
                let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
                
                if (0 == indexPath.row) {
                    
                    if linkListTableViewCell == nil {
                        
                        linkListTableViewCell = Bundle.main.loadNibNamed("QiangDanTaskTopTableViewCell", owner: nil, options: nil)?.first as! QiangDanTaskTopTableViewCell
                        linkListTableViewCell?.selectionStyle = .none
                    }
                    
                    let tempCell = linkListTableViewCell as! QiangDanTaskTopTableViewCell
                    
                    if model.Range?.compare("") == .orderedSame {
                        tempCell.nameLabel.text = "公共区域"
                    }else {
                        tempCell.nameLabel.text = model.Range
                    }
                    
                    tempCell.contentLabel.text = model.CreateTime
                    
                    return linkListTableViewCell!
                    
                }
                
                if linkListTableViewCell == nil {
                    
                    linkListTableViewCell = Bundle.main.loadNibNamed("QiangDanTaskTableViewCell", owner: nil, options: nil)?.first as! QiangDanTaskTableViewCell
                    linkListTableViewCell?.selectionStyle = .none
                }
                
                let tempCell = linkListTableViewCell as! QiangDanTaskTableViewCell
                
                tempCell.nameLabel.text = qListNames[indexPath.row - 1]
                
                var content = ""
                
                switch indexPath.row {
                case 1:
                    content = model.Location!
                case 2:
                    content = model.Content!
                case 3:
                    content = model.BillCode!
                case 4:
                    content = model.Type!
                case 5:
                    content = model.Proposer!
                case 6:
                    content = model.TelNum!
                default:
                    break
                }
                
                tempCell.contentLabel.text = content
                
                return linkListTableViewCell!
                
            }
        }
        
        if linkListTableViewCell == nil {
            
            linkListTableViewCell = Bundle.main.loadNibNamed("RepairTaskTableViewCell", owner: nil, options: nil)?.first as! RepairTaskTableViewCell
            linkListTableViewCell?.selectionStyle = .none
        }
        
        let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
        let tempCell = linkListTableViewCell as! RepairTaskTableViewCell
        
        /*
         
         open var Range: String? = ""
         open var Location: String? = ""
         open var Content: String? = ""
         open var CreateTime: String? = ""
         open var State: String? = ""
         
         */
        
        if model.Range?.compare("") == .orderedSame {
            tempCell.titleNameLabel.text = "公共区域"
        }else {
            tempCell.titleNameLabel.text = model.Range
        }
        
        
        tempCell.addressLabel.text = model.Location
        
        let createTime = model.CreateTime?.components(separatedBy: "T").joined(separator: " ")
        
        tempCell.timeLabel.text = createTime
        tempCell.contentLabel.text = model.Content
        
        let stateTemp = model.State ?? ""
        
        switch stateTemp {
        case "0":
            tempCell.stateLabel.text = "未派单"
        case "1":
            tempCell.stateLabel.text = "派单中"
        case "2":
            tempCell.stateLabel.text = "未派单"
        case "3":
            tempCell.stateLabel.text = "进行中"
        case "4":
            
            if (Int(model.IsReturnCall!) == 0) {
                
                if (model.Range?.compare("客户区域") == .orderedSame) {
                    tempCell.stateLabel.text = "已完成待回访"
                }else {
                    tempCell.stateLabel.text = "已完成待检验"
                }
                
            }else {
                if (model.Range?.compare("客户区域") == .orderedSame) {
                    tempCell.stateLabel.text = "已回访"
                }else {
                    tempCell.stateLabel.text = "已检验"
                }

            }
        default:
            break
        }
        
        if (stateTemp.compare("3") == .orderedSame) {
            if (model.Category?.compare("NoComplete") == .orderedSame
                && model.IsOver?.compare("1") == .orderedSame) {
                //完成单据未提交
                tempCell.stateLabel.text = "完成单据未提交"
            }
        }
        
        if (selectIndex == -1) {
            tempCell.statesLabelWidthConstraint.constant = 140
            let createTime = model.CreateTime?.components(separatedBy: "T").joined(separator: " ")
            tempCell.stateLabel.text = createTime
        }else {
            tempCell.stateLabel.textColor = BaseTool.setColorWithContent(tempCell.stateLabel.text!)
            tempCell.statesLabelWidthConstraint.constant = 95
        }
        
        return linkListTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectIndex == -1 {
            
            floatingView.isHidden = false
            
            qSelectIndex = indexPath.section
            
            contentTableView?.reloadData()
            
        }else {
            
            let taskDetailVC = TaskDetailViewController()
            
            let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
            
            let stateTemp = model.State ?? ""
            
            switch stateTemp {
            case "0":
                break
            case "1":
                break
            case "2":
                break
            case "3":
                break
            case "4":
                
                if (Int(model.IsReturnCall!) == 0) {
                    model.State = "3"
                }else {
                    model.State = "4"
                }
                
            default:
                break
            }
            
            if (selectIndex == 0) {
                taskDetailVC.contentType = contentType
            }
            
            taskDetailVC.selectIndex = selectIndex
            
            taskDetailVC.getRepaireListModel = model
            
            self.navigationController?.pushViewController(taskDetailVC, animated: true)
            
        }
        
    }
    
    override func requestData() {
        super.requestData()
        
        if (selectIndex == 0 || selectIndex == -1) {
            
            if (selectIndex == 0) {
                self.repairTaskDetailDataSource.removeAllObjects()
            }else if (selectIndex == -1 && self.pageIndex == 1) {
                self.repairTaskDetailDataSource.removeAllObjects()
            }
            
            if (self.selectIndex == 0) {
                //["NoSend","NoComplete","NoReCall","NoCheck"]
                
                self.repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: " WHERE Category = '" + self.category + "' ORDER BY CreateTime"))
                
            }
            
            LoadView.storeLabelText = "正在加载任务列表信息"
            
            let getBillInfoAPICmd = GetBillInfoAPICmd()
            getBillInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getBillInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":contentType]
            if (selectIndex == 0) {
                getBillInfoAPICmd.loadView = LoadView()
                getBillInfoAPICmd.loadParentView = self.view
            }
            getBillInfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功

                    if (self.selectIndex == 0) {
                        //["NoSend","NoComplete","NoReCall","NoCheck"]
                        
                        //1 未派单中的数据一律更新
                        if (self.category.compare("NoSend") == .orderedSame
                            || self.category.compare("NoCheck") == .orderedSame
                            || self.category.compare("NoReCall") == .orderedSame) {
                            self.repairTaskDetailDataSource.removeAllObjects()
                            GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = '" + self.category + "'")
                        }
                        
                    }
                    
                    var datas: Array<GetRepaireListModel> = Array()

                    for (_,tempDict) in dict["Bills"] {
                        
                        if let getBillInfoModel:GetRepaireListModel = GetRepaireListModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            
                            if (self.selectIndex == -1) {
                                self.repairTaskDetailDataSource.add(getBillInfoModel)
                            }else {
                                
                                datas.append(getBillInfoModel)
                                //self.repairTaskDetailDataSource.add(getBillInfoModel)
                                getBillInfoModel.Category = self.category
                            }
                            
                        }
                        
                    }
                    
                    if (self.selectIndex == 0) {
                        if (self.category.compare("NoSend") == .orderedSame
                            || self.category.compare("NoCheck") == .orderedSame
                            || self.category.compare("NoReCall") == .orderedSame) {
                            GetRepaireListModel.save(datas)
                            self.repairTaskDetailDataSource.addObjects(from: datas)
                        }else if (self.category.compare("NoComplete") == .orderedSame) {
                            // 未完成 （1.在编辑：更新  2.不在编辑：本地删除添加）
                            
                            //var existArray = Array<GetRepaireListModel>()
                            
                            var billCodes = "not in ("
                            
                            for (index, getBillInfoModel) in datas.enumerated() {
                                
                                billCodes.append("'")
                                billCodes.append(getBillInfoModel.BillCode!)
                                
                                if (index != (dict["Bills"].array?.count)! - 1) {
                                    billCodes.append("',")
                                }else {
                                    billCodes.append("')")
                                }
                                
                            }
                            
                            //删除本地没有的单据，并更新数据
                            GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = 'NoComplete' and BillCode " + billCodes)
                            
                            self.repairTaskDetailDataSource.removeAllObjects()
                            self.repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: " WHERE Category = '" + self.category + "' ORDER BY CreateTime DESC"))
                            
//                            //删除本地未编辑
//                            GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = 'NoComplete' and IsEdit = '0'")
                            
                            
//                            var notExistDatas: Array<GetRepaireListModel> = Array()
                            var index = 0
                            
                            for getBillInfoModel in datas {
                                
                                var isExist: Bool = false
                                
                                for subModel in self.repairTaskDetailDataSource {
                                    
                                    let subTempModel = subModel as! GetRepaireListModel
                                    if (getBillInfoModel.BillCode?.compare(subTempModel.BillCode!) == .orderedSame) {
                                        //同步本地数据
                                        subTempModel.files = getBillInfoModel.files
                                        getBillInfoModel.pk = subTempModel.pk
                                        getBillInfoModel.IsEdit = subTempModel.IsEdit
                                        isExist = true
                                        
//                                        getBillInfoModel.pk = subTempModel.pk
                                        
                                        
                                        break;
                                    }
                                }
                                
//                                if (!isExist) {
//                                    notExistDatas.append(getBillInfoModel)
//                                }
                                
                                if (!isExist) {
                                    getBillInfoModel.save()
                                    self.repairTaskDetailDataSource.add(getBillInfoModel)
                                }else {
                                    if (getBillInfoModel.IsEdit?.compare("0") == .orderedSame) {
                                        getBillInfoModel.update()
                                    }
                                }
                                
                                index = index + 1
                            }
                            
//                            for getBillInfoModel in notExistDatas {
//                                getBillInfoModel.save()
//                            }
//                            
//                            self.repairTaskDetailDataSource.removeAllObjects()
//                            self.repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: " WHERE Category = '" + self.category + "' ORDER BY CreateTime DESC"))
                            
                            
                            /*
                            if (existArray.count != 0) {
                                //存在需要更新的数据
                                GetRepaireListModel.update(existArray)
                            }*/
                        }
                        
                    }
                    
                    if (self.selectIndex != -1) {
                        var title = (self.titleContent as! String) + ",共(" + String(self.repairTaskDetailDataSource.count) + ")条"
                        
                        if (self.repairTaskDetailDataSource.count == 0) {
                            title = (self.titleContent as! String)
                        }
                        
                        self.setTitleView(titles: [title as NSString])
                        
                        self.repairTaskDetailDataSource = NSMutableArray(array: BaseTool.sortData(self.repairTaskDetailDataSource))
                    }
                    
                    if self.selectIndex == -1 && self.repairTaskDetailDataSource.count == 0 {
                        LocalToastView.toast(text: "无单据可抢！")
                        self.timer.invalidate()
                        self.pop()
                    }else if (self.selectIndex == -1) {
                        
                        if (self.foreListNumber == -1) {
                            self.foreListNumber = self.repairTaskDetailDataSource.count
                        }
                        if (self.foreListNumber > self.repairTaskDetailDataSource.count) {
                            self.floatingView.isHidden = true
                            self.foreListNumber = self.repairTaskDetailDataSource.count
                            if (!self.robListSuccess) {
                                LocalToastView.toast(text: "此单据已被抢！")
                            }else {
                                self.robListSuccess = true
                            }
                        }
                        
                    }
                    
                    var index = 0
                    for model in self.repairTaskDetailDataSource {
                        let getRepaireListModel = model as! GetRepaireListModel
                        if getRepaireListModel.BillCode == self.notificationBillPK {
                            
                            self.tableView(self.contentTableView!, didSelectRowAt: IndexPath(row: 0, section: index))
                            self.notificationBillPK = ""
                            break
                        }
                        index += 1
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
            
        }else {
            
            LoadView.storeLabelText = "正在加载维修信息"
            
            let getRepaireListAPICmd = GetRepaireListAPICmd()
            getRepaireListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getRepaireListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","PageIndex":self.pageIndex,"PageSize":self.pageSize,"state":state]
            getRepaireListAPICmd.loadView = LoadView()
            getRepaireListAPICmd.loadParentView = self.view
            getRepaireListAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    if (self.pageIndex == 1) {
                        self.repairTaskDetailDataSource.removeAllObjects()
                    }
                    
                    for (_,tempDict) in dict["Bills"] {
                        
                        
                        if let getRepaireListModel:GetRepaireListModel = GetRepaireListModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.repairTaskDetailDataSource.add(getRepaireListModel)
                        }
                        
                    }
                    
                    
                    if (self.selectIndex != -1) {
                        var title = (self.titleContent as! String) + ",共(" + String(self.repairTaskDetailDataSource.count) + ")条"
                        
                        if (self.repairTaskDetailDataSource.count == 0) {
                            title = (self.titleContent as! String)
                        }
                        
                        self.setTitleView(titles: [title as NSString])
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
    }
    
    func floatingViewClick() {
        //抢单
        
        robListSuccess = true
        
        timer.invalidate()
        
        let model = self.repairTaskDetailDataSource[qSelectIndex] as! GetRepaireListModel
        
        LoadView.storeLabelText = "抢单中......"
        
        let acceptRepareTaskAPICmd = AcceptRepareTaskAPICmd()
        acceptRepareTaskAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        acceptRepareTaskAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","billCode":model.BillCode ?? "","taskType":2,"billInfo":""]
        acceptRepareTaskAPICmd.loadView = LoadView()
        acceptRepareTaskAPICmd.loadParentView = self.view
        acceptRepareTaskAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                self.floatingView.isHidden = true
                
                self.foreListNumber = self.repairTaskDetailDataSource.count;
                
                self.requestData()
                
                LocalToastView.toast(text: "抢单成功！")
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
            self.stopFresh()
            
            self.startTimer()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
            self.startTimer()
        }
    }
    
    @objc func refreshData() {
        
        self.pageIndex = 1
        requestData()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
    }

}
 */

import UIKit
import SwiftyJSON
import HandyJSON

class RepairTaskDetailViewController: BaseTableViewController,FJFloatingViewDelegate {
    
    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    var qListNames = ["保修地址","保修内容","维修单编号","维修种类","报修人","报修人联系电话"]
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var titleContent: NSString? = ""
    var state: String! = "All"
    var contentType: String! = ""
    var category: String! = ""
    var selectIndex: NSInteger = 0
    
    var qSelectIndex: NSInteger = -1
    var timer: Timer  = Timer()
    var foreListNumber = -1
    
    var repairTaskDetailDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var robListSuccess = false
    
    var notificationBillPK = ""
    
    var chooseTitle:NSString?  // 楼盘筛选
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: kNotificationCenterFreshRepairTaskDetailList as NSNotification.Name, object: nil)
        
        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: [titleContent!])
        
        let item = UIBarButtonItem(image: UIImage(named: "ryback_topBar_Icon_white"), style: .done, target: self, action: #selector(pop))
        self.navigationItem.leftBarButtonItem = item;
        
        if (selectIndex == 0 && (titleContent?.contains("未提交"))!) {
            self.localHasHeader = false
            self.localHasFooter = false
        }
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49 - 64))
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        if (selectIndex == -1) {
            
            //抢单页面定时刷新
            
            self.startTimer()
            
            floatingView.iconImageView.image = UIImage(named: "icon_qiangdan_normal.png")
            floatingView.delegate = self
            floatingView.isHidden = true
            self.view.addSubview(floatingView)
            
        }
        
//        self.requestData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterFreshRepairTaskDetailList as NSNotification.Name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        floatingView.isHidden = true
        self.refreshData();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.repairTaskDetailDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectIndex == -1) {
            if (floatingView.isHidden == false && qSelectIndex == section) {
                return 7
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selectIndex == -1) {
            if (floatingView.isHidden == false && qSelectIndex == indexPath.section) {
                return 44.0
            }
        }
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var linkListTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (selectIndex == -1) {
            
            if (floatingView.isHidden == false && qSelectIndex == indexPath.section) {
                
                let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
                
                if (0 == indexPath.row) {
                    
                    if linkListTableViewCell == nil {
                        
                        linkListTableViewCell = Bundle.main.loadNibNamed("QiangDanTaskTopTableViewCell", owner: nil, options: nil)?.first as! QiangDanTaskTopTableViewCell
                        linkListTableViewCell?.selectionStyle = .none
                    }
                    
                    let tempCell = linkListTableViewCell as! QiangDanTaskTopTableViewCell
                    
                    if model.Range?.compare("") == .orderedSame {
                        tempCell.nameLabel.text = "公共区域"
                    }else {
                        tempCell.nameLabel.text = model.Range
                    }
                    
                    tempCell.contentLabel.text = model.CreateTime
                    
                    return linkListTableViewCell!
                    
                }
                
                if linkListTableViewCell == nil {
                    
                    linkListTableViewCell = Bundle.main.loadNibNamed("QiangDanTaskTableViewCell", owner: nil, options: nil)?.first as! QiangDanTaskTableViewCell
                    linkListTableViewCell?.selectionStyle = .none
                }
                
                let tempCell = linkListTableViewCell as! QiangDanTaskTableViewCell
                
                tempCell.nameLabel.text = qListNames[indexPath.row - 1]
                
                var content = ""
                
                switch indexPath.row {
                case 1:
                    content = model.Location!
                case 2:
                    content = model.Content!
                case 3:
                    content = model.BillCode!
                case 4:
                    content = model.Type!
                case 5:
                    content = model.Proposer!
                case 6:
                    content = model.TelNum!
                default:
                    break
                }
                
                tempCell.contentLabel.text = content
                
                return linkListTableViewCell!
                
            }
        }
        
        if linkListTableViewCell == nil {
            
            linkListTableViewCell = Bundle.main.loadNibNamed("RepairTaskTableViewCell", owner: nil, options: nil)?.first as! RepairTaskTableViewCell
            linkListTableViewCell?.selectionStyle = .none
        }
        
        let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
        let tempCell = linkListTableViewCell as! RepairTaskTableViewCell
        
        /*
         
         open var Range: String? = ""
         open var Location: String? = ""
         open var Content: String? = ""
         open var CreateTime: String? = ""
         open var State: String? = ""
         
         */
        
        if model.Range?.compare("") == .orderedSame {
            tempCell.titleNameLabel.text = "公共区域"
        }else {
            tempCell.titleNameLabel.text = model.Range
        }
        
        
        tempCell.addressLabel.text = model.Location
        
        //        let createTime = model.CreateTime?.components(separatedBy: "T").joined(separator: " ")
        let createTime = model.BillDate;
        tempCell.timeLabel.text = createTime
        tempCell.contentLabel.text = model.Content
        tempCell.stateLabel.text = model.Type;
        let stateTemp = model.State ?? ""
        //
        //        switch stateTemp {
        //        case "0":
        //            tempCell.stateLabel.text = "未派单"
        //        case "1":
        //            tempCell.stateLabel.text = "派单中"
        //        case "2":
        //            tempCell.stateLabel.text = "待修中"
        //        case "3":
        //            tempCell.stateLabel.text = "进行中"
        //        case "4":
        //
        //            if (Int(model.IsReturnCall!) == 0 ) {
        //
        //                if (model.Range?.compare("客户区域") == .orderedSame) {
        //                    tempCell.stateLabel.text = "已完成待回访"
        //                }else {
        //                    tempCell.stateLabel.text = "已完成待检验"
        //                }
        //
        //            }else {
        //                if (model.Range?.compare("客户区域") == .orderedSame) {
        //                    tempCell.stateLabel.text = "已回访"
        //                }else {
        //                    tempCell.stateLabel.text = "已检验"
        //                }
        //
        //            }
        //        default:
        //            break
        //        }
        
        if (stateTemp.compare("3") == .orderedSame) {
            if (model.Category?.compare("NoComplete") == .orderedSame
                && model.IsOver?.compare("1") == .orderedSame) {
                //完成单据未提交
                tempCell.stateLabel.text = "完成单据未提交"
            }
        }
        
        if (selectIndex == -1) {
            tempCell.statesLabelWidthConstraint.constant = 140
            let createTime = model.CreateTime?.components(separatedBy: "T").joined(separator: " ")
            tempCell.stateLabel.text = createTime
        }else {
            tempCell.stateLabel.textColor = BaseTool.setColorWithContent(tempCell.stateLabel.text!)
            tempCell.statesLabelWidthConstraint.constant = 95
        }
        
        return linkListTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectIndex == -1 {
            
            floatingView.isHidden = false
            
            qSelectIndex = indexPath.section
            
            contentTableView?.reloadData()
            
        }else {
            
            let taskDetailVC = TaskDetailViewController()
            
            let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
            
            let stateTemp = model.State ?? ""
            
            switch stateTemp {
            case "0":
                break
            case "1":
                break
            case "2":
                break
            case "3":
                break;
            case "4":
                
                //                if (Int(model.IsReturnCall!) == 0) {
                //                    model.State = "3"
                //                }else {
                //                    model.State = "4"
                //                }
                break;
                
            default:
                break
            }
            
            if (selectIndex == 0) {
                taskDetailVC.contentType = contentType
            }
            
            taskDetailVC.selectIndex = selectIndex
            
            taskDetailVC.getModel = model
            
            self.navigationController?.pushViewController(taskDetailVC, animated: true)
            
        }
        
    }
    
    override func requestData() {
        super.requestData()
        if (selectIndex == 0 || selectIndex == -1) {
            
            
            
            if (self.selectIndex == 0) {
                //["NoSend","NoComplete","NoReCall","NoCheck"]
                
                //                self.repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: " WHERE Category = '" + self.category + "' ORDER BY CreateTime"))
                
            }
            
            LoadView.storeLabelText = "正在加载任务列表信息"
            
            let getBillInfoAPICmd = GetBillInfoAPICmd()
            getBillInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getBillInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":contentType,"onlymy":"1","PageSize":"30","PageIndex":self.pageIndex]
            if (selectIndex == 0) {
                getBillInfoAPICmd.loadView = LoadView()
                getBillInfoAPICmd.loadParentView = self.view
            }
            getBillInfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    if (self.pageIndex == 1) {
                        if (self.selectIndex == 0) {
                            self.repairTaskDetailDataSource.removeAllObjects()
                        }else if (self.selectIndex == -1 && self.pageIndex == 1) {
                            self.repairTaskDetailDataSource.removeAllObjects()
                        }
                    }
                    
                    //成功
                    
                    //                    if (self.selectIndex == 0) {
                    //                        //["NoSend","NoComplete","NoReCall","NoCheck"]
                    //
                    //                        //1 未派单中的数据一律更新
                    //                        if (self.category.compare("NoSend") == .orderedSame
                    //                            || self.category.compare("NoCheck") == .orderedSame
                    //                            || self.category.compare("NoReCall") == .orderedSame) {
                    //                            self.repairTaskDetailDataSource.removeAllObjects()
                    ////                            GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = '" + self.category + "'")
                    //                        }
                    //
                    //                    }
                    
                    var datas: Array<GetRepaireListModel> = Array()
                    
                    for (_,tempDict) in dict["Bills"] {
                        
                        if let getBillInfoModel:GetRepaireListModel = GetRepaireListModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            
                            if (self.selectIndex == -1) {
                                self.repairTaskDetailDataSource.add(getBillInfoModel)
                            }else {
                                
                                datas.append(getBillInfoModel)
                                self.repairTaskDetailDataSource.add(getBillInfoModel)
                                getBillInfoModel.Category = self.category
                            }
                            
                        }
                        
                    }
                    
                    if (self.selectIndex == 0) {
                        if (self.category.compare("NoSend") == .orderedSame
                            || self.category.compare("NoCheck") == .orderedSame
                            || self.category.compare("NoReCall") == .orderedSame) {
                            //                            GetRepaireListModel.save(datas)
                            //                            self.repairTaskDetailDataSource.addObjects(from: datas)
                        }else if (self.category.compare("NoComplete") == .orderedSame) {
                            // 未完成 （1.在编辑：更新  2.不在编辑：本地删除添加）
                            
                            //var existArray = Array<GetRepaireListModel>()
                            
                            var billCodes = "not in ("
                            
                            for (index, getBillInfoModel) in datas.enumerated() {
                                
                                billCodes.append("'")
                                billCodes.append(getBillInfoModel.BillCode!)
                                
                                if (index != (dict["Bills"].array?.count)! - 1) {
                                    billCodes.append("',")
                                }else {
                                    billCodes.append("')")
                                }
                            }
                            
                            //删除本地没有的单据，并更新数据
                            //                            GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = 'NoComplete' and BillCode " + billCodes)
                            
                            self.repairTaskDetailDataSource.removeAllObjects()
                            //                            self.repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: " WHERE Category = '" + self.category + "' ORDER BY CreateTime DESC"))
                            
                            //                            //删除本地未编辑
                            //                            GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = 'NoComplete' and IsEdit = '0'")
                            
                            
                            //                            var notExistDatas: Array<GetRepaireListModel> = Array()
                            var index = 0
                            
                            for getBillInfoModel in datas {
                                
                                //                                var isExist: Bool = false
                                
                                for subModel in self.repairTaskDetailDataSource {
                                    
                                    let subTempModel = subModel as! GetRepaireListModel
                                    if (getBillInfoModel.BillCode?.compare(subTempModel.BillCode!) == .orderedSame) {
                                        //同步本地数据
                                        //                                        subTempModel.files = getBillInfoModel.files
                                        //                                        getBillInfoModel.pk = subTempModel.pk
                                        //                                        getBillInfoModel.IsEdit = subTempModel.IsEdit
                                        //                                        isExist = true
                                        
                                        //                                        getBillInfoModel.pk = subTempModel.pk
                                        
                                        
                                        break;
                                    }
                                }
                                
                                //                                if (!isExist) {
                                //                                    notExistDatas.append(getBillInfoModel)
                                //                                }
                                
                                //                                if (isExist) {
                                ////                                    getBillInfoModel.save()
                                //                                    self.repairTaskDetailDataSource.add(getBillInfoModel)
                                //                                }else {
                                //                                    if (getBillInfoModel.IsEdit?.compare("0") == .orderedSame) {
                                ////                                        getBillInfoModel.update()
                                //                                    }
                                //                                }
                                self.repairTaskDetailDataSource.add(getBillInfoModel)
                                index = index + 1
                            }
                            
                            //                            for getBillInfoModel in notExistDatas {
                            //                                getBillInfoModel.save()
                            //                            }
                            //
                            //                            self.repairTaskDetailDataSource.removeAllObjects()
                            //                            self.repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: " WHERE Category = '" + self.category + "' ORDER BY CreateTime DESC"))
                            
                            
                            /*
                             if (existArray.count != 0) {
                             //存在需要更新的数据
                             GetRepaireListModel.update(existArray)
                             }*/
                        }
                        
                    }
                    
                    if (self.selectIndex != -1) {
//                        var title = (self.titleContent as! String) + ",共(" + String(self.repairTaskDetailDataSource.count) + ")条"
                        
                        var title = (self.titleContent as! String) + ",共(" + String(describing: dict["BillNum"]) + ")条"
                        
                        if (self.repairTaskDetailDataSource.count == 0) {
                            title = (self.titleContent as! String)
                        }
                        
                        self.setTitleView(titles: [title as NSString])
                        
                        self.repairTaskDetailDataSource = NSMutableArray(array: BaseTool.sortData(self.repairTaskDetailDataSource))
                    }
                    
                    if self.selectIndex == -1 && self.repairTaskDetailDataSource.count == 0 {
                        LocalToastView.toast(text: "无单据可抢！")
                        self.timer.invalidate()
                        self.pop()
                    }else if (self.selectIndex == -1) {
                        
                        if (self.foreListNumber == -1) {
                            self.foreListNumber = self.repairTaskDetailDataSource.count
                        }
                        if (self.foreListNumber > self.repairTaskDetailDataSource.count) {
                            self.floatingView.isHidden = true
                            self.foreListNumber = self.repairTaskDetailDataSource.count
                            if (!self.robListSuccess) {
                                LocalToastView.toast(text: "此单据已被抢！")
                            }else {
                                self.robListSuccess = true
                            }
                        }
                        
                    }
                    
                    var index = 0
                    for model in self.repairTaskDetailDataSource {
                        let getRepaireListModel = model as! GetRepaireListModel
                        if getRepaireListModel.BillCode == self.notificationBillPK {
                            
                            self.tableView(self.contentTableView!, didSelectRowAt: IndexPath(row: 0, section: index))
                            self.notificationBillPK = ""
                            break
                        }
                        index += 1
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
            
        }else {
            
            LoadView.storeLabelText = "正在加载维修信息"
            
            let getRepaireListAPICmd = GetRepaireListAPICmd()
            getRepaireListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getRepaireListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","PageIndex":self.pageIndex,"PageSize":self.pageSize,"state":state,"PProjectCode":self.chooseTitle ?? ""]
            getRepaireListAPICmd.loadView = LoadView()
            getRepaireListAPICmd.loadParentView = self.view
            getRepaireListAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    if (self.pageIndex == 1) {
                        self.repairTaskDetailDataSource.removeAllObjects()
                    }
                    
                    for (_,tempDict) in dict["Bills"] {
                        
                        
                        if let getRepaireListModel:GetRepaireListModel = GetRepaireListModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.repairTaskDetailDataSource.add(getRepaireListModel)
                        }
                        
                    }
                    
                    
                    if (self.selectIndex != -1) {
                        var title = (self.titleContent as! String) + ",共(" + String(self.repairTaskDetailDataSource.count) + ")条"
                        
                        if (self.repairTaskDetailDataSource.count == 0) {
                            title = (self.titleContent as! String)
                        }
                        
                        self.setTitleView(titles: [title as NSString])
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
    }
    
    func floatingViewClick() {
        //抢单
        
        robListSuccess = true
        
        timer.invalidate()
        
        let model = self.repairTaskDetailDataSource[qSelectIndex] as! GetRepaireListModel
        
        LoadView.storeLabelText = "抢单中......"
        
        let acceptRepareTaskAPICmd = AcceptRepareTaskAPICmd()
        acceptRepareTaskAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        acceptRepareTaskAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","billCode":model.BillCode ?? "","taskType":2,"billInfo":""]
        acceptRepareTaskAPICmd.loadView = LoadView()
        acceptRepareTaskAPICmd.loadParentView = self.view
        acceptRepareTaskAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                self.floatingView.isHidden = true
                
                self.foreListNumber = self.repairTaskDetailDataSource.count;
                
                self.requestData()
                
                LocalToastView.toast(text: "抢单成功！")
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
            self.stopFresh()
            
            self.startTimer()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
            self.startTimer()
        }
    }
    
    @objc func refreshData() {
        
        self.pageIndex = 1
        requestData()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
    }
    
}

