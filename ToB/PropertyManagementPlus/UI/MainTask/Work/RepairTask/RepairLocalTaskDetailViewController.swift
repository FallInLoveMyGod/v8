//
//  RepairLocalTaskDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class RepairLocalTaskDetailViewController: BaseTableViewController,UIAlertViewDelegate,UIActionSheetDelegate {
    
    var qListNames = ["保修地址","保修内容","维修单编号","维修种类","报修人","报修人联系电话"]
    
    var titleContent: NSString? = ""
    var category: String! = ""
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var repairTaskDetailDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var deleteModel: GetRepaireListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: [titleContent!])
        
        let item = UIBarButtonItem(image: UIImage(named: "ryback_topBar_Icon_white"), style: .done, target: self, action: #selector(pop))
        self.navigationItem.leftBarButtonItem = item;
        
        if (category.compare("NoCommit") == .orderedSame) {
            self.localHasHeader = false
            self.localHasFooter = false
        }
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49))
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        requestData()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
        if linkListTableViewCell == nil {
            
            linkListTableViewCell = Bundle.main.loadNibNamed("RepairTaskTableViewCell", owner: nil, options: nil)?.first as! RepairTaskTableViewCell
            linkListTableViewCell?.selectionStyle = .none
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDelete(longPress:)))
            linkListTableViewCell?.contentView.isUserInteractionEnabled = true
            linkListTableViewCell?.contentView.addGestureRecognizer(longPress)
        }
        
        linkListTableViewCell?.contentView.tag = indexPath.section + 1
        
        let model = self.repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
        let tempCell = linkListTableViewCell as! RepairTaskTableViewCell
        
        if model.Range?.compare("") == .orderedSame {
            tempCell.titleNameLabel.text = "公共区域"
        }else {
            tempCell.titleNameLabel.text = model.Range
        }
        
        
        tempCell.addressLabel.text = model.Location
        tempCell.timeLabel.text = model.CreateTime
        tempCell.contentLabel.text = model.Content
        
        if (category.compare("NoCommit") == .orderedSame) {
            if (model.SubCategory?.compare("NoSend") == .orderedSame) {
                tempCell.stateLabel.text = "未分派任务"
            }else if (model.SubCategory?.compare("CreateNew") == .orderedSame) {
                tempCell.stateLabel.text = "创建单据未提交"
            }else if (model.SubCategory?.compare("CreateSuccessNoMaterial") == .orderedSame) {
                tempCell.stateLabel.text = "创建附件未提交"
            }else if (model.SubCategory?.compare("FinishSuccessCase") == .orderedSame) {
                tempCell.stateLabel.text = "完成单据未提交"
            }
            
            //FinishSuccessCase
            
            tempCell.stateLabel.textColor = UIColor.red
        }else {
            
            tempCell.stateLabel.isHidden = false
            
            let stateTemp = model.State ?? ""
            
            switch stateTemp {
            case "0":
                tempCell.stateLabel.text = "未派单"
            case "1":
                tempCell.stateLabel.text = "派单中"
            case "2":
                tempCell.stateLabel.text = "待修中"
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
            
        }
        
        tempCell.statesLabelWidthConstraint.constant = 95
        
        return linkListTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = repairTaskDetailDataSource[indexPath.section] as! GetRepaireListModel
        
        if (category.compare("NoCommit") == .orderedSame) {
            
            if (model.SubCategory?.compare("FinishSuccessCase") == .orderedSame) {
                //"完成单据未提交"
                
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
                
                taskDetailVC.contentType = "2"
                
                taskDetailVC.selectIndex = 0
                
                taskDetailVC.getRepaireListModel = model
                
                self.navigationController?.pushViewController(taskDetailVC, animated: true)
                
            }else {
                //修改维修单
                let taskVC = RepairTaskAddViewController()
                taskVC.isModify = true
                taskVC.createRepareBillModel = model
                self.navigationController?.pushViewController(taskVC, animated: true)
            }

        }
        else {
            //我创建的维修
            
            let taskDetailVC = TaskDetailViewController()
            
            let stateTemp = model.State ?? ""
            
            switch stateTemp {
            case "0":
                break
            case "1":
                break
            case "2":
                model.State = "2"
            case "3":
                model.State = "2"
            case "4":
                
                if (Int(model.IsReturnCall!) == 0) {
                    
                    model.State = "3"
                }else {
                    model.State = "4"
                }
                
            default:
                break
            }
            
            taskDetailVC.selectIndex = Int(1)
            taskDetailVC.getRepaireListModel = model
            
            self.navigationController?.pushViewController(taskDetailVC, animated: true)

        }
    }
    
    override func requestData() {
        
        super.requestData()
        
        //"NoCommit","AlreadySend","AlreadyComplete","AlreadyCallBack","AlreadyCheck","AlreadyBack"
        //我创建的维修、未提交、已派单、已回访、已检验、已退单的列表进入后，要获取每个单据最新的信息
        
        if (self.category.compare("NoCommit") != .orderedSame) {
            //我创建的维修(更新数据)
        
        
            var billCodes = ""
        
            for (index,model) in repairTaskDetailDataSource.enumerated() {
                let taskModel = model as! GetRepaireListModel
                billCodes.append(taskModel.BillCode!)
                
                if (index != repairTaskDetailDataSource.count - 1) {
                    billCodes.append(",")
                }
                
            }
            
            LoadView.storeLabelText = "正在加载我创建的维修信息"
            
            let getBillInfoAPICmd = GetBillInfoAPICmd()
            getBillInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getBillInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":"3","billcodes":billCodes]
            getBillInfoAPICmd.loadView = LoadView()
            getBillInfoAPICmd.loadParentView = self.view
            getBillInfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    for (_,tempDict) in dict["Bills"] {
                        
                        if let getBillInfoModel:GetRepaireListModel = GetRepaireListModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            
                            
                            for (index,model) in self.repairTaskDetailDataSource.enumerated() {
                                let taskModel = model as! GetRepaireListModel
                                if (taskModel.BillCode?.compare(getBillInfoModel.BillCode!) == .orderedSame) {
                                    getBillInfoModel.pk = taskModel.pk
                                    //本地数据同步
                                    getBillInfoModel.Category = taskModel.Category
                                    getBillInfoModel.SubCategory = taskModel.SubCategory
                                    
                                    if (self.category.compare("MyCreate") == .orderedSame) {
                                        
                                        getBillInfoModel.IsEdit = taskModel.IsEdit
                                        getBillInfoModel.IsArrive = taskModel.IsArrive
                                        getBillInfoModel.IsStart = taskModel.IsStart
                                        getBillInfoModel.IsSuspend = taskModel.IsSuspend
                                    }
                                    
                                    self.repairTaskDetailDataSource[index] = getBillInfoModel
                                    
                                    getBillInfoModel.update()
                                }
                            }
                            
                        }
                        
                    }
                    
//                    for (index, model) in self.repairTaskDetailDataSource.enumerated() {
//                        let taskModel = model as! GetRepaireListModel
//                        taskModel.fileJson = BaseTool.toJson(taskModel.files)
//                        self.repairTaskDetailDataSource[index] = taskModel
//                    }
                    
                    self.loadData()
                    
                    self.contentTableView?.reloadData()
                    
                    LocalToastView.toast(text: "刷新成功")
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }else {
            self.stopFresh()
        }

    }
    
    func loadData() {
        
        repairTaskDetailDataSource = NSMutableArray(capacity: 20)
        
        let criteria = " WHERE Category = '" + category + "'"
        repairTaskDetailDataSource.addObjects(from: GetRepaireListModel.find(byCriteria: criteria))
        self.contentTableView?.reloadData()
        
        var title = (self.titleContent as! String) + ",共(" + String(self.repairTaskDetailDataSource.count) + ")条"
        
        if (self.repairTaskDetailDataSource.count == 0) {
            title = (self.titleContent as! String)
        }
        
        self.setTitleView(titles: [title as NSString])
        
    }
    
    @objc func longPressDelete(longPress: UILongPressGestureRecognizer) {
        //长按删除
        
        if (deleteModel != nil) {
            return
        }
        
        deleteModel = self.repairTaskDetailDataSource[(longPress.view?.tag)! - 1] as? GetRepaireListModel
        
        showActionSheet(title: "选择操作", cancelTitle: "取消", titles: ["删除单据","全部删除"], tag: "HandleStyle")
        
//        let action: UIActionSheet = UIActionSheet(title: "选择操作", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "删除单据","全部删除")
//        action.tag = 1115
//        action.show(in: self.view);
        
    }
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        if (tag.compare("HandleStyle") == .orderedSame) {
            
            if (buttonIndex == 0) {
                deleteModel = nil
                return
            }
            
            var title = "删除后不可恢复！"
            var alert = UIAlertView(title: "警告", message: title, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "取消", "删除")
            
            if (buttonIndex == 1) {
                alert.tag = 3331
            }else {
                alert.tag = 3332
                
                title = "确认全部删除！"
                alert = UIAlertView(title: "警告", message: title, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "取消", "删除")
            }
            alert.show()
            
        }
    }
    
    // MARK:  UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            deleteModel = nil
            return
        }
        
        if (actionSheet.tag == 1115) {
            
            var title = "删除后不可恢复！"
            var alert = UIAlertView(title: "警告", message: title, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "取消", "删除")
            
            if (buttonIndex == 1) {
                alert.tag = 3331
            }else {
                alert.tag = 3332
                
                title = "确认全部删除！"
                alert = UIAlertView(title: "警告", message: title, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "取消", "删除")
            }
            alert.show()
        }
        
    }
    
    //UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView.tag == 3331) {
            
            if (buttonIndex == 1) {
                deleteModel?.deleteObject()
            }
            
        }else {
            
            if (buttonIndex == 1) {
                
                for model in repairTaskDetailDataSource {
                    let tempModel = model as! GetRepaireListModel
                    tempModel.deleteObject()
                }
            }
        }
        
        deleteModel = nil
        
        loadData()
    }
    
}
