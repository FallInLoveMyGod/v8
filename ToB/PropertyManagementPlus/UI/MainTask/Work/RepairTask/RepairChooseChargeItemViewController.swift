//
//  RepairChooseChargeItemViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

//TODO:
@objc public protocol RepairChooseChargeItemDelegate {
    @objc optional func confirmRepairChooseChargeItemWithObject(object: AnyObject)
}

class RepairChooseChargeItemViewController: BaseTableViewController {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    //1:收费项目 2选择维修类别
    var itemType = 1
    
    var delegate: RepairChooseChargeItemDelegate?
    
    var dataSource = NSMutableArray(capacity: 20)
    var type = 1
    var model = GetRepaireTypeModel()
    
    var selectIndexPath = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if (type == 1) {
            dataSource.add(NSMutableArray(capacity: 20))
            dataSource.add(NSMutableArray(capacity: 20))
            dataSource.add(NSMutableArray(capacity: 20))
        }

        self.view.backgroundColor = UIColor.white
        
        if (itemType == 1) {
            self.setTitleView(titles: ["请选择收费项目"])
        }else {
            self.setTitleView(titles: ["请选择维修类别"])
        }
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49))
        
        requestCategoryData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(confirm)], target: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.dataSource[type - 1] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (tableViewCell == nil) {
            tableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        let model = (self.dataSource[type - 1] as! NSArray)[indexPath.row] as! GetRepaireTypeModel
        tableViewCell?.textLabel?.text = model.repairtypename
        
        return tableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = (self.dataSource[type - 1] as! NSArray)[indexPath.row] as! GetRepaireTypeModel
        
        selectIndexPath = indexPath.row
        
        if (type == 3) {
            
            confirm()
            return
        }
        
        let vc = RepairChooseChargeItemViewController()
        
        vc.model = model
        
        vc.dataSource = dataSource
        vc.type = type + 1
        vc.delegate = delegate
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func requestData() {
        self.stopFresh()
    }
    
    
    func requestCategoryData() {
        
        LoadView.storeLabelText = "正在加载维修类别信息"
        
        let getRepaireTypeAPICmd = GetRepaireTypeAPICmd()
        getRepaireTypeAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getRepaireTypeAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":type]
        getRepaireTypeAPICmd.loadView = LoadView()
        getRepaireTypeAPICmd.loadParentView = self.view
        getRepaireTypeAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                let tempArray = NSMutableArray(capacity: 20)
                
                for (_,tempDict) in dict["infos"] {
                    
                    if let getRepaireTypeModel:GetRepaireTypeModel = JSONDeserializer<GetRepaireTypeModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                        
                        if (self.type == 1) {
                            tempArray.add(getRepaireTypeModel)
                        }else {
                            if (getRepaireTypeModel.sort?.compare(String(self.type)) == .orderedSame
                                && self.model.repairtypepk?.compare(getRepaireTypeModel.superiorpk!) == .orderedSame) {
                                tempArray.add(getRepaireTypeModel)
                            }
                        }
                    }
                    
                }
                
                if (self.type == 1) {
                    self.dataSource[0] = tempArray
                }else if (self.type == 2) {
                    self.dataSource[1] = tempArray
                }else if (self.type == 3) {
                    self.dataSource[2] = tempArray
                }
                
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    @objc func confirm() {
        
        if (self.dataSource.count > type - 1) {
            
            let array = (self.dataSource[type - 1] as! NSArray)
            
            if (array.count == 0) {
                return
            }
            
            let model = array[selectIndexPath] as! GetRepaireTypeModel
            delegate?.confirmRepairChooseChargeItemWithObject!(object: model)
            
            for vc in (self.navigationController?.childViewControllers)! {
                
                if (vc.isKind(of: TaskDetailViewController.self)) {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                
            }
        }

    }

}
