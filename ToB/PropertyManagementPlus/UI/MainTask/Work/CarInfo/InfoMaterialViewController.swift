//
//  InfoMaterialViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

enum InfoMaterialType {
    //车辆资料
    case car
    //设备资料
    case equipmentMaterial
    //意向客户
    case customerIntent
}

class InfoMaterialViewController: BaseTableViewController,SearchBarViewDelegate,CustomerIntentItemViewDelegate,ChooseAlertDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    //CustomSearchBar
    var searchBar = SearchBarView()
    
    var titleContent : String = "车辆资料"
    var code = ""
    var equipmenttypepk = ""
    var customerIntentCtype = ""
    var infoMaterialType = InfoMaterialType.car
    var dataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var selectModel: InfoCustomerIntentMaterialModel = InfoCustomerIntentMaterialModel()
    
    var chooseTitle:NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (infoMaterialType == .customerIntent) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (infoMaterialType == .customerIntent) {
            if (indexPath.row == 1) {
                return 35
            }
            return 115
        }
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (infoMaterialType == .customerIntent && indexPath.row == 1) {
            
            let normalCellID = "NormalCellID"
            var cell = tableView.dequeueReusableCell(withIdentifier: normalCellID)
            if (cell == nil) {
                cell = UITableViewCell(style: .default, reuseIdentifier: normalCellID)
                cell?.separatorInset = .zero
                cell?.layoutMargins = .zero
                cell?.preservesSuperviewLayoutMargins = false
            }
            
            for view in (cell?.contentView.subviews)! {
                if (view.isKind(of: CustomerIntentItemView.self)) {
                    view.removeFromSuperview()
                }
            }
            
            //cell?.contentView.viewWithTag(indexPath.section + 1000)?.removeFromSuperview()
            
            let intentView = CustomerIntentItemView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35), titles: ["客户需求","跟进记录","短信联系","电话联系"], icons: ["icon_tixing","icon_more","icon_msg","icon_phone"])
            intentView?.delegate = self
            intentView?.tag = indexPath.section + 1000
            cell?.contentView.addSubview(intentView!)
            
            return cell!
        }
        
        let cellIdentifier = "CellIdentifier"
        var carInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if carInfoTableViewCell == nil {
            
            carInfoTableViewCell = Bundle.main.loadNibNamed("CarInfoTableViewCell", owner: nil, options: nil)?.first as! CarInfoTableViewCell
            carInfoTableViewCell?.selectionStyle = .none
            
            carInfoTableViewCell?.separatorInset = .zero
            carInfoTableViewCell?.layoutMargins = .zero
            carInfoTableViewCell?.preservesSuperviewLayoutMargins = false
        }
        
        let tempCell: CarInfoTableViewCell = carInfoTableViewCell as! CarInfoTableViewCell
        
        if (infoMaterialType == .car) {
            
            let model: InfoMaterialModel = dataSource[indexPath.section] as! InfoMaterialModel
            tempCell.statusLabel.isHidden = true
            tempCell.titleLabel.text = model.Code
            tempCell.materialCodeNameLabel.text = "车辆类型"
            tempCell.materialXHNameLabel.text = "车主名称"
            tempCell.locationNameLabel.text = "车位信息"
            tempCell.materialCodeLabel.text = model.Type
            tempCell.materialXHLabel.text = model.Name
            tempCell.locationLabel.text = model.Parkinglot
        }else if (infoMaterialType == .equipmentMaterial){
            
            let model: InfoEquipmentMaterialModel = dataSource[indexPath.section] as! InfoEquipmentMaterialModel
            tempCell.statusLabel.isHidden = false
            tempCell.statusLabel.text = model.equipmentstate
            tempCell.titleLabel.text = model.equipmentname
            tempCell.materialCodeNameLabel.text = "设备编号"
            tempCell.materialXHNameLabel.text = "设备型号"
            tempCell.locationNameLabel.text = "位置信息"
            tempCell.materialCodeLabel.text = model.equipmentno
            tempCell.materialXHLabel.text = model.equipmenttype
            tempCell.locationLabel.text = model.equipmentlocation
        }else if (infoMaterialType == .customerIntent) {
            let model: InfoCustomerIntentMaterialModel = dataSource[indexPath.section] as! InfoCustomerIntentMaterialModel
            tempCell.statusLabel.isHidden = true
            tempCell.titleLabel.text = model.CName
            tempCell.materialCodeNameLabel.text = "跟进次数"
            tempCell.materialXHNameLabel.text = "首访时间"
            tempCell.locationNameLabel.text = "最近跟进"
            tempCell.materialCodeLabel.text = model.Num
            if (model.FirstDate?.compare("0001-01-01T00:00:00") != .orderedSame) {
                tempCell.materialXHLabel.text = model.FirstDate
            }
            if (model.RecentDate?.compare("0001-01-01T00:00:00") != .orderedSame) {
                tempCell.locationLabel.text = model.RecentDate
            }
        }
        
        return carInfoTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (infoMaterialType == .car || infoMaterialType == .equipmentMaterial) {
            let detail = DataInfoDetailViewController()
            if (infoMaterialType == .car) {
                let model: InfoMaterialModel = dataSource[indexPath.section] as! InfoMaterialModel
                detail.code = model.Code!
                detail.titleName = model.Code! as NSString
                detail.dataInfoDetailType = .dataInfoDetailCar
            }else {
                let model: InfoEquipmentMaterialModel = dataSource[indexPath.section] as! InfoEquipmentMaterialModel
                detail.equipmentModel = model
                detail.titleName = model.equipmentno! as NSString
                detail.dataInfoDetailType = .dataInfoDetailEquipment
            }
            self.push(viewController: detail)
        }else if (infoMaterialType == .customerIntent) {
            if (indexPath.row == 0) {
                let model: InfoCustomerIntentMaterialModel = dataSource[indexPath.section] as! InfoCustomerIntentMaterialModel
                let eventCustomerInfoVC = EventAddViewController()
                let addUpdateYXKHInfoModel = AddUpdateYXKHInfoModel()
                addUpdateYXKHInfoModel.CID = model.CID
                eventCustomerInfoVC.eventType = .customerIntent
                eventCustomerInfoVC.customerIntentInfoIsModify = true
                eventCustomerInfoVC.addUpdateYXKHInfoModel = addUpdateYXKHInfoModel
                self.push(viewController: eventCustomerInfoVC)
            }
        }
        
        
    }
    
    //MARK: SearchBarViewDelegate
    func textFieldDidChange(_ textField: UITextField!) {
        
    }
    
    //MARK: CustomerIntentItemViewDelegate
    func buttonItemClick(_ sender: UIButton!, intentView: CustomerIntentItemView!) {
        
        let model: InfoCustomerIntentMaterialModel = dataSource[intentView.tag - 1000] as! InfoCustomerIntentMaterialModel
        selectModel = model
        if (sender.titleLabel?.text?.compare("客户需求") == .orderedSame) {
            let eventAdd = EventAddViewController()
            eventAdd.addCustomerNeedInfoModel = model
            eventAdd.eventType = .customerNeedInfo
            self.push(viewController: eventAdd)
        }else if (sender.titleLabel?.text?.compare("跟进记录") == .orderedSame) {
            
            let comeInList = EventListViewController()
            comeInList.eventType = .customerComeIn
            comeInList.infoCustomerIntentMaterialModel = model
            self.push(viewController: comeInList)
        }else if (sender.titleLabel?.text?.compare("短信联系") == .orderedSame) {
            
            if (model.PhoneNum != nil && model.PhoneNum?.compare("") != .orderedSame) {
                if (Validate.phoneNum(model.PhoneNum!).isRight) {
                    let phone = "sms://".appending(model.PhoneNum!)
                    UIApplication.shared.openURL(URL(string: phone)!)
                }else {
                    LocalToastView.toast(text: "不是有效的手机号码")
                }
            }
            
        }else if (sender.titleLabel?.text?.compare("电话联系") == .orderedSame) {
            action()
        }
    }
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return;
        }
        
        if (tag.compare("Select") == .orderedSame) {
            
            if (buttonIndex == 1) {
                UIPasteboard.general.string = selectModel.PhoneNum
            }else if (buttonIndex == 2
                || buttonIndex == 3) {
                
                if (selectModel.PhoneNum != nil && selectModel.PhoneNum?.compare("") != .orderedSame) {
                    if (buttonIndex == 3) {
                        if (Validate.phoneNum(selectModel.PhoneNum!).isRight) {
                            let phone = "sms://".appending(selectModel.PhoneNum!)
                            UIApplication.shared.openURL(URL(string: phone)!)
                        }else {
                            LocalToastView.toast(text: "不是有效的手机号码")
                        }
                    }else {
                        let sms = "tel:".appending(selectModel.PhoneNum!)
                        UIApplication.shared.openURL(URL(string: sms)!)
                    }
                }
            }
        }
    }
    
    func initData() {
        
        self.dataSource = NSMutableArray(capacity: 20)
        
        if (self.infoMaterialType == .car) {
            self.dataSource.addObjects(from: InfoMaterialModel.findAll())
        }else if (self.infoMaterialType == .equipmentMaterial){
            let array = InfoEquipmentMaterialModel.findAll()
            for model in array! {
                let equipmentModel = model as! InfoEquipmentMaterialModel
                if (equipmentModel.equipmenttypepk?.compare(equipmenttypepk) == .orderedSame) {
                    self.dataSource.add(model)
                }
            }
        }else if (self.infoMaterialType == .customerIntent) {
            
            //customerIntentCtype 判断
            let tempDataSource = NSMutableArray(array: InfoCustomerIntentMaterialModel.findAll())
            
            for model in tempDataSource {
                let tempModel = model as! InfoCustomerIntentMaterialModel
                if (tempModel.CustomerIntentCtype?.compare(customerIntentCtype) == .orderedSame) {
                    self.dataSource.add(tempModel)
                }
            }
        }
        
        if (self.dataSource.count == 0) {
            requestData()
        }else {
            self.sort()
            self.contentTableView?.reloadData()
        }
        
    }
    
    func createUI() {
        
        self.view.backgroundColor = UIColor.clear
        
        switch infoMaterialType {
        case .car:
            searchBar = SearchBarView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 45), placeHolder: "请输入关键字",searchBarType: .car)
        case .customerIntent:
            searchBar = SearchBarView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 45), placeHolder: "请输入关键字",searchBarType: .intent)
        case .equipmentMaterial:
            searchBar = SearchBarView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 45), placeHolder: "名称/编号/规格信号/位置",searchBarType: .material)
        }
        
        if (infoMaterialType == .equipmentMaterial
            || infoMaterialType == .customerIntent) {
            if (self.dataSource.count == 0) {
                if (infoMaterialType == .customerIntent) {
                    self.setTitleView(titles: ["客户列表"])
                }else {
                    self.setTitleView(titles: [titleContent as NSString])
                }
                
            }else {
                var title = ("设备列表(") + String(self.dataSource.count) + ")条"
                if (infoMaterialType == .customerIntent) {
                    title = ("客户列表(") + String(self.dataSource.count) + ")条记录"
                }
                self.setTitleView(titles: [title as NSString])
            }
        }else {
            self.setTitleView(titles: [titleContent as NSString])
        }
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 45, width: kScreenWidth, height: kScreenHeight - 49 - searchBar.frame.size.height), hasHeader: true, hasFooter: false)
        
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        
        searchBar.dataSource = dataSource
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
//        // 右按钮
//        let rightBarBtn = UIBarButtonItem.init(image: UIImage(named: "SX.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(chooseArea))
//        self.navigationItem.rightBarButtonItem = rightBarBtn;
    }
    
    @objc func chooseArea() {
        if  (!HouseStructureModel.isExistInTable())  {
            let alertv = UIAlertController.init(title: "还未同步房产信息", message: "是否同步", preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction.init(title: "立即同步", style: .default) { (action) in
                DataSynchronizationManager.houseStructureDataSynchronization();
            }
            let cancleAction = UIAlertAction.init(title: "取消", style: .default) { (action) in
                
            }
            alertv.addAction(action1);
            alertv.addAction(cancleAction);
            self.present(alertv, animated: true, completion: nil);
            return;
        }
        let arr:NSArray = HouseStructureModel.findAll()! as NSArray;
        
        let alert = ChooseAlertView.init(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight));
        appDelegate.window?.addSubview(alert)
        alert.delegate = self;
        alert.dataSource = arr;
        alert.show()
    }
    
    func action() {
        showActionSheet(title: "请选择", cancelTitle: "取消", titles: ["复制","拨打电话","发送短信"], tag: "Select")
    }
    
    func sort() {
        if (infoMaterialType == .car) {
            self.dataSource.sort(comparator: { (modelF, modelS) -> ComparisonResult in
                let modelFT = modelF as! InfoMaterialModel
                let modelST = modelS as! InfoMaterialModel
                return (modelST.Name?.compare(modelFT.Name!))!
            });
        }else if (infoMaterialType == .customerIntent) {
            self.dataSource.sort(comparator: { (modelF, modelS) -> ComparisonResult in
                let modelFT = modelF as! InfoCustomerIntentMaterialModel
                let modelST = modelS as! InfoCustomerIntentMaterialModel
                return (modelST.RecentDate?.compare(modelFT.RecentDate!))!
            });
        }
        
        searchBar.dataSource = dataSource
    }
    
    func tableViewSelectWithHouseModel(model: HouseStructureModel) {
        print(model.Code ?? "");
        self.chooseTitle = model.Code! as NSString;
        // 筛选
        let mArr:NSMutableArray = NSMutableArray();
        for item in self.dataSource {
            let tempItem:InfoEquipmentMaterialModel = item as! InfoEquipmentMaterialModel
            if tempItem.PProjectCode == model.Code {
                mArr.add(tempItem);
            }
        }
        self.dataSource.removeAllObjects()
        self.dataSource.addObjects(from: mArr as! [Any]);
        print(self.dataSource.count)
        self.contentTableView?.reloadData()
    }
    
    override func requestData() {
        super.requestData()
        
        if (infoMaterialType == .car) {
            
            LoadView.storeLabelText = "正在加载车辆资料信息"
            
            let searchCarListAPICmd = SearchCarListAPICmd()
            searchCarListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            searchCarListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","State":"1","code":code]
            searchCarListAPICmd.loadView = LoadView()
            searchCarListAPICmd.loadParentView = self.view
            searchCarListAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.dataSource.removeAllObjects()
                    InfoMaterialModel.clearTable()
                    for (_,tempDict) in dict["infos"] {
                        
                        if let infoMaterialModel:InfoMaterialModel = InfoMaterialModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.dataSource.add(infoMaterialModel)
                            infoMaterialModel.save()
                        }
                        
                    }
                    self.sort()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
        }else if (infoMaterialType == .equipmentMaterial){
            
            LoadView.storeLabelText = "正在加载设备资料信息"
            
            let getEquipmentListAPICmd = GetEquipmentListAPICmd()
            getEquipmentListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getEquipmentListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","equipmenttypepk":equipmenttypepk]
            getEquipmentListAPICmd.loadView = LoadView()
            getEquipmentListAPICmd.loadParentView = self.view
            getEquipmentListAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.dataSource.removeAllObjects()
                    InfoEquipmentMaterialModel.clearTable()
                    for (_,tempDict) in dict["info"] {
                        
                        if let infoEquipmentMaterialModel:InfoEquipmentMaterialModel = InfoEquipmentMaterialModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.dataSource.add(infoEquipmentMaterialModel)
                            infoEquipmentMaterialModel.save()
                        }
                        
                    }
                    self.sort()
                    let title = ("设备列表(") + String(self.dataSource.count) + ")条"
                    self.setTitleView(titles: [title as NSString])
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                // 筛选
                if self.chooseTitle != "" && self.chooseTitle != nil  {
                    let mArr:NSMutableArray = NSMutableArray();
                    for item in self.dataSource {
                        let tempItem:InfoEquipmentMaterialModel = item as! InfoEquipmentMaterialModel
                        if tempItem.PProjectCode == self.chooseTitle! as String {
                            mArr.add(tempItem);
                        }
                    }
                    self.dataSource.removeAllObjects()
                    self.dataSource.addObjects(from: mArr as! [Any]);
                    print(self.dataSource.count)
                }
