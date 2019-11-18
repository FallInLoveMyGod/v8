//
//  EventListViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class EventListViewController: BaseTableViewController,FJFloatingViewDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    var infoCustomerIntentMaterialModel: InfoCustomerIntentMaterialModel = InfoCustomerIntentMaterialModel()
    var eventType = EventType.eventCustomer
    var dataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var titleNames: NSMutableArray = NSMutableArray(capacity: 20)
    
    var hud: MBProgressHUD = MBProgressHUD()
    
    var selectNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (eventType == .warehouseIn || eventType == .warehouseOut) {
            return 90.0
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
        
        let cellIdentifier = "CellIdentifier"
        
        var carInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (eventType == .warehouseIn || eventType == .warehouseOut) {
            
            if carInfoTableViewCell == nil {
                
                carInfoTableViewCell = Bundle.main.loadNibNamed("WarehouseInOutListShowTableViewCell", owner: nil, options: nil)?.first as! WarehouseInOutListShowTableViewCell
                carInfoTableViewCell?.selectionStyle = .none
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDelete(longPress:)))
                carInfoTableViewCell?.contentView.isUserInteractionEnabled = true
                carInfoTableViewCell?.contentView.addGestureRecognizer(longPress)
            }
            
            let tempCell: WarehouseInOutListShowTableViewCell = carInfoTableViewCell as! WarehouseInOutListShowTableViewCell
            
            let model:WarehouseInOutListModel = dataSource[indexPath.section] as! WarehouseInOutListModel
            if (eventType == .warehouseOut) {
                tempCell.title.text = "出仓单"
            }else {
                tempCell.title.text = "入仓单"
            }
            tempCell.time.text = model.InDate
            //tempCell.number.text = model.ListItems
            
            let datas = BaseTool.dictionary(withJsonString: model.ListItems) as! NSArray
            tempCell.number.text = "物品数量 ".appending(String(datas.count))
            
            for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '仓库信息'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                if (getDictionaryInfosModel.Id?.compare(model.WarehouseID!) == .orderedSame) {
                    tempCell.wareHouseName.text = "仓库名称 ".appending(getDictionaryInfosModel.Content!)
                    break;
                }
            }
            
            var criteria =  ""
            if (eventType == .warehouseIn) {
                criteria = criteria.appending(" WHERE Type = '入仓类别'")
            }else {
                criteria = criteria.appending(" WHERE Type = '出仓类别'")
            }
            
            for tempModel in GetDictionaryInfosModel.find(byCriteria:  criteria) {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                if (getDictionaryInfosModel.Id?.compare(model.WarehouseWarrantType!) == .orderedSame) {
                    if (eventType == .warehouseIn) {
                        tempCell.category.text = "入仓类别 ".appending(getDictionaryInfosModel.Content!)
                    }else {
                        tempCell.category.text = "出仓类别 ".appending(getDictionaryInfosModel.Content!)
                    }
                    break;
                }
            }
            
            return carInfoTableViewCell!
        }
        
        if carInfoTableViewCell == nil {
            
            carInfoTableViewCell = Bundle.main.loadNibNamed("CarInfoTableViewCell", owner: nil, options: nil)?.first as! CarInfoTableViewCell
            carInfoTableViewCell?.selectionStyle = .none
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDelete(longPress:)))
            carInfoTableViewCell?.contentView.isUserInteractionEnabled = true
            carInfoTableViewCell?.contentView.addGestureRecognizer(longPress)
        }
        
        let tempCell: CarInfoTableViewCell = carInfoTableViewCell as! CarInfoTableViewCell
        
        tempCell.materialCodeNameLabel.text = titleNames[0] as? String
        tempCell.materialXHNameLabel.text = titleNames[1] as? String
        tempCell.locationNameLabel.text = titleNames[2] as? String
        
        if (eventType == .eventCustomer) {
            let model:AddCustomerEventModel = dataSource[indexPath.section] as! AddCustomerEventModel
            tempCell.statusLabel.textColor = UIColor.red
            tempCell.titleLabel.text = model.EvetnTypeId
            //客户事件类别
            for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '客户事件类别'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                if (getDictionaryInfosModel.Id?.compare(model.EvetnTypeId!) == .orderedSame) {
                    tempCell.titleLabel.text = getDictionaryInfosModel.Content
                    break;
                }
            }
            tempCell.statusLabel.text = "未提交"
            tempCell.materialCodeLabel.text = model.EvetnDate
            tempCell.materialXHLabel.text = model.Address?.appending(model.TenantName!)
            tempCell.locationLabel.text = model.Content
        }else if (eventType == .customerComeIn) {
            //跟进记录InfoCustomerComeInModel
            let model:InfoCustomerComeInModel = dataSource[indexPath.section] as! InfoCustomerComeInModel
            tempCell.titleLabel.text = model.IntentionState
            tempCell.statusLabel.text = model.Date
            tempCell.materialCodeLabel.text = model.FollowMan
            tempCell.materialXHLabel.text =  model.Way
            tempCell.locationLabel.text = model.Content
            tempCell.topTrailConstraint.constant = -90
            
            //"招商管理_跟进方式","招商管理_客户意向状态"
            for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '招商管理_跟进方式'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                if (getDictionaryInfosModel.Id?.compare(model.Way!) == .orderedSame) {
                    tempCell.materialXHLabel.text = getDictionaryInfosModel.Content
                    break;
                }
            }
            
            for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '招商管理_客户意向状态'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                if (getDictionaryInfosModel.Id?.compare(model.IntentionState!) == .orderedSame) {
                    tempCell.titleLabel.text = getDictionaryInfosModel.Content
                    break;
                }
            }
            
        }else if (eventType == .eventSudden) {
            let model:AddSuddenEventModel = dataSource[indexPath.section] as! AddSuddenEventModel
            tempCell.statusLabel.textColor = UIColor.orange
            if model.commitStatus?.compare("0") == .orderedSame {
                //未提交
                tempCell.statusLabel.text = "未提交"
            }else {
                //未上报
                tempCell.statusLabel.text = "未上报"
            }
            
            tempCell.materialCodeLabel.text = model.EventDate?.appending(" ").appending(model.SpecificTime!)
            tempCell.materialXHLabel.text = model.Address
            tempCell.locationLabel.text = model.EvetSummary
            
            for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '重大事件_类别'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                if (getDictionaryInfosModel.Id?.compare(model.EventTypeName!) == .orderedSame) {
                    tempCell.titleLabel.text = getDictionaryInfosModel.Content
                    break;
                }
            }
            
        }
        else {
            tempCell.statusLabel.text = "未上报"
        }
        
        return carInfoTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (eventType == .customerComeIn
            || eventType == .eventCustomer
            || eventType == .eventSudden
            || eventType == .warehouseOut
            || eventType == .warehouseIn) {
            //跟进修改
            let eventAdd = EventAddViewController()
            eventAdd.eventType = eventType
            if (eventType == .eventCustomer) {
                let model:AddCustomerEventModel = dataSource[indexPath.section] as! AddCustomerEventModel
                eventAdd.addCustomerEventModel = model
                eventAdd.eventCustomerIsModify = true
            }else if (eventType == .eventSudden) {
                let model:AddSuddenEventModel = dataSource[indexPath.section] as! AddSuddenEventModel
                eventAdd.addSuddenEventModel = model
                eventAdd.eventSuddenIsModify = true
            }else if (eventType == .customerComeIn) {
                let model:InfoCustomerComeInModel = dataSource[indexPath.section] as! InfoCustomerComeInModel
                eventAdd.addCustomerComeInModel = model
                eventAdd.customerComeInIsModify = true
            }else if (eventType == .warehouseOut || eventType == .warehouseIn) {
                let model:WarehouseInOutListModel = dataSource[indexPath.section] as! WarehouseInOutListModel
                eventAdd.wareHouseInfoIsModify = true
                eventAdd.warehouseInOutListModel = model
            }
            
            self.pushNormalViewController(viewController: eventAdd)
        }
        
    }
    
    //MARK: FJFloatingViewDelegate
    
    func floatingViewClick() {
        let eventAdd = EventAddViewController()
        eventAdd.eventType = eventType
        if (eventType == .customerComeIn) {
            //跟进
            
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateStr = dateFmt.string(from: Date())
            
            let model = InfoCustomerComeInModel()
            model.CName = infoCustomerIntentMaterialModel.CName
            model.Date = dateStr
            model.CId = infoCustomerIntentMaterialModel.CID
            model.IsContinue = "0"
            eventAdd.addCustomerComeInModel = model
        }
        self.pushNormalViewController(viewController: eventAdd)
    }
    
    func createUI() {
        
        self.view.backgroundColor = UIColor.white
        
        if (eventType == .eventCustomer) {
            self.setTitleView(titles: ["客户事件" as NSString])
            titleNames = ["创建日期","客户信息","时间内容"]
        }else if (eventType == .warehouseIn) {
            self.setTitleView(titles: ["入仓单列表" as NSString])
        }else if (eventType == .warehouseOut) {
            self.setTitleView(titles: ["出仓单列表" as NSString])
        }else if (eventType == .customerComeIn) {
            //跟进记录
            titleNames = ["跟进人","跟进方式","跟进内容"]
            self.setTitleView(titles: ["跟进记录" as NSString])
        }else {
            self.setTitleView(titles: ["重大事件" as NSString])
            titleNames = ["事件时间","事件地点","事件摘要"]
        }
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49), hasHeader: true, hasFooter: false)
        floatingView.delegate = self
        self.view.addSubview(floatingView)
        
        if (eventType == .warehouseIn || eventType == .warehouseOut) {
            
            let goods = NSMutableArray(array: WarehouseInOutGoodsModel.findAll())
            
            if (goods.count == 0) {
                
                let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "尚未获取物品信息，请先获取物品信息", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "确认", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    self.updateGoods()
                })
                let confirmAction = UIAlertAction(title: "返回", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    self.pop()
                })
                tipAlertView.addAction(cancelAction)
                tipAlertView.addAction(confirmAction)
                self.present(tipAlertView, animated: true, completion: {
                    
                })
                
            }
            
        }else if (eventType == .customerComeIn || eventType == .eventSudden) {
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }else {
            buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commit)], target: self)
        }
        
    }
    
    //MARK: Event Response
    
    @objc func commit() {
        if (eventType == .eventCustomer) {
            //提交客户事件列表AddCustomerEventAPICmd
            
            var object = NSMutableArray(capacity: 20)
            
            for model in dataSource {
                let addCustomerEventModel = model as! AddCustomerEventModel
                
                let json = addCustomerEventModel.yy_modelToJSONString()
                
                let data = json?.data(using: .utf8)
                let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let changeDict = NSMutableDictionary(dictionary: dictionary!)
                changeDict.removeObject(forKey: "pk")
                changeDict.removeObject(forKey: "TenantName")
                changeDict.removeObject(forKey: "Address")
                object.add(changeDict)
            }
            
            LoadView.storeLabelText = "正在提交客户事件信息"
            
            let addCustomerEventAPICmd = AddCustomerEventAPICmd()
            addCustomerEventAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            addCustomerEventAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","infos":object.yy_modelToJSONString() ?? ""]
            addCustomerEventAPICmd.loadView = LoadView()
            addCustomerEventAPICmd.loadParentView = self.view
            addCustomerEventAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    AddCustomerEventModel.clearTable()
                    self.dataSource.removeAllObjects()
                    self.contentTableView?.reloadData()
                    LocalToastView.toast(text: "提交成功！")
                    self.buttonAction(titles: ["返回"], actions: [#selector(self.pop)], target: self)
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                
                LocalToastView.toast(text: DisNetWork)
            }
            
        }else if (eventType == .warehouseIn || eventType == .warehouseOut) {
            //AddWarehouseRecepitAPICmd (入仓) AddWarehouseWarrantAPICmd (出仓)
            //billInfo
            
            hud.label.text = "正在上传"
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            self.commitCycle(model: self.dataSource[0] as! WarehouseInOutListModel)
        }
    }
    
    func commitCycle(model: WarehouseInOutListModel) {
        
        var addWarehouseRecepitAPICmd = XYCBaseRequest()
        
        let resultDict = NSMutableDictionary(capacity: 20)
        resultDict.setValue(model.WarehouseID, forKey: "WarehouseID")
        resultDict.setValue(model.WarehouseWarrantType, forKey: "WarehouseWarrantType")
        
        if (eventType == .warehouseIn) {
            resultDict.setValue(model.InDate, forKey: "InDate")
            addWarehouseRecepitAPICmd = AddWarehouseRecepitAPICmd()
        }else {
            resultDict.setValue(model.InDate, forKey: "OutDate")
            addWarehouseRecepitAPICmd = AddWarehouseWarrantAPICmd()
        }
        
        let removeArray = NSMutableArray(capacity: 20)
        let tempArray = NSMutableArray(array: BaseTool.dictionary(withJsonString: model.ListItems) as! NSArray)
        for dict in tempArray {
            
            let dealDict = dict as! NSMutableDictionary
            
            dealDict.removeObject(forKey: "Name")
            removeArray.add(dealDict)
        }
        
        resultDict.setValue(removeArray, forKey: "ListItems")
        
        addWarehouseRecepitAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        addWarehouseRecepitAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","billInfo":resultDict.yy_modelToJSONString() ?? ""]
        addWarehouseRecepitAPICmd.transactionWithSuccess({ (response) in
            
            print(response)
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                //数据库删除
                WarehouseInOutListModel.delete([self.dataSource[0] as! WarehouseInOutListModel])
                
            }
            
            //本地数据删除
            self.dataSource.removeObject(at: 0)
            
            if (self.dataSource.count == 0) {
                //check
                self.checkStatus()
            }else {
                self.commitCycle(model: self.dataSource[0] as! WarehouseInOutListModel)
            }
            
        }) { (response) in
            self.checkStatus()
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    func checkStatus() {
        
        self.requestData()
        if (self.dataSource.count == 0) {
            LocalToastView.toast(text: "上传成功")
        }else {
            LocalToastView.toast(text: "部分提交失败")
        }
        hud.hide(animated: true)
        freshTopUI()
        self.contentTableView?.reloadData()
    }
    
    func freshTopUI() {
        
        if (self.dataSource.count == 0) {
            if (eventType == .warehouseIn) {
                self.setTitleView(titles: ["入仓单列表" as NSString])
            }else {
                self.setTitleView(titles: ["出仓单列表" as NSString])
            }
        }else {
            
            var content = ""
            if (eventType == .warehouseIn) {
                content = String("入仓单列表,共(") + String(self.dataSource.count)
                content.append(")条")
                self.setTitleView(titles: [content as NSString])
            }else {
                content = String("出仓单列表,共(") + String(self.dataSource.count)
                content.append(")条")
                self.setTitleView(titles: [content as NSString])
            }
        }
    }
    
    @objc func updateGoods() {
        
        LoadView.storeLabelText = "正在加载物品信息"
        
        let getWarehouseGoodsListAPICmd = GetWarehouseGoodsListAPICmd()
        getWarehouseGoodsListAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getWarehouseGoodsListAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        getWarehouseGoodsListAPICmd.loadView = LoadView()
        getWarehouseGoodsListAPICmd.loadParentView = self.view
        getWarehouseGoodsListAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                WarehouseInOutGoodsModel.clearTable()
                
                for (_,tempDict) in dict["List"] {
                    
                    if let warehouseInOutGoodsModel:WarehouseInOutGoodsModel = WarehouseInOutGoodsModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        warehouseInOutGoodsModel.save()
                    }
                    
                }
                LocalToastView.toast(text: "获取物品成功！")
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            
        }
    }
    
    func changeStatus() {
        
        if (eventType == .eventCustomer
            || eventType == .eventSudden) {
            
            if (dataSource.count == 0) {
                buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
            }else {
                buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commit)], target: self)
            }
            
        }
        
    }
    
    override func requestData() {
        super.requestData()
        
        if (eventType == .eventCustomer) {
            dataSource = NSMutableArray(array: AddCustomerEventModel.findAll())
            changeStatus()
            self.contentTableView?.reloadData()
            self.stopFresh()
        }else if (eventType == .eventSudden) {
            dataSource = NSMutableArray(array: AddSuddenEventModel.findAll())
            changeStatus()
            self.contentTableView?.reloadData()
            self.stopFresh()
        }else if (eventType == .customerComeIn) {
            //跟进记录
            LoadView.storeLabelText = "正在加载跟进记录"
            
            let searchFollowRecordAPICmd = SearchFollowRecordAPICmd()
            searchFollowRecordAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            searchFollowRecordAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Cid":infoCustomerIntentMaterialModel.CID ?? "","Id":"","version":"1.0"]
            searchFollowRecordAPICmd.loadView = LoadView()
            searchFollowRecordAPICmd.loadParentView = self.view
            searchFollowRecordAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.dataSource.removeAllObjects()
                    
                    for (_,tempDict) in dict["Infos"] {
                        
                        if let infoCustomerComeInModel:InfoCustomerComeInModel = InfoCustomerComeInModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.dataSource.add(infoCustomerComeInModel)
                            let criteria = "WHERE CId = '".appending(infoCustomerComeInModel.CId!).appending("'")
                            
                            let findArray: NSArray = InfoCustomerComeInModel.find(byCriteria: criteria) as NSArray
                            if (findArray.count == 0) {
                                infoCustomerComeInModel.save()
                            }else {
                                infoCustomerComeInModel.update()
                            }
                            
                        }
                        
                    }
                    
                    self.dataSource.sort(comparator: { (modelF, modelS) -> ComparisonResult in
                        let modelFT = modelF as! InfoCustomerComeInModel
                        let modelST = modelS as! InfoCustomerComeInModel
                        return (modelST.Date?.compare(modelFT.Date!))!
                    });
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
        }else if (eventType == .warehouseIn || eventType == .warehouseOut) {
            
            self.dataSource = NSMutableArray(capacity: 20)
            let seperateArray = WarehouseInOutListModel.findAll()
            for model in seperateArray! {
                
                let tempModel: WarehouseInOutListModel = model as! WarehouseInOutListModel
                if (eventType == .warehouseIn && tempModel.IsWarehouseRecepit?.compare("1") == .orderedSame) {
                    self.dataSource.add(model)
                }else if (eventType == .warehouseOut && tempModel.IsWarehouseRecepit?.compare("0") == .orderedSame){
                    self.dataSource.add(model)
                }
            }
            
            freshTopUI()
            
            if (self.dataSource.count == 0) {
                buttonAction(titles: ["返回","更新物品"], actions: [#selector(pop),#selector(updateGoods)], target: self)
            }else {
                buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commit)], target: self)
//                buttonAction(titles: ["返回","更新物品","提交"], actions: [#selector(pop),#selector(updateGoods),#selector(commit)], target: self)
            }
            
            self.contentTableView?.reloadData()
            self.stopFresh()
        }
    }
    
    @objc func longPressDelete(longPress: UILongPressGestureRecognizer) {
        selectNumber = (longPress.view?.tag)!
        showActionSheet(title: "选择操作对象", cancelTitle: "取消", titles: ["删除当前","删除所有"], tag: "HandleDeleteStyle")
    }
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if tag.compare("HandleDeleteStyle") == .orderedSame {
            if (buttonIndex == 1) {
                let model:DBCommonModel = dataSource[selectNumber] as! DBCommonModel
                model.deleteObject()
                dataSource.removeObject(at: selectNumber)
            }else if (buttonIndex == 2) {
                
                switch eventType {
                case .eventCustomer:
                    AddCustomerEventModel.clearTable()
                case .eventSudden:
                    AddSuddenEventModel.clearTable()
                case .customerComeIn:
                    InfoCustomerComeInModel.clearTable()
                case .warehouseOut,.warehouseIn:
                    WarehouseInOutListModel.clearTable()
                default:
                    break
                }
                dataSource.removeAllObjects()
                
                pop()
            }
            changeStatus()
            self.contentTableView?.reloadData()
        }
    }

}
