//
//  ComplaintHandingContactInfoViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class ComplaintHandingContactInfoViewController: BaseTableViewController {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()

    var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: ["客户信息"])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49), hasHeader: false, hasFooter: false)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customerDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
//        let titleLable = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth, height: 30))
//        titleLable.font = UIFont.boldSystemFont(ofSize: 16)
//        titleLable.text = "房产架构"
//        backView.addSubview(titleLable)
//        return backView
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if tableViewCell == nil {
            
            tableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            tableViewCell?.accessoryType = .disclosureIndicator
            tableViewCell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        let model: HouseStructureModel = self.customerDataSource[indexPath.row] as! HouseStructureModel
        
        tableViewCell?.textLabel?.text = model.Name
        
        return tableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let customerInfoVC = CustomerInfoViewController()
        customerInfoVC.levelHouseStructureModel = self.customerDataSource[indexPath.row] as! HouseStructureModel
        self.push(viewController: customerInfoVC)
        
    }
    
    override func requestData() {
        
        self.customerDataSource.removeAllObjects()
        
        let response = UserDefaults.standard.object(forKey: HouseStructureDataSynchronization)
        
        let dict = JSON(response ?? {})
        
        for (_,tempDict) in dict["PProjects"] {
            
            if let houseStructureModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                self.customerDataSource.add(houseStructureModel)
            }
            
        }
        
        self.contentTableView?.reloadData()
        
    }
}
