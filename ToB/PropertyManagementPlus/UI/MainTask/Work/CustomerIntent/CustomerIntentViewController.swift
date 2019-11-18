//
//  CustomerIntentViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class CustomerIntentViewController: BaseTableViewController,FJFloatingViewDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    var titleNames: NSMutableArray = NSMutableArray(array: [
        ["LevelName":"未跟进","Content":[]],
        ["LevelName":"已跟进","Content":[]],
        ["LevelName":"已认租","Content":[]],
        ["LevelName":"已签约","Content":[]],
        ["LevelName":"已退租","Content":[]]])
    var values: Array<JSON> = Array()
    
    var selectStatusArray: NSMutableArray = NSMutableArray(array: ["0","1","0","0","0"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = (titleNames[section] as! NSDictionary)["Content"] as! NSArray
        let status = (selectStatusArray[section] as? String)
        if (status?.compare("0") == .orderedSame) {
            return 1
        }
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10.0
        }
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
        var taskNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskNumberTableViewCell == nil {
            
            taskNumberTableViewCell = Bundle.main.loadNibNamed("TaskNumberTableViewCell", owner: nil, options: nil)?.first as! TaskNumberTableViewCell
            taskNumberTableViewCell?.selectionStyle = .none
            
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
            lineView.backgroundColor = UIColor.groupTableViewBackground
            taskNumberTableViewCell?.contentView.addSubview(lineView)
        }
        
        let tempCell: TaskNumberTableViewCell = taskNumberTableViewCell as! TaskNumberTableViewCell
        tempCell.numberLabelWidthConstraint.constant = 40
        tempCell.numberLabelTrailConstraint.constant = 0
        tempCell.numberLabel.text = "0"
        
        let array = (titleNames[indexPath.section] as! NSDictionary)["Content"] as! NSArray
        if (array.count == 0) {
            tempCell.accessoryType = .disclosureIndicator
            tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSDictionary)["LevelName"] as? String
        }else {
            tempCell.accessoryType = .disclosureIndicator
            tempCell.nameLabel.text = array[indexPath.row] as? String
            if (indexPath.row != 0) {
                tempCell.leftMarginConstraint.constant = 30
            }
        }
        
        for dictDict in self.values {
            let info: Dictionary<String, JSON> = dictDict.dictionaryValue
            if (info["Tag"]?.stringValue.compare(tempCell.nameLabel.text!) == .orderedSame) {
                tempCell.numberLabel.text = info["Num"]?.stringValue
            }
        }
        
        return taskNumberTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let array = (titleNames[indexPath.section] as! NSDictionary)["Content"] as! NSArray
        if (array.count != 0 && indexPath.row == 0) {
            
            if ((selectStatusArray[indexPath.section] as? String)?.compare("1") == .orderedSame) {
                selectStatusArray[indexPath.section] = "0"
            }else {
                selectStatusArray[indexPath.section] = "1"
            }
            
            let indexSet = NSMutableIndexSet()
            indexSet.add(indexPath.section)
            tableView.reloadSections(indexSet as IndexSet, with: .none)
            
            return;
        }
        
        let customerIntentList = InfoMaterialViewController()
        customerIntentList.infoMaterialType = .customerIntent
        if (array.count == 0) {
            customerIntentList.customerIntentCtype = (titleNames[indexPath.section] as! NSDictionary)["LevelName"] as! String
        }else {
            customerIntentList.customerIntentCtype = array[indexPath.row] as! String
        }
        
        self.push(viewController: customerIntentList)
        
    }
    
    //MARK: FJFloatingViewDelegate
    
    func floatingViewClick() {
        //添加
        let addCustomerIntent = EventAddViewController()
        addCustomerIntent.eventType = .customerIntent
        self.push(viewController: addCustomerIntent)
    }
    
    func createUI() {
        
        self.setTitleView(titles: ["客户列表"])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49), hasHeader: true, hasFooter: false)
        
        contentTableView?.separatorStyle = .none
        
        floatingView.delegate = self
        self.view.addSubview(floatingView)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    override func requestData() {
        super.requestData()
        
        LoadView.storeLabelText = "正在查询意向客户信息"
        
        let queryYXKHStatistics = QueryYXKHStatistics()
        queryYXKHStatistics.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        queryYXKHStatistics.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        queryYXKHStatistics.loadView = LoadView()
        queryYXKHStatistics.loadParentView = self.view
        queryYXKHStatistics.transactionWithSuccess({ (response) in
            
            print(response)
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.values = dict["infos"].arrayValue
                self.titleNames = NSMutableArray(array: [
                    ["LevelName":"未跟进","Content":[]],
                    ["LevelName":"已跟进","Content":[]],
                    ["LevelName":"已认租","Content":[]],
                    ["LevelName":"已签约","Content":[]],
                    ["LevelName":"已退租","Content":[]]])
                
                for dictDict in self.values {
                    let info: Dictionary<String, JSON> = dictDict.dictionaryValue
                    if (info["SuperTag"] != nil && info["SuperTag"]?.stringValue.compare("") != .orderedSame) {
                        //存在上级目录
                        var index = 0
                        for dictionary in self.titleNames {
                            let levelName = (dictionary as! NSDictionary)["LevelName"] as! String
                            if (levelName.compare((info["SuperTag"]?.stringValue)!) == .orderedSame) {
                                //编入父组
                                let tempDictionary: NSMutableDictionary = NSMutableDictionary(capacity: 20)
                                let tempDataSource: NSMutableArray = NSMutableArray(array: (dictionary as! NSDictionary)["Content"] as! NSArray)
                                if (tempDataSource.count == 0) {
                                    tempDataSource.add(info["SuperTag"]?.stringValue ?? "")
                                }
                                tempDataSource.add(info["Name"]?.stringValue ?? "")
                                
                                tempDictionary.setValue(levelName, forKey: "LevelName")
                                tempDictionary.setValue(tempDataSource, forKey: "Content")
                                self.titleNames.replaceObject(at: index, with: tempDictionary)
                                
                            }
                            
                            index = index + 1
                        }
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

}
