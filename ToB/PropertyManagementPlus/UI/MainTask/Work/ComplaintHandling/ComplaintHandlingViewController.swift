//
//  ComplaintHandlingViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class ComplaintHandlingViewController: BaseTableViewController,FJFloatingViewDelegate {

    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    var notificationBillCode = ""
    
    var complaintHandleDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var addCompaintArray: NSMutableArray = NSMutableArray(capacity: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestData), name: kNotificationCenterFreshComplaintList as NSNotification.Name, object: nil)
        
        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: ["投诉处理"])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49), hasHeader: true, hasFooter: false)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        floatingView.delegate = self
        self.view.addSubview(floatingView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterFreshComplaintList as NSNotification.Name, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return complaintHandleDataSource.count
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
            
            linkListTableViewCell = Bundle.main.loadNibNamed("ComplaintHandlingTableViewCell", owner: nil, options: nil)?.first as! ComplaintHandlingTableViewCell
            linkListTableViewCell?.selectionStyle = .none
        }
        
        let model = self.complaintHandleDataSource[indexPath.section] as! ComplaintHandleModel
        let tempCell = linkListTableViewCell as! ComplaintHandlingTableViewCell
        
//        tempCell.titleContentLabel.text = model.Title
        tempCell.titleContentLabel.text = model.Title! + "(" + model.Code! + ")"
        tempCell.complaintPerson.text = model.ComplainantDate;
        tempCell.complaintStyle.text = model.ComplainantPsAddress;
        tempCell.complaintContent.text = model.Content
        
        /*
        //1-待处理 2-待回访
        if (model.Type?.compare("1") == .orderedSame) {
            tempCell.statesLabel.text = "未处理"
        }else {
            if (model.Type?.compare("-1") == .orderedSame) {
                tempCell.statesLabel.text = "未分派任务"
            }else {
                tempCell.statesLabel.text = "未回访"
            }
            
        }
 */
        if (model.Type?.compare("0") == .orderedSame) {
            tempCell.statesLabel.text = "待派单"
        }
        else if (model.Type?.compare("1") == .orderedSame) {
            tempCell.statesLabel.text = "未处理"
        }
        else if (model.Type?.compare("2") == .orderedSame) {
            tempCell.statesLabel.text = "待回访派单"
        }
        else if (model.Type?.compare("3") == .orderedSame) {
            tempCell.statesLabel.text = "未回访"
        }
        
        tempCell.statesLabel.textColor = UIColor.red
        
        return linkListTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.complaintHandleDataSource[indexPath.section] as! ComplaintHandleModel
        
        
        if (model.Type?.compare("-1") == .orderedSame) {
            //未分派任务
            let compaintVC = ComplaintHandlingAddViewController()
            compaintVC.addComplaintFormModel = self.addCompaintArray[indexPath.section] as! AddComplaintFormModel;
            self.navigationController?.pushViewController(compaintVC, animated: true)
        }else {
            let linkDetailVC = DealComplaintHandleListViewController()
            linkDetailVC.complaintHandleModel = model
            self.navigationController?.pushViewController(linkDetailVC, animated: true)
        }
    }
    
    @objc override func requestData() {
        super.requestData()
        
        LoadView.storeLabelText = "正在加载投诉处理信息"
        
        let getComplaintListAPICmd = GetComplaintListAPICmd()
        getComplaintListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getComplaintListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","version":"8.2"]
        getComplaintListAPICmd.loadView = LoadView()
        getComplaintListAPICmd.loadParentView = self.view
        getComplaintListAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.complaintHandleDataSource.removeAllObjects()
                
                self.addCompaintArray = NSMutableArray(array: AddComplaintFormModel.find(byCriteria: " WHERE Category = 'NoSend'"))
                
                for model in self.addCompaintArray {
                    
                    let addModel = model as! AddComplaintFormModel
                    let json = addModel.yy_modelToJSONString()
                    
                    let data = json?.data(using: .utf8)
                    let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    let complaintModel = ComplaintHandleModel()
                    complaintModel.setValuesForKeys(dictionary as! [String : Any])
                    complaintModel.Type = "-1"
                    
                    self.complaintHandleDataSource.add(complaintModel)
                    
                }
                
                for (_,tempDict) in dict["infos"] {
                    
                    if let complaintHandleModel:ComplaintHandleModel = ComplaintHandleModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        self.complaintHandleDataSource.add(complaintHandleModel)
                    }
                    
                }
                
                for model in self.complaintHandleDataSource {
                    let complainModel = model as! ComplaintHandleModel
                    if complainModel.Code == self.notificationBillCode {
                        let linkDetailVC = DealComplaintHandleListViewController()
                        linkDetailVC.complaintHandleModel = complainModel
                        self.navigationController?.pushViewController(linkDetailVC, animated: true)
                        self.notificationBillCode = ""
                        break
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
    
    func floatingViewClick() {
        self.navigationController?.pushViewController(ComplaintHandlingAddViewController(), animated: true)
    }

}