//                self.contentTableView?.reloadData()
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
        }else if (infoMaterialType == .customerIntent) {
            //QueryYXKHInfosAPICmd
            
            LoadView.storeLabelText = "正在加载意向客户信息"
            
            let queryYXKHInfosAPICmd = QueryYXKHInfosAPICmd()
            queryYXKHInfosAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            queryYXKHInfosAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","ctype":customerIntentCtype,"frype":"0"]
            queryYXKHInfosAPICmd.loadView = LoadView()
            queryYXKHInfosAPICmd.loadParentView = self.view
            queryYXKHInfosAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.dataSource.removeAllObjects()
                    InfoCustomerIntentMaterialModel.clearTable()
                    for (_,tempDict) in dict["infos"] {
                        
                        if let infoCustomerIntentMaterialModel:InfoCustomerIntentMaterialModel = InfoCustomerIntentMaterialModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.dataSource.add(infoCustomerIntentMaterialModel)
                            infoCustomerIntentMaterialModel.CustomerIntentCtype = self.customerIntentCtype
                            infoCustomerIntentMaterialModel.save()
                        }
                        
                    }
                    self.sort()
                    var title = ("客户列表(") + String(self.dataSource.count) + ")条记录"
                    if (self.dataSource.count == 0) {
                        title = "客户列表"
                    }
                    self.setTitleView(titles: [title as NSString])
                    
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

}
