//
//  TaskViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class TaskViewController: BaseTableViewController {

    var taskType: Int = 0
    var taskTag: NSString = "0"
    var taskNumber: NSString = "0"
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    var taskDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createContentUI()
        requestData()
    }
    
    deinit {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func createContentUI () {
        
        var title = "待办任务"
        title = title.appending("(").appending(taskNumber as String).appending(")")
        
        self.setTitleView(titles: [title as NSString])
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49))
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.taskDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var taskTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskTableViewCell == nil {
            
            taskTableViewCell = Bundle.main.loadNibNamed("TaskTableViewCell", owner: nil, options: nil)?.first as! TaskTableViewCell
            //taskTableViewCell?.selectionStyle = .none
        }
        
        let model: GetTaskListModel = self.taskDataSource[indexPath.section] as! GetTaskListModel
        
        let tempTaskTableViewCell: TaskTableViewCell = (taskTableViewCell as! TaskTableViewCell)
        
        if model.Categories?.caseInsensitiveCompare("1") == .orderedSame {
            //1: 维修任务
            tempTaskTableViewCell.titleNameLabel.text = "维修任务"
            tempTaskTableViewCell.digestLabel.text = model.Sender?.appending("发来的\"".appending(TaskSettingAction.getKind(kind: model.Kind!))).appending("\"任务")
            
        }else {
            tempTaskTableViewCell.digestLabel.text = model.Sender?.appending("发来的\"".appending(TaskSettingAction.getComplaintKind(kind: model.Kind!))).appending("\"任务")
            if (model.Kind?.compare("1") == .orderedSame
                || model.Kind?.compare("2") == .orderedSame) {
                tempTaskTableViewCell.titleNameLabel.text = "投诉任务"
                tempTaskTableViewCell.typeIconImageView.image = UIImage(named: "index_tscl")
            }else {
                tempTaskTableViewCell.titleNameLabel.text = "未知任务"
            }
            
        }
        
        tempTaskTableViewCell.timeLable.text = model.SendTime
        tempTaskTableViewCell.describeLabel.text = model.Description

        
        return taskTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model: GetTaskListModel = self.taskDataSource[indexPath.section] as! GetTaskListModel
        fetchTaskDetail(model: model)
        
        /*
        let viewController = TaskDetailViewController()
        viewController.taskType = .distribute
        self.navigationController?.pushViewController(viewController, animated: true)
        */
    }
    
    override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        
        if (segmentView.selectedSegmentIndex == 0) {
            taskType = 0
        }else {
            taskType = 1
        }
        
        self.requestData()
    }
    
    func fetchTaskDetail(model: GetTaskListModel) {
        
        if model.Categories == "1" {
            LoadView.storeLabelText = "正在加载任务信息"
            
            let getBillInfoAPICmd = GetBillInfoAPICmd()
            getBillInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getBillInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":"3","billcodes":model.BillCode ?? ""]
            getBillInfoAPICmd.loadView = LoadView()
            getBillInfoAPICmd.loadParentView = self.view
            getBillInfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    var isExist: Bool = false
                    
                    for (_,tempDict) in dict["Bills"] {
                        
                        isExist = true
                        let getBillInfoModel:GetRepaireListModel = GetRepaireListModel.yy_model(withJSON: tempDict.rawString() ?? {})!
                        
                        self.jump(model: getBillInfoModel, listModel: model)
                        break
                    }
                    
                    if (!isExist) {
                        LocalToastView.toast(text: "此单据已处理!")
                    }
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
        } else {
            
            LoadView.storeLabelText = "正在加载投诉详情信息"
            
            let getComplaintByCodeAPICmd = GetComplaintByCodeAPICmd()
            getComplaintByCodeAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getComplaintByCodeAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Code":model.BillCode ?? ""]
            getComplaintByCodeAPICmd.loadView = LoadView()
            getComplaintByCodeAPICmd.loadParentView = self.view
            getComplaintByCodeAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    let complaintHandleModel: GetComplaintByCodeModel =  JSONDeserializer<GetComplaintByCodeModel>.deserializeFrom(json: JSON(dict["infos"].object).rawString())!
                    
                    let model = ComplaintHandleModel()
                    model.Type = complaintHandleModel.Type
                    model.Code = complaintHandleModel.Code
                    
                    let linkDetailVC = DealComplaintHandleListViewController()
                    linkDetailVC.resultModel = complaintHandleModel
                    linkDetailVC.complaintHandleModel = model
                    self.appDelegate.slider.tabbarNavigationController!.pushViewController(linkDetailVC, animated: true)
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }
        
    }
    
    func jump(model: GetRepaireListModel, listModel: GetTaskListModel) {
        
        if (listModel.Categories?.compare("1") == .orderedSame) {
            
            let taskDetailVC = TaskDetailViewController()
            
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
            
            if (listModel.Kind?.compare("4") == .orderedSame) {
                taskDetailVC.contentType = "5"
            }else if (listModel.Kind?.compare("5") == .orderedSame) {
                taskDetailVC.contentType = "6"
            }else if (listModel.Kind?.compare("3") == .orderedSame) {
                //维修抢单页面
                
                let viewController = RepairTaskDetailViewController()
                viewController.selectIndex = -1
                viewController.contentType = "4"
                viewController.titleContent = "待抢列表"
                
                appDelegate.slider.tabbarNavigationController!.pushViewController(viewController, animated: true)
                
                return
            }else {
                taskDetailVC.contentType = listModel.Kind
            }
            
            taskDetailVC.selectIndex = 0
            taskDetailVC.getRepaireListModel = model
            
            appDelegate.slider.tabbarNavigationController!.pushViewController(taskDetailVC, animated: true)
            
        }else {
            
            if (listModel.Kind?.compare("1") == .orderedSame
                || listModel.Kind?.compare("2") == .orderedSame) {
                
                let complaintHandleModel = ComplaintHandleModel()
                complaintHandleModel.Type = listModel.Kind
                complaintHandleModel.Code = model.BillCode
                
                let linkDetailVC = DealComplaintHandleListViewController()
                linkDetailVC.complaintHandleModel = complaintHandleModel
                appDelegate.slider.tabbarNavigationController!.pushViewController(linkDetailVC, animated: true)
            }
            
        }
    }
    
    override func requestData() {
        
        super.requestData()
        
        if (!LocalStoreData.getOnLine()) {
            self.stopFresh()
            return
        }
        
        //0:待办 1:督办 为空的话查全部数据
        
        LoadView.storeLabelText = "正在加载任务列表"
        
        let homeGetTaskListAPICmd = GetTaskListAPICmd()
        homeGetTaskListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        homeGetTaskListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Type":taskType,"tag":taskTag]
        homeGetTaskListAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.taskDataSource.removeAllObjects()
                for (_,tempDict) in dict["infos"] {
                    
                    if let getTaskInfoModel:GetTaskListModel = JSONDeserializer<GetTaskListModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                        self.taskDataSource.add(getTaskInfoModel)
                    }
                    
                }
                
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: "获取任务信息失败！")
            }
            
            
            self.stopFresh()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
    }
}
