//
//  EventAddViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class EventAddViewController: BaseTableViewController,DatePickerDelegate,CustomerInfoDelegate,LSTextFiledDelegate,LSContentInputTextViewDelegate,InfoSelectDelegate,RepairChooseSenderResultDelegate,WarehouseSelectGoodDelegate,WarehouseInNumberDelegate,WarehouseInInputDelegate,WarehouseInOutDelegate,ScanResultDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var eventType = EventType.eventCustomer
    var houseStructureModel = HouseStructureModel()
    var addCustomerEventModel = AddCustomerEventModel()
    var addSuddenEventModel = AddSuddenEventModel()
    var addCustomerComeInModel = InfoCustomerComeInModel()
    var addCustomerNeedInfoModel = InfoCustomerIntentMaterialModel()
    var updateCustomerNeedInfoModel = CustomerNeedInfoModel()
    var addUpdateYXKHInfoModel = AddUpdateYXKHInfoModel()
    var warehouseInOutListModel = WarehouseInOutListModel()
    var energyMeterReadingModel = EnergyMeterReadingModel()
    var selectContentModel = SelectContentModel()
    var titleNames: NSMutableArray = NSMutableArray(capacity: 20)
    
    //客户事件类别-数据 重大事件类别-数据 跟进记录-跟进方式
    var waySourceArray: NSMutableArray = NSMutableArray(capacity: 20)
    var wayArray: NSMutableArray = NSMutableArray(capacity: 20)
    
    //重大事件级别-数据
    var waySuddenSourceArray: NSMutableArray = NSMutableArray(capacity: 20)
    var waySuddenArray: NSMutableArray = NSMutableArray(capacity: 20)
    
    //跟进记录-意向状态
    var wayIntentSourceArray: NSMutableArray = NSMutableArray(capacity: 20)
    var wayIntentArray: NSMutableArray = NSMutableArray(capacity: 20)
    
    var customerNeedInfoValues: NSMutableArray = NSMutableArray(array: ["","","","","",""])
    var customerUpdateYXKHInfoValues: NSMutableArray = NSMutableArray(array: [["","","","","","","",""],["","","",""]])
    var energyMeterInfoValues: NSMutableArray = NSMutableArray(array: [["","","","","","","",""],["","","",""]])
    var wareHouseGoods: NSMutableArray = NSMutableArray(capacity: 20)
    var wareHouseGoodDictionary: NSMutableDictionary = NSMutableDictionary(capacity: 20)
    
    var customerAddress = ""
    
    var customerComeInIsModify: Bool = false
    var eventCustomerIsModify: Bool = false
    var eventSuddenIsModify: Bool = false
    var customerNeedInfoIsModify: Bool = false
    var customerIntentInfoIsModify: Bool = false
    var wareHouseInfoIsModify: Bool = false
    var isPresent:Bool = false
    
    var selectNumber = 0
    
    let cellHeight = kScreenHeight - 7 * 44.0 - 64.0 - 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addObserver()
        createUI()
        initData()
        requestData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (eventType == .eventCustomer
            || eventType == .eventSudden
            || eventType == .warehouseIn
            || eventType == .warehouseOut
            || eventType == .customerComeIn
            || eventType == .customerIntent
            || eventType == .customerNeedInfo
            || eventType == .energyMeterUnit) {
            return titleNames.count;
        }
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (eventType == .eventCustomer
            || eventType == .eventSudden
            || eventType == .warehouseIn
            || eventType == .warehouseOut
            || eventType == .customerComeIn
            || eventType == .customerIntent
            || eventType == .customerNeedInfo
            || eventType == .energyMeterUnit) {
            if (eventType == .warehouseIn || eventType == .warehouseOut) {
                if (section == 2) {
                    return 1
                }
            }
            
            if eventType == .customerIntent {
                if section == 1 {
                    let count = (titleNames[section] as! NSArray).count;
                    let value = (customerUpdateYXKHInfoValues[section] as! NSArray)[count - 1] as? String
                    if value?.compare("") == .orderedSame || selectContentModel.customerIntentYXState?.compare("") == .orderedSame {
                        return count - 1
                    }
                }
            }
            return (titleNames[section] as! NSArray).count;
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((eventType == .warehouseIn || eventType == .warehouseOut) && indexPath.section == 2) {
            return cellHeight
        }
        if (eventType == .eventCustomer) {
            if (indexPath.row == 4) {
                return 115
            }
            return 44
        }else if (eventType == .customerComeIn) {
            if (eventType == .customerComeIn && (indexPath.section == 0 && indexPath.row == 4)) {
                return 115
            }
            return 44
        }else if (eventType == .customerNeedInfo) {
            if (indexPath.section == 0) {
                return 44
            }
            return 115
        }
        else {
            if (eventType == .eventSudden && indexPath.section == 1 && indexPath.row == 6) {
                return 115
            }
            return 44
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (eventType == .warehouseIn || eventType == .warehouseOut || eventType == .energyMeterUnit) {
            
            if (eventType == .energyMeterUnit) {
                return 40.0
            }
            
            if (section == 0) {
                return 10.0
            }
            return 40
        }
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (eventType == .warehouseIn
            || eventType == .warehouseOut
            || eventType == .energyMeterUnit) {
            
            let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
            let titleLable = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth - 100, height: 30))
            titleLable.font = UIFont.boldSystemFont(ofSize: 16)
            
            if (eventType == .energyMeterUnit) {
                if (section == 0) {
                    titleLable.text = "基本信息"
                }else {
                    titleLable.text = "本次操作"
                }
            }else {
                
                let scanButton = UIButton(frame: CGRect(x: kScreenWidth - 50, y: 0, width: 40, height: 40))
                scanButton.setImage(UIImage(named: "icon_sys_pressed"), for: .normal)
                scanButton.addTarget(self, action: #selector(inoutScan), for: .touchUpInside)
            
                if (section == 1) {
                    titleLable.text = "物品详情"
                }else if (section == 2) {
                    titleLable.text = "物品列表"
                    backView.addSubview(scanButton)
                }else if (section == 0) {
                    return nil
                }
                
            }
            
            backView.addSubview(titleLable)
            return backView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifierLabel = "CellIdentifierLabel"
        let cellIdentifierInput = "CellIdentifierInput"
        let cellIdentifierChoose = "CellIdentifierChoose"
        let cellIdentifierTextView = "CellIdentifierTextView"
        let cellIdentifierWareHourseSelectGoods = "CellIdentifierWareHourseSelectGoods"
        let cellIdentifierWarehouseInNumber = "CellIdentifierWarehouseInNumber"
        
        if (eventType == .eventCustomer && indexPath.row != 4) {
            
            if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3) {
                let cellIdentifier = cellIdentifierChoose
                var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
                
                if materialDataInfoDetailTableViewCell == nil {
                    
                    materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
                    materialDataInfoDetailTableViewCell?.selectionStyle = .none
                }
                
                let tempCell: MaterialDataInfoDetailTableViewCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
                tempCell.nameLabel.isUserInteractionEnabled = false;
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                
                if (indexPath.row == 0) {
                    tempCell.contentLabel.text = addCustomerEventModel.Address
                }else if (indexPath.row == 2) {
                    tempCell.contentLabel.text = addCustomerEventModel.EvetnDate
                }else {
                    tempCell.contentLabel.text = selectContentModel.eventCustomerContent
                }
                
                return materialDataInfoDetailTableViewCell!
            }else if (indexPath.row == 1) {
                let cellID = cellIdentifierInput
                var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellID)
                if textFiledTableViewCell == nil {
                    textFiledTableViewCell = Bundle.main.loadNibNamed("LSTextFiledTableViewCell", owner: nil, options: nil)?.first as! LSTextFiledTableViewCell
                    textFiledTableViewCell?.selectionStyle = .none
                    
                }
                
                let tempCell: LSTextFiledTableViewCell = textFiledTableViewCell as! LSTextFiledTableViewCell
                self.freshLSTextFiledTableViewCell(tempCell, indexPath: indexPath)
                tempCell.contentTextFiled.text = addCustomerEventModel.TenantName
                return textFiledTableViewCell!
            }
            
        }else if (eventType == .eventSudden && !(indexPath.section == 1 && indexPath.row == 6)) {
            
            if (indexPath.row == 0) {
                
                var titleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierLabel)
                if titleCell == nil {
                    titleCell = Bundle.main.loadNibNamed("LSLabelTableViewCell", owner: nil, options: nil)?.first as! LSLabelTableViewCell
                    titleCell?.selectionStyle = .none
                }
                
                let tempCell: LSLabelTableViewCell = titleCell as! LSLabelTableViewCell
                tempCell.contentLabel.font = UIFont.boldSystemFont(ofSize: 15)
                
                tempCell.contentLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                return titleCell!
            }
            
            if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2))
                || indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)) {
                
                var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierChoose)
                
                if materialDataInfoDetailTableViewCell == nil {
                    
                    materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
                    materialDataInfoDetailTableViewCell?.selectionStyle = .none
                }
                
                let tempCell: MaterialDataInfoDetailTableViewCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                if (indexPath.section == 0) {
                    switch indexPath.row {
                    case 1:
                        tempCell.contentLabel.text = selectContentModel.eventSuddenCategory
                    case 2:
                        tempCell.contentLabel.text = selectContentModel.eventSuddenLevel
                    default:
                        tempCell.contentLabel.text = ""
                    }
                }else if (indexPath.section == 1) {
                    switch indexPath.row {
                    case 1:
                        tempCell.contentLabel.text = selectContentModel.eventOrganizename
                        tempCell.contentLabel.numberOfLines = 0
                    case 2:
                        tempCell.contentLabel.text = addSuddenEventModel.EventDate
                    case 3:
                        tempCell.contentLabel.text = addSuddenEventModel.SpecificTime
                    default:
                        tempCell.contentLabel.text = ""
                    }
                }
                return materialDataInfoDetailTableViewCell!
                
            }
            else {
                
                var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierInput)
                if textFiledTableViewCell == nil {
                    textFiledTableViewCell = Bundle.main.loadNibNamed("LSTextFiledTableViewCell", owner: nil, options: nil)?.first as! LSTextFiledTableViewCell
                    textFiledTableViewCell?.selectionStyle = .none
                    
                }
                
                let tempCell: LSTextFiledTableViewCell = textFiledTableViewCell as! LSTextFiledTableViewCell
                self.freshLSTextFiledTableViewCell(tempCell, indexPath: indexPath)
                
                if indexPath.section == 2 {
                    if (indexPath.row == 1) {
                        tempCell.contentTextFiled.keyboardType = .numberPad
                    }else if (indexPath.row == 2){
                        tempCell.contentTextFiled.keyboardType = .decimalPad
                    }
                }
                
                if (eventSuddenIsModify) {
                    tempCell.contentTextFiled.isUserInteractionEnabled = false
                }
                
                if (indexPath.section == 1) {
                    switch indexPath.row {
                    case 4:
                        tempCell.contentTextFiled.text = addSuddenEventModel.Address
                    case 5:
                        tempCell.contentTextFiled.text = addSuddenEventModel.RelatedPersonnel
                    default:
                        tempCell.contentTextFiled.text = ""
                    }
                }else if (indexPath.section == 2) {
                    switch indexPath.row {
                    case 1:
                        tempCell.contentTextFiled.text = addSuddenEventModel.Casualties
                    case 2:
                        tempCell.contentTextFiled.text = addSuddenEventModel.PropertyLoss
                    default:
                        tempCell.contentTextFiled.text = ""
                    }
                }
                
                return textFiledTableViewCell!
            }
        }else if (eventType == .warehouseIn
            || eventType == .warehouseOut) {
            //出仓入仓
            if (indexPath.section == 0) {
                var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierChoose)
                
                if materialDataInfoDetailTableViewCell == nil {
                    
                    materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
                    materialDataInfoDetailTableViewCell?.selectionStyle = .none
                }
                
                let tempCell: MaterialDataInfoDetailTableViewCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                if (indexPath.row == 0) {
                    tempCell.contentLabel.text = selectContentModel.warehouseChooseInfo
                }else {
                    tempCell.contentLabel.text = selectContentModel.warehouseType
                }
                return materialDataInfoDetailTableViewCell!
            }else if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    //WarehouseSelectGoodsTableViewCell
                    var warehouseSelectGoodsTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierWareHourseSelectGoods)
                    
                    if warehouseSelectGoodsTableViewCell == nil {
                        
                        warehouseSelectGoodsTableViewCell = Bundle.main.loadNibNamed("WarehouseSelectGoodsTableViewCell", owner: nil, options: nil)?.first as! WarehouseSelectGoodsTableViewCell
                        warehouseSelectGoodsTableViewCell?.selectionStyle = .none
                    }
                    
                    let tempCell: WarehouseSelectGoodsTableViewCell = warehouseSelectGoodsTableViewCell as! WarehouseSelectGoodsTableViewCell
                    tempCell.contentTextField.text = wareHouseGoodDictionary.object(forKey: "Code") as? String
                    tempCell.loadData()
                    tempCell.warehouseSelectGoodDelegate = self
                    
                    return warehouseSelectGoodsTableViewCell!
                }else if (indexPath.row == 1
                    || indexPath.row == 2) {
                    
                    if (eventType == .warehouseIn && indexPath.row == 2) {
                        //WarehouseInNumberTableViewCell
                        var warehouseInNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierWarehouseInNumber)
                        
                        if warehouseInNumberTableViewCell == nil {
                            
                            warehouseInNumberTableViewCell = Bundle.main.loadNibNamed("WarehouseInNumberTableViewCell", owner: nil, options: nil)?.first as! WarehouseInNumberTableViewCell
                            warehouseInNumberTableViewCell?.selectionStyle = .none
                        }
                        
                        let tempCell: WarehouseInNumberTableViewCell = warehouseInNumberTableViewCell as! WarehouseInNumberTableViewCell
                        tempCell.priceTextField.text = wareHouseGoodDictionary.object(forKey: "Price") as? String
                        tempCell.numberTextField.text = wareHouseGoodDictionary.object(forKey: "Num") as? String
//                        tempCell.priceTextField.inputAccessoryView = BaseTool.addBar(withTarget: self, action: #selector(EventAddViewController.tap))
//                        tempCell.numberTextField.inputAccessoryView = BaseTool.addBar(withTarget: self, action: #selector(EventAddViewController.tap))
                        tempCell.priceTextField.keyboardType = .decimalPad
                        tempCell.numberTextField.keyboardType = .numberPad
                        tempCell.loadData()
                        tempCell.warehouseInNumberDelegate = self
                        return warehouseInNumberTableViewCell!
                    }
                    
                    var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierInput)
                    if textFiledTableViewCell == nil {
                        textFiledTableViewCell = Bundle.main.loadNibNamed("WarehouseInInputTableViewCell", owner: nil, options: nil)?.first as! WarehouseInInputTableViewCell
                        textFiledTableViewCell?.selectionStyle = .none
                        
                    }
                    
                    let tempCell: WarehouseInInputTableViewCell = textFiledTableViewCell as! WarehouseInInputTableViewCell
                    if (indexPath.row == 1) {
                        tempCell.nameLabel.text = "名称"
                        tempCell.contentTextField.text = wareHouseGoodDictionary.object(forKey: "Name") as? String
                        tempCell.contentTextField.isUserInteractionEnabled = false
                    }else {
                        tempCell.nameLabel.text = "数量"
                        tempCell.contentTextField.text = wareHouseGoodDictionary.object(forKey: "Num") as? String
//                        tempCell.contentTextField.inputAccessoryView = BaseTool.addBar(withTarget: self, action: #selector(EventAddViewController.tap))
                        tempCell.contentTextField.keyboardType = .numberPad
                        tempCell.contentTextField.isUserInteractionEnabled = true
                        tempCell.loadData()
                        tempCell.warehouseInInputDelegate = self
                        
                    }
                    return textFiledTableViewCell!
                }
                
            }//物品列表
            else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NormalCellID")
                
                if cell == nil {
                    
                    cell = UITableViewCell(style: .default, reuseIdentifier: "NormalCellID")
                    cell?.selectionStyle = .none
                    cell?.backgroundColor = UIColor.clear
                    let wareHouseView = WarehouseInOutContentView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: cellHeight))
                    wareHouseView?.tag = 7531
                    wareHouseView?.delegate = self
                    cell?.contentView.addSubview(wareHouseView!)
                    
                }
                let wareHouse = cell?.contentView.viewWithTag(7531) as! WarehouseInOutContentView
                wareHouse.reloadData(withDataSource: wareHouseGoods)
                
                return cell!
            }
        }else if (eventType == .customerIntent) {
            
            let count = (titleNames[indexPath.section] as! NSArray).count
            
            if ((indexPath.section == 0 && (indexPath.row == count - 1 || indexPath.row == count - 2))
                || indexPath.section == 1) {
                
                var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierChoose)
                
                if materialDataInfoDetailTableViewCell == nil {
                    
                    materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
                    materialDataInfoDetailTableViewCell?.selectionStyle = .none
                }
                
                let tempCell: MaterialDataInfoDetailTableViewCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                tempCell.nameLabel.numberOfLines = 0
                tempCell.contentLabel.text = (customerUpdateYXKHInfoValues[indexPath.section] as! NSArray)[indexPath.row] as? String
                if (indexPath.section == 0 && indexPath.row == 6) {
                    tempCell.contentLabel.text = selectContentModel.customerIntentLinkPosition
                }else if (indexPath.section == 0 && indexPath.row == 7) {
                    tempCell.contentLabel.text = selectContentModel.customerIntentSource
                }else if (indexPath.section == 1 && indexPath.row == 2) {
                    tempCell.contentLabel.text = selectContentModel.customerIntentDateType
                }else if (indexPath.section == 1 && indexPath.row == 3) {
                    tempCell.contentLabel.text = selectContentModel.customerIntentGJState
                }else if (indexPath.section == 1 && indexPath.row == 4) {
                    tempCell.contentLabel.text = selectContentModel.customerIntentYXState
                }
                else if (indexPath.section == 1 && indexPath.row == 1) {
                    tempCell.contentLabel.text = addUpdateYXKHInfoModel.FirstDate ?? ""
                }
                return materialDataInfoDetailTableViewCell!
                
            }else {
                
                var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierInput)
                if textFiledTableViewCell == nil {
                    textFiledTableViewCell = Bundle.main.loadNibNamed("LSTextFiledTableViewCell", owner: nil, options: nil)?.first as! LSTextFiledTableViewCell
                    textFiledTableViewCell?.selectionStyle = .none
                    
                }
                
                let tempCell: LSTextFiledTableViewCell = textFiledTableViewCell as! LSTextFiledTableViewCell
                self.freshLSTextFiledTableViewCell(tempCell, indexPath: indexPath)
                tempCell.contentTextFiled.text = (customerUpdateYXKHInfoValues[indexPath.section] as! NSArray)[indexPath.row] as? String
                if indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3) {
                    tempCell.contentTextFiled.keyboardType = .numberPad
                }else if indexPath.section == 0 && indexPath.row == 4 {
                    tempCell.contentTextFiled.keyboardType = .emailAddress
                }
                return textFiledTableViewCell!
            }
            
        }else if (eventType == .customerComeIn && !(indexPath.section == 0 && indexPath.row == 4)) {
            //跟进
            if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)) || (indexPath.section == 1)) {
                
                var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierChoose)
                
                if materialDataInfoDetailTableViewCell == nil {
                    
                    materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
                    materialDataInfoDetailTableViewCell?.selectionStyle = .none
                }
                
                let tempCell: MaterialDataInfoDetailTableViewCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                if (indexPath.section == 1 && indexPath.row == 0) {
                    if (BaseTool.toStr(addCustomerComeInModel.IsContinue).compare("1") == .orderedSame) {
                        tempCell.contentLabel.text = "是"
                    }else {
                        tempCell.contentLabel.text = "否"
                    }
                }else if (indexPath.row == 1) {
                    tempCell.contentLabel.text = addCustomerComeInModel.Date
                }else if (indexPath.row == 2) {
                    tempCell.contentLabel.text = selectContentModel.customerComeInWay
                }else if (indexPath.row == 3) {
                    tempCell.contentLabel.text = selectContentModel.customerComeInWant
                }
                return materialDataInfoDetailTableViewCell!
            }else {
                
                var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierInput)
                if textFiledTableViewCell == nil {
                    textFiledTableViewCell = Bundle.main.loadNibNamed("LSTextFiledTableViewCell", owner: nil, options: nil)?.first as! LSTextFiledTableViewCell
                    textFiledTableViewCell?.selectionStyle = .none
                    
                }
                
                let tempCell: LSTextFiledTableViewCell = textFiledTableViewCell as! LSTextFiledTableViewCell
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                tempCell.contentTextFiled.text = addCustomerComeInModel.CName
                tempCell.contentTextFiled.isUserInteractionEnabled = false
                return textFiledTableViewCell!
            }
        }else if (eventType == .customerNeedInfo && indexPath.section != 1) {
            if (indexPath.section == 0) {
                
                var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierInput)
                if textFiledTableViewCell == nil {
                    textFiledTableViewCell = Bundle.main.loadNibNamed("LSTextFiledTableViewCell", owner: nil, options: nil)?.first as! LSTextFiledTableViewCell
                    textFiledTableViewCell?.selectionStyle = .none
                    
                }
                
                let tempCell: LSTextFiledTableViewCell = textFiledTableViewCell as! LSTextFiledTableViewCell
                tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
                if (indexPath.row == 0) {
                    tempCell.contentTextFiled.text = addCustomerNeedInfoModel.CName
                }else if (indexPath.row == 1) {
                    tempCell.contentTextFiled.text = addCustomerNeedInfoModel.PhoneNum
                }else if (indexPath.row == 2) {
                    tempCell.contentTextFiled.text = addCustomerNeedInfoModel.TelNum
                }
                tempCell.contentTextFiled.isUserInteractionEnabled = false
                return textFiledTableViewCell!
            }
        }else if (eventType == .energyMeterUnit) {
            
            var textFiledTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierInput)
            if textFiledTableViewCell == nil {
                textFiledTableViewCell = Bundle.main.loadNibNamed("LSTextFiledTableViewCell", owner: nil, options: nil)?.first as! LSTextFiledTableViewCell
                textFiledTableViewCell?.selectionStyle = .none
                
            }
            
            let tempCell: LSTextFiledTableViewCell = textFiledTableViewCell as! LSTextFiledTableViewCell
            self.freshLSTextFiledTableViewCell(tempCell, indexPath: indexPath)
            tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
            tempCell.contentTextFiled.text = (energyMeterInfoValues[indexPath.section] as! NSArray)[indexPath.row] as? String
            if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 2)) {
                tempCell.contentTextFiled.isUserInteractionEnabled = false
            }else {
                if (indexPath.row == 0 || indexPath.row == 1) {
                    tempCell.contentTextFiled.keyboardType = .decimalPad
                }
                tempCell.contentTextFiled.isUserInteractionEnabled = true
            }
            return textFiledTableViewCell!
            
        }
        
        var contentInputTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierTextView)
        
        if contentInputTableViewCell == nil {
            contentInputTableViewCell = Bundle.main.loadNibNamed("LSContentInputTableViewCell", owner: nil, options: nil)?.first as! LSContentInputTableViewCell
            contentInputTableViewCell?.selectionStyle = .none
        }
        
        let tempCell: LSContentInputTableViewCell = contentInputTableViewCell as! LSContentInputTableViewCell
        
        if (eventType == .eventSudden) {
            tempCell.placeHolderLabel.text = "事件摘要"
        }else if (eventType == .customerComeIn) {
            tempCell.placeHolderLabel.text = "跟进内容"
        }else if (eventType == .eventCustomer) {
            tempCell.placeHolderLabel.text = "事件说明"
        }else if (eventType == .customerNeedInfo) {
            tempCell.placeHolderLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
        }
        
        tempCell.loadData()
        tempCell.contentTextView.tag = indexPath.section * 1000 + indexPath.row
        tempCell.contentInputTextViewDelegate = self
//        tempCell.contentTextView.inputAccessoryView = BaseTool.addBar(withTarget: self, action: #selector(EventAddViewController.tap))
        
        if (eventType == .eventSudden) {
            tempCell.contentTextView.text = addSuddenEventModel.EvetSummary
            if eventSuddenIsModify {
                tempCell.contentTextView.isUserInteractionEnabled = false
            }
            
        }else if (eventType == .customerComeIn && customerComeInIsModify) {
            tempCell.contentTextView.text = addCustomerComeInModel.Content
        }else if (eventType == .customerNeedInfo) {
            tempCell.contentTextView.text = customerNeedInfoValues[indexPath.row] as! String
        }else {
            tempCell.contentTextView.text = addCustomerEventModel.Content
        }
        
        tempCell.textViewDidChange(tempCell.contentTextView)
        
        return contentInputTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.view.endEditing(true)
        
        if (eventType == .eventCustomer) {
            
            if (indexPath.row == 2) {
                
                let dateStr = addCustomerEventModel.EvetnDate?.components(separatedBy: "T").joined(separator: " ")
                
                let lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日"], scrollDate: dateStr)
                lSDatePicker?.delegate = self
                lSDatePicker?.setHintsText("选择日期")
                lSDatePicker?.showView(inSelect: self.view)
                
            }else if (indexPath.row == 0) {
                //跳转选择业户
                let customerInfoVC = CustomerInfoViewController()
                customerInfoVC.isTopLevelShow = true
                customerInfoVC.customerInfoType = .customerEvent
                customerInfoVC.delegate = self
                self.navigationController?.pushViewController(customerInfoVC, animated: true)
            }else if (indexPath.row == 3) {
                if (self.wayArray.count != 0) {
                    showActionSheet(title: "选择事件类别", cancelTitle: "取消", titles: (self.wayArray as NSArray) as! [Any], tag: "Category")
                }
                
            }
            
        }else if (eventType == .customerComeIn) {
            
            if (indexPath.section == 0 && indexPath.row == 1) {
                
                let dateStr = addCustomerComeInModel.Date?.components(separatedBy: "T").joined(separator: " ")
                
                let lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日","时","分","秒"], scrollDate: dateStr)
                lSDatePicker?.delegate = self
                lSDatePicker?.setHintsText("选择日期")
                lSDatePicker?.showView(inSelect: self.view)
            }else if (indexPath.section == 1 && indexPath.row == 0) {
                showActionSheet(title: "是否需要继续跟进?", cancelTitle: "取消", titles: ["是","否"], tag: "CustomerComeInIsContinue")
            }else if (indexPath.row == 2) {
                if (self.wayArray.count != 0) {
                    showActionSheet(title: "跟进方式", cancelTitle: "取消", titles: (self.wayArray as NSArray) as! [Any], tag: "CustomerComeInWay")
                }
            }else if (indexPath.row == 3) {
                if (self.wayIntentArray.count != 0) {
                    showActionSheet(title: "意向状态", cancelTitle: "取消", titles: (self.wayIntentArray as NSArray) as! [Any], tag: "CustomerComeInIntentionState")
                }
            }
            
        }else if (eventType == .eventSudden) {
            if (indexPath.section == 0) {
                if (indexPath.row == 1) {
                    if (self.wayArray.count != 0) {
                        showActionSheet(title: "选择事件种类", cancelTitle: "取消", titles: (self.wayArray as NSArray) as! [Any], tag: "SuddenCategory")
                    }
                }else if (indexPath.row == 2) {
                    if (self.waySuddenArray.count != 0) {
                        showActionSheet(title: "选择事件级别", cancelTitle: "取消", titles: (self.waySuddenArray as NSArray) as! [Any], tag: "SuddenLevelCategory")
                    }
                }
            }else if (indexPath.section == 1) {
                if (indexPath.row == 2 || indexPath.row == 3) {
                    
                    let formatter = DateFormatter()
                    if (indexPath.row == 2 && addSuddenEventModel.EventDate?.compare("") == .orderedSame) {
                        formatter.dateFormat = "yyyy-MM-dd"
                        addSuddenEventModel.EventDate = formatter.string(from: NSDate() as Date)
                    }
                    
                    if (indexPath.row == 3 && addSuddenEventModel.SpecificTime?.compare("") == .orderedSame) {
                        formatter.dateFormat = "HH:ss:mm"
                        addSuddenEventModel.SpecificTime = formatter.string(from: NSDate() as Date)
                    }
                    

                    var lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日"], scrollDate: addSuddenEventModel.EventDate)
                    if (indexPath.row == 3) {
                        lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["时","分","秒"], scrollDate: addSuddenEventModel.SpecificTime)
                    }
                    lSDatePicker?.tag = indexPath.row
                    lSDatePicker?.delegate = self
                    lSDatePicker?.setHintsText("选择日期")
                    lSDatePicker?.showView(inSelect: self.view)
                    
                }else if (indexPath.row == 1) {
                    //相关部门
                    let infoSelect = InfoSelectViewController()
                    infoSelect.infoSelectType = .partment
                    infoSelect.infoSelectDelegate = self
                    self.push(viewController: infoSelect)
                }
            }
        }else if (eventType == .customerIntent) {
            
            self.wayArray.removeAllObjects()
            self.waySourceArray.removeAllObjects()
            
            var title = ""
            var tag = ""
            
            if (indexPath.section == 0) {
                var criteria =  ""
                switch indexPath.row {
                case 6:
                    title = "选择联系人职务"
                    tag = "CustomerIntentLinkPosition"
                    criteria = criteria.appending(" WHERE Type = '招商管理_联系人职务'")
                case 7:
                    title = "选择信息来源"
                    tag = "CustomerIntentSource"
                    criteria = criteria.appending(" WHERE Type = '信息来源'")
                default:
                    break
                }
                
                if (criteria.compare("") != .orderedSame) {
                    for model in GetDictionaryInfosModel.find(byCriteria:  criteria) {
                        
                        let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                        self.waySourceArray.add(getDictionaryInfosModel)
                        self.wayArray.add(getDictionaryInfosModel.Content ?? "")
                    }
                }
            }
            else if (indexPath.section == 1) {
                
                switch indexPath.row {
                case 0:
                    
                    title = "选择招商人员"
                    tag = "CustomerIntentWorkerDataSource"
                    
                    var dataSource = WorkerDataModel.findAll()
                    
                    for model in dataSource! {
                        let tempModel = model as! WorkerDataModel
                        if (tempModel.role?.compare("招商") == .orderedSame) {
                            self.wayArray.add(tempModel.workername)
                            self.waySourceArray.add(tempModel)
                        }
                        
                    }
                    
                    break
                case 1:
                    let dateStr = addUpdateYXKHInfoModel.FirstDate?.components(separatedBy: "T").joined(separator: " ")
                    
                    let lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日"], scrollDate: dateStr)
                    lSDatePicker?.delegate = self
                    lSDatePicker?.setHintsText("选择日期")
                    lSDatePicker?.showView(inSelect: self.view)
                case 2:
                    //"来访","来电"
                    title = "选择初次到访方式"
                    tag = "CustomerIntentDateType"
                    self.wayArray = NSMutableArray(array: ["来访","来电"])
                    self.waySourceArray = NSMutableArray(array: ["来访","来电"])
                case 3:
                    title = "选择跟进状态"
                    tag = "CustomerIntentGJState"
                    //未跟进、已跟进、已认租、已签约、已退租
                    self.wayArray = NSMutableArray(array: ["未跟进","已跟进","已认租","已签约","已退租"])
                    self.waySourceArray = NSMutableArray(array: ["未跟进","已跟进","已认租","已签约","已退租"])
                case 4:
                    title = "选择意向状态"
                    tag = "YXState"
                    self.wayArray = NSMutableArray(array: ["低意向","高意向","中等意向","无意向"])
                    self.waySourceArray = NSMutableArray(array: ["低意向","高意向","中等意向","无意向"])
                default:
                    break
                }
                
            }
            
            if (self.wayArray.count != 0) {
                showActionSheet(title: title, cancelTitle: "取消", titles: (self.wayArray as NSArray) as! [Any], tag: tag)
            }
        }else if (eventType == .warehouseIn
            || eventType == .warehouseOut) {
            if (indexPath.section == 0) {
                
                self.wayArray.removeAllObjects()
                self.waySourceArray.removeAllObjects()
                
                var title = ""
                var tag = ""
                
                var criteria =  ""
                switch indexPath.row {
                case 0:
                    title = "选择仓库"
                    tag = "WarehouseChoose"
                    criteria = criteria.appending(" WHERE Type = '仓库信息'")
                case 1:
                    
                    tag = "WarehouseType"
                    if (eventType == .warehouseIn) {
                        title = "选择入仓类型"
                        criteria = criteria.appending(" WHERE Type = '入仓类别'")
                    }else {
                        title = "选择出仓类型"
                        criteria = criteria.appending(" WHERE Type = '出仓类别'")
                    }
                default:
                    break
                }
                
                if (criteria.compare("") != .orderedSame) {
                    for model in GetDictionaryInfosModel.find(byCriteria:  criteria) {
                        
                        let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                        self.waySourceArray.add(getDictionaryInfosModel)
                        self.wayArray.add(getDictionaryInfosModel.Content ?? "")
                    }
                }
                
                if (self.wayArray.count != 0) {
                    showActionSheet(title: title, cancelTitle: "取消", titles: (self.wayArray as NSArray) as! [Any], tag: tag)
                }

            }
        }
    }
    
    //MARK: CustomerInfoDelegate
    
    func confirmWithObject(object: AnyObject) {
        
        if (object.isKind(of: HouseStructureModel.self)) {
            //联系人model
            let tempModel = (object as? HouseStructureModel)!
            
            if tempModel.TenantName?.compare("") == .orderedSame {
                //如果没有业主
                LocalToastView.toast(text: ("房间[".appending(houseStructureModel.Name!)).appending("]没有业主"))
            }else {
                houseStructureModel = (object as? HouseStructureModel)!
            }
        }
        
    }
    
    func confirmWithAddress(address: NSString, pcode: NSString, bcode: NSString, fname: NSString, rcode: NSString, ownerCode: NSString) {
        print("\(pcode)  \(bcode)  \(rcode)  \(ownerCode)  \(address)  \(address)")
        if houseStructureModel.TenantName?.compare("") != .orderedSame {
            customerAddress = NSString(string: address) as String
            addCustomerEventModel.TenantName = houseStructureModel.TenantName
            addCustomerEventModel.Address = customerAddress
            addCustomerEventModel.PRoomCode = houseStructureModel.Code
            addCustomerEventModel.TenantCode = houseStructureModel.TenantCode
        }
        self.contentTableView?.reloadData()
    }
    
    //MARK: LSTextFiledDelegate
    
    func lSTextFiledDidChange(_ textField: UITextField) {
        let section = textField.tag / 1000
        let row = textField.tag % 1000
        if (eventType == .eventSudden) {
            if (section == 1) {
                if (row == 4) {
                    addSuddenEventModel.Address = textField.text
                }else if (row == 5) {
                    addSuddenEventModel.RelatedPersonnel = textField.text
                }
            }else if (section == 2) {
                if (row == 1) {
                    addSuddenEventModel.Casualties = textField.text
                }else if (row == 2) {
                    addSuddenEventModel.PropertyLoss = textField.text
                }
            }
        }else if (eventType == .customerIntent) {
            let tempArray: NSMutableArray = NSMutableArray(array: customerUpdateYXKHInfoValues[section] as! NSArray)
            tempArray[row] = textField.text ?? ""
            self.customerUpdateYXKHInfoValues[section] = tempArray
            switch row {
            case 0:
                addUpdateYXKHInfoModel.CName = textField.text
            case 1:
                addUpdateYXKHInfoModel.CNamejc = textField.text
            case 2:
                addUpdateYXKHInfoModel.PhoneNum = textField.text
            case 3:
                addUpdateYXKHInfoModel.TelNum = textField.text
            case 4:
                addUpdateYXKHInfoModel.Email = textField.text
            case 5:
                addUpdateYXKHInfoModel.LinkName = textField.text
            default:
                break;
            }
        }else if (eventType == .energyMeterUnit) {
            if (row == 3) {
                energyMeterReadingModel.Memo = textField.text
            } else if (row == 1) {
                energyMeterReadingModel.QuantityAdjust = textField.text
            }
            else {
                energyMeterReadingModel.CurDegree = textField.text
            }
            energyMeterInfoValues = NSMutableArray(array: DataInfoDetailManager.shareInstance().dealEnergyMeterReading(withModel: energyMeterReadingModel))
        }
    }
    
    func lSTextFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: self.getHeight(textField.tag))
    }
    
    func lSTextFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: self.getHeight(textField.tag))
    }
    
    //MARK: LSContentInputTextViewDelegate
    
    func lStextViewDidChange(_ textView: UITextView) {
        if (eventType == .eventCustomer) {
            addCustomerEventModel.Content = textView.text
        }else if (eventType == .eventSudden) {
            addSuddenEventModel.EvetSummary = textView.text
        }else if (eventType == .customerComeIn) {
            addCustomerComeInModel.Content = textView.text
        }else if (eventType == .customerNeedInfo) {
            let row = textView.tag % 1000
            customerNeedInfoValues[row] = textView.text
            switch row {
            case 0:
                updateCustomerNeedInfoModel.Requirement = textView.text
            case 1:
                updateCustomerNeedInfoModel.Suggest = textView.text
            case 2:
                updateCustomerNeedInfoModel.Hinder = textView.text
            case 3:
                updateCustomerNeedInfoModel.Favorable = textView.text
            case 4:
                updateCustomerNeedInfoModel.Description = textView.text
            case 5:
                updateCustomerNeedInfoModel.Remarks = textView.text
            default:
                break
            }
        }
    }
    
    func lSTextViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: self.getHeight(textView.tag))
    }
    
    func lSTextViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(up: true, moveValue: self.getHeight(textView.tag))
    }
    
    //MARK: DatePickerDelegate
    
    func cancelButtonClick() {
        
    }
    
    func resetButtonClick(withDataPicker picker: LSDatePicker!) {
        addCustomerEventModel.EvetnDate = ""
        addUpdateYXKHInfoModel.FirstDate = ""
        if (picker.tag == 3) {
            addSuddenEventModel.SpecificTime = ""
        }else {
            addSuddenEventModel.EventDate = ""
        }
        self.contentTableView?.reloadData()
    }
    
    func datePickerDelegateEnterAction(withDataPicker picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue)
        let minValue = String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        addCustomerEventModel.EvetnDate = value
        addUpdateYXKHInfoModel.FirstDate = value
        if (picker.tag == 3) {
            addSuddenEventModel.SpecificTime = minValue
        }else {
            addSuddenEventModel.EventDate = value
        }
    
        self.contentTableView?.reloadData()
        
    }
    
    //MARK:ActionSheet
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            
            if (eventType == .eventSudden && tag.compare("UpData") == .orderedSame) {
                self.addSuddenEventModel.commitStatus = "1"
                self.addSuddenEventModel.saveOrUpdate()
            }
            
            
            return
        }
        
        if (eventType == .eventCustomer) {
            if (tag.compare("Category") == .orderedSame) {
                
                let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addCustomerEventModel.EvetnTypeId = model.Id
                selectContentModel.eventCustomerContent = model.Content
            }
        }else if (eventType == .eventSudden) {
            
        
            if (tag.compare("SuddenCategory") == .orderedSame) {
                let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addSuddenEventModel.EventTypeName = model.Id
                selectContentModel.eventSuddenCategory = model.Content

            }else if (tag.compare("SuddenLevelCategory") == .orderedSame) {
                let model = self.waySuddenSourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addSuddenEventModel.EventLevelName = model.Id
                selectContentModel.eventSuddenLevel = model.Content
            }else if (tag.compare("UpData") == .orderedSame) {
                
                let choose = RepairChooseSenderViewController()
                choose.delegate = self
                
                choose.accountCode = loginInfo?.accountCode ?? ""
                choose.upk = userInfo?.upk ?? ""
                choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
                choose.chooseType = "11"
                choose.updataType = "2"
                choose.eventCode = addSuddenEventModel.code
                
                if (buttonIndex == 1) {
                    //直接上报主管
                    choose.updataType = "1"
                    choose.commitDirect()
                    return;
                }
                
                
                self.pushNormalViewController(viewController: choose)
            }
        }else if (eventType == .customerComeIn) {
            if (tag.compare("CustomerComeInWay") == .orderedSame) {
                let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addCustomerComeInModel.Way = model.Id
                selectContentModel.customerComeInWay = model.Content
            }else if (tag.compare("CustomerComeInIntentionState") == .orderedSame) {
                let model = self.wayIntentSourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addCustomerComeInModel.IntentionState = model.Id
                selectContentModel.customerComeInWant = model.Content
            }else if (tag.compare("CustomerComeInIsContinue") == .orderedSame) {
                if (buttonIndex == 1) {
                    addCustomerComeInModel.IsContinue = "1"
                }else {
                    addCustomerComeInModel.IsContinue = "0"
                }
            }
        }else if (eventType == .customerIntent) {
            if (tag.compare("CustomerIntentLinkPosition") == .orderedSame) {
                let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addUpdateYXKHInfoModel.LinkPosition = model.Id
                selectContentModel.customerIntentLinkPosition = model.Content
            }else if (tag.compare("CustomerIntentSource") == .orderedSame) {
                let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                addUpdateYXKHInfoModel.Source = model.Id
                selectContentModel.customerIntentSource = model.Content
            }else if (tag.compare("CustomerIntentDateType") == .orderedSame) {
                let dateType = self.waySourceArray[buttonIndex - 1] as! String
                addUpdateYXKHInfoModel.DateType = dateType
                selectContentModel.customerIntentDateType = dateType
            }else if (tag.compare("CustomerIntentGJState") == .orderedSame) {
                let gJState = self.waySourceArray[buttonIndex - 1] as! String
                addUpdateYXKHInfoModel.GJState = gJState
                selectContentModel.customerIntentGJState = gJState
            }else if (tag.compare("CustomerIntentWorkerDataSource") == .orderedSame) {
                let model = self.waySourceArray[buttonIndex - 1] as! WorkerDataModel
                addUpdateYXKHInfoModel.ZSPerson = model.workername
            }else if (tag.compare("YXState") == .orderedSame) {
                let yXState = self.waySourceArray[buttonIndex - 1] as! String
                addUpdateYXKHInfoModel.YXState = yXState
                selectContentModel.customerIntentYXState = yXState
            }
            
            
            if (self.addUpdateYXKHInfoModel.GJState?.compare("已跟进") != .orderedSame) {
                selectContentModel.customerIntentYXState = ""
            }else {
                if !customerIntentInfoIsModify {
                    self.addUpdateYXKHInfoModel.YXState = "低意向"
                }
                
                selectContentModel.customerIntentYXState = self.addUpdateYXKHInfoModel.YXState
                
            }
            self.customerUpdateYXKHInfoValues = NSMutableArray(array: DataInfoDetailManager.shareInstance().customerUpdateYXKHInfoValues(withData: self.addUpdateYXKHInfoModel))
        }else if (eventType == .warehouseIn || eventType == .warehouseOut) {
            
            let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
            if (tag.compare("WarehouseChoose") == .orderedSame) {
                //仓库类型
                warehouseInOutListModel.WarehouseID = model.Id
                selectContentModel.warehouseChooseInfo = model.Content
            }else if (tag.compare("WarehouseType") == .orderedSame) {
                //入仓出仓类型
                warehouseInOutListModel.WarehouseWarrantType = model.Id
                selectContentModel.warehouseType = model.Content
            }
        }
        
        self.contentTableView?.reloadData()
    }
    
    //MARK: InfoSelectDelegate
    func infoSuddenEventSelectItem(_ model: OrganizeDataModel, item: String) {
        addSuddenEventModel.organizepk = model.organizepk
        addSuddenEventModel.eventOrganizename = item
        selectContentModel.eventOrganizename = item.appending(model.organizename ?? "")
        self.contentTableView?.reloadData()
    }
    
    //MARK: RepairChooseSenderResultDelegate
    func popAction(_ result: String!) {
        pop()
    }
    
    func popCurrentPageAction(_ result: String!) {
        
        LocalToastView.toast(text: "上报成功！")
        self.addSuddenEventModel.deleteObject()
        let childs = self.navigationController?.childViewControllers
        self.navigationController?.popToViewController((childs?[(childs?.count)! - 2])!, animated: true)
    }
    
    //MARK: WarehouseSelectGoodDelegate
    func selectButtonWithContent(_ content: String) {
        
        if (content.compare("") == .orderedSame) {
            LocalToastView.toast(text: "编号不可为空！")
            return
        }
        
        //查找对应物品
        var isExist = false
        var existModel = WarehouseInOutGoodsModel()
        for model in WarehouseInOutGoodsModel.findAll() {
            let tempModel: WarehouseInOutGoodsModel = model as! WarehouseInOutGoodsModel
            if (content.compare(tempModel.Code!) == .orderedSame) {
                //存在物品
                existModel = tempModel
                isExist = true
                break
            }
        }
        
        if (!isExist) {
            LocalToastView.toast(text: "没有对应的物品")
            return
        }
        
        if (eventType == .warehouseIn) {
            wareHouseGoodDictionary.setValue(existModel.Code, forKey: "Code")
            wareHouseGoodDictionary.setValue(existModel.Name, forKey: "Name")
            wareHouseGoodDictionary.setValue(existModel.Id, forKey: "Id")
        }else if (eventType == .warehouseOut) {
            wareHouseGoodDictionary.setValue(existModel.Code, forKey: "Code")
            wareHouseGoodDictionary.setValue(existModel.Name, forKey: "Name")
            wareHouseGoodDictionary.setValue(existModel.Id, forKey: "Id")
        }
        
        wareHouseGoodDictionary.setValue("", forKey: "Num")
        wareHouseGoodDictionary.setValue("", forKey: "Price")
        
        self.contentTableView?.reloadData()
        
        buttonAction(titles: ["返回","添加"], actions: [#selector(pop),#selector(commit)], target: self)
    }
    
    //MARK: WarehouseInNumberDelegate
    func warehouseInNumberTextFiledDidChange(_ textField: UITextField, tag: Int) {
        if (tag == 1) {
            wareHouseGoodDictionary.setValue(textField.text, forKey: "Num")
        }else {
            wareHouseGoodDictionary.setValue(textField.text, forKey: "Price")
        }
        wareHouseGoodDictionary = DataInfoDetailManager.shareInstance().dealWareHouseGoodDictionary(wareHouseGoodDictionary)
    }
    
    //MARK: WarehouseInInputDelegate
    func warehouseInInputTextFiledDidChange(_ textField: UITextField) {
        wareHouseGoodDictionary.setValue(textField.text, forKey: "Num")
    }
    
    //MARK: WarehouseInOutDelegate
    func subTableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath!) {
        wareHouseGoodDictionary = NSMutableDictionary(dictionary: wareHouseGoods[indexPath.row] as! NSDictionary)
        buttonAction(titles: ["返回","更新"], actions: [#selector(pop),#selector(commit)], target: self)
        self.contentTableView?.reloadData()
    }
    
    //MARK: ScanResultDelegate
    func scan(result: String) {
        selectButtonWithContent(result)
    }
    
    //MARK: longPress
    func longPress(with index: Int) {
        selectNumber = index
        print(wareHouseGoods[selectNumber])
        let data = wareHouseGoods[selectNumber] as! NSDictionary
        let tip = "是否删除物品".appending("【").appending(data["Name"] as! String).appending("】")
        alert(title: "提示", message: tip as NSString, buttonAction: [#selector(EventAddViewController.goodsConfirm),#selector(EventAddViewController.continueCancel)], buttonNames: ["确认","返回"], type: 7777)
    }
    
    @objc func goodsDeleteConfirm() {
        warehouseInOutListModel.deleteObject()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goodsConfirm() {
        wareHouseGoods.removeObject(at: selectNumber)
        warehouseInOutListModel.ListItems = wareHouseGoods.yy_modelToJSONString()
        warehouseInOutListModel.saveOrUpdate()
        self.contentTableView?.reloadData()
    }
    
    func initData() {
        if (eventType == .eventSudden) {
            titleNames = [["事件分类","事件类别","事件级别"],["事件详情","相关部门","日期","时间","事发地点","相关人员","事件摘要"],["损失情况","人员伤亡","财务损失"]];
        }else if (eventType == .eventCustomer) {
            titleNames = [["客户房屋","业户名称","事件日期","事件类别","事件说明"]];
        }else if (eventType == .warehouseOut) {
            titleNames = [["仓库名称","出仓类型"],["编号","名称","数量"],[]];
        }else if (eventType == .warehouseIn) {
            titleNames = [["仓库名称","入仓类型"],["编号","名称","数量.单价"],[]];
        }else if (eventType == .customerIntent) {
            let comeIn = "意向状态"
            titleNames = [["客户姓名","客户简称","手机号码",
                           "联系电话","电子邮件","联系人姓名",
                           "联系人职务","信息来源"],
                          ["招商人员","初次到访日期","初次到访方式","跟进状态",comeIn]];
            
            
        }else if (eventType == .customerComeIn) {
            titleNames = [["客户名称","跟进时间","跟进方式","意向状态","跟进内容"],["继续跟进"]];
        }else if (eventType == .customerNeedInfo) {
            titleNames = [["客户姓名","手机号码","联系电话"],["需求说明","客户建议","招商障碍分析","优惠措施","客户描述","附加说明"]]
        }else if (eventType == .energyMeterUnit) {
            titleNames = [["表  名  称","表  编  号","表  地  址","表  种  类","表  倍  率","表  量  程","上次读数","抄表时间"],["本次读数","调整用量","本次用量","抄表备注"]]
        }
        
        if (eventType == .eventCustomer) {
            
            if (addCustomerEventModel.EvetnDate?.compare("") == .orderedSame) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                addCustomerEventModel.EvetnDate = formatter.string(from: NSDate() as Date)
            }
            
            for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '客户事件类别'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                if (eventCustomerIsModify && getDictionaryInfosModel.Id?.compare(addCustomerEventModel.EvetnTypeId!) == .orderedSame) {
                    //修改
                    selectContentModel.eventCustomerContent = getDictionaryInfosModel.Content
                }
                self.waySourceArray.add(getDictionaryInfosModel)
                self.wayArray.add(getDictionaryInfosModel.Content ?? "")
            }
        }else if (eventType == .eventSudden) {
            
            if (eventSuddenIsModify) {
                selectContentModel.eventOrganizename = addSuddenEventModel.eventOrganizename
            }
            
            for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '重大事件_级别'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                if (eventSuddenIsModify && getDictionaryInfosModel.Id?.compare(addSuddenEventModel.EventLevelName!) == .orderedSame) {
                    //修改
                    selectContentModel.eventSuddenLevel = getDictionaryInfosModel.Content
                }
                self.waySuddenSourceArray.add(getDictionaryInfosModel)
                self.waySuddenArray.add(getDictionaryInfosModel.Content ?? "")
            }
            
            for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '重大事件_类别'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                if (eventSuddenIsModify && getDictionaryInfosModel.Id?.compare(addSuddenEventModel.EventTypeName!) == .orderedSame) {
                    //修改
                    selectContentModel.eventSuddenCategory = getDictionaryInfosModel.Content
                }
                self.waySourceArray.add(getDictionaryInfosModel)
                self.wayArray.add(getDictionaryInfosModel.Content ?? "")
            }
            
        }else if (eventType == .customerComeIn) {
            
            //"招商管理_跟进方式","招商管理_客户意向状态"
            for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '招商管理_跟进方式'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                if (customerComeInIsModify && getDictionaryInfosModel.Id?.compare(addCustomerComeInModel.Way!) == .orderedSame) {
                    //修改
                    selectContentModel.customerComeInWay = getDictionaryInfosModel.Content
                }
                self.waySourceArray.add(getDictionaryInfosModel)
                self.wayArray.add(getDictionaryInfosModel.Content ?? "")
            }
            
            for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '招商管理_客户意向状态'") {
                
                let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                if (customerComeInIsModify && getDictionaryInfosModel.Id?.compare(addCustomerComeInModel.IntentionState!) == .orderedSame) {
                    //修改
                    selectContentModel.customerComeInWant = getDictionaryInfosModel.Content
                }
                self.wayIntentSourceArray.add(getDictionaryInfosModel)
                self.wayIntentArray.add(getDictionaryInfosModel.Content ?? "")
            }
            
            if (customerComeInIsModify) {
                
                if (selectContentModel.customerComeInWay?.compare("") == .orderedSame) {
                    selectContentModel.customerComeInWay = addCustomerComeInModel.Way
                }
                
                if (selectContentModel.customerComeInWant?.compare("") == .orderedSame) {
                    selectContentModel.customerComeInWant = addCustomerComeInModel.IntentionState
                }
            }
            
        }else if (eventType == .customerIntent) {
            //客户意向
            if (!customerIntentInfoIsModify) {
                //新增
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                addUpdateYXKHInfoModel.FirstDate = formatter.string(from: NSDate() as Date)
            }
            
            
            if (customerIntentInfoIsModify) {
                
                if (selectContentModel.customerIntentDateType?.compare("") == .orderedSame) {
                    selectContentModel.customerIntentDateType = addUpdateYXKHInfoModel.DateType
                }
                
                if (selectContentModel.customerIntentGJState?.compare("") == .orderedSame) {
                    selectContentModel.customerIntentGJState = addUpdateYXKHInfoModel.GJState
                }
                
                if (selectContentModel.customerIntentYXState?.compare("") == .orderedSame) {
                    selectContentModel.customerIntentYXState = addUpdateYXKHInfoModel.YXState
                }
                
                for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '信息来源'") {
                    
                    let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                    if (getDictionaryInfosModel.Id?.compare(addUpdateYXKHInfoModel.Source!) == .orderedSame) {
                        //修改
                        selectContentModel.customerIntentSource = getDictionaryInfosModel.Content
                    }
                }
                
                for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '招商管理_联系人职务'") {
                    
                    let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
                    if (getDictionaryInfosModel.Id?.compare(addUpdateYXKHInfoModel.LinkPosition!) == .orderedSame) {
                        //修改
                        selectContentModel.customerIntentLinkPosition = getDictionaryInfosModel.Content
                    }
                }
                
            }
            customerUpdateYXKHInfoValues = NSMutableArray(array: DataInfoDetailManager.shareInstance().customerUpdateYXKHInfoValues(withData: addUpdateYXKHInfoModel))
        }else if (eventType == .warehouseIn || eventType == .warehouseOut) {
            
            if (eventType == .warehouseIn) {
                warehouseInOutListModel.IsWarehouseRecepit = "1"
            }else {
                warehouseInOutListModel.IsWarehouseRecepit = "0"
            }
            
            if (wareHouseInfoIsModify) {
                wareHouseGoods = NSMutableArray(array: BaseTool.dictionary(withJsonString: warehouseInOutListModel.ListItems) as! NSArray)
                
                for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '仓库信息'") {
                    
                    let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                    if (getDictionaryInfosModel.Id?.compare(warehouseInOutListModel.WarehouseID!) == .orderedSame) {
                        selectContentModel.warehouseChooseInfo = getDictionaryInfosModel.Content
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
                    if (getDictionaryInfosModel.Id?.compare(warehouseInOutListModel.WarehouseWarrantType!) == .orderedSame) {
                        selectContentModel.warehouseType = getDictionaryInfosModel.Content
                        break;
                    }
                }
            }else {
                for tempModel in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '仓库信息'") {
                    
                    let getDictionaryInfosModel:GetDictionaryInfosModel = tempModel as! GetDictionaryInfosModel
                    selectContentModel.warehouseChooseInfo = getDictionaryInfosModel.Content
                    warehouseInOutListModel.WarehouseID = getDictionaryInfosModel.Id
                    
                    break
                }
            }
            
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }else if (eventType == .energyMeterUnit) {
            energyMeterInfoValues = NSMutableArray(array: DataInfoDetailManager.shareInstance().dealEnergyMeterReading(withModel: energyMeterReadingModel))
        }
        self.contentTableView?.reloadData()
    }
    
    /*
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    //键盘的出现
    func keyBoardWillShow(_ notification: Notification){
        
        let tuple = isAddAction()
        if (!tuple.1) {
            return
        }
        
        
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘的y偏移量
        let changeY = kbRect.origin.y - kScreenHeight
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        //界面偏移动画
        UIView.animate(withDuration: duration) {
            let bottomView = tuple.0
            bottomView?.frame = CGRect(x: 0, y: kScreenHeight - 50 - kbRect.height, width: kScreenWidth, height: 50)
        }
    }
    
    //键盘的隐藏
    func keyBoardWillHide(_ notification: Notification){
        
        let tuple = isAddAction()
        if (!tuple.1) {
            return
        }
        
        let kbInfo = notification.userInfo
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let changeY = kbRect.origin.y
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            let bottomView = tuple.0
            bottomView?.frame = CGRect(x: 0, y: kScreenHeight - 50, width: kScreenWidth, height: 50)
        }
    }
    */
    func isAddAction() -> (UIView?, Bool){
        
        let bottomView = self.view.viewWithTag(bottomActionTag)
        
        if (eventType != .warehouseIn && eventType != .warehouseOut) {
            return (bottomView, false)
        }
        
        for subView in (bottomView?.subviews)! {
            if subView.isKind(of: UIButton.self) {
                let button = subView as! UIButton
                if (button.titleLabel?.text?.compare("添加") == .orderedSame
                    || button.titleLabel?.text?.compare("更新") == .orderedSame) {
                    return (bottomView, true)
                }
                
            }
        }
        
        return (bottomView, false)
    }
    
    
    override func requestData() {
        super.requestData()
        
        if (eventType == .customerNeedInfo) {

            updateCustomerNeedInfoModel.CID = addCustomerNeedInfoModel.CID
            
            var request = XYCBaseRequest()
            if (customerNeedInfoIsModify) {
                request = UpdateVoiceInfoAPICmd()
                request.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","info":updateCustomerNeedInfoModel.yy_modelToJSONString() ?? ""]
            }else {
                request = QueryVoiceInfoAPICmd()
                request.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","CID":addCustomerNeedInfoModel.CID ?? ""]
            }
            
            LoadView.storeLabelText = "正在加载客户需求资料"
            
            request.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            
            request.loadView = LoadView()
            request.loadParentView = self.view
            request.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    if (self.customerNeedInfoIsModify) {
                        self.pop()
                    }else {
                        self.updateCustomerNeedInfoModel = CustomerNeedInfoModel.yy_model(withJSON: dict["info"].rawString() ?? {})!
                        self.customerNeedInfoValues.removeAllObjects()
                        self.customerNeedInfoValues.add(self.updateCustomerNeedInfoModel.Requirement ?? "")
                        self.customerNeedInfoValues.add(self.updateCustomerNeedInfoModel.Suggest ?? "")
                        self.customerNeedInfoValues.add(self.updateCustomerNeedInfoModel.Hinder ?? "")
                        self.customerNeedInfoValues.add(self.updateCustomerNeedInfoModel.Favorable ?? "")
                        self.customerNeedInfoValues.add(self.updateCustomerNeedInfoModel.Description ?? "")
                        self.customerNeedInfoValues.add(self.updateCustomerNeedInfoModel.Remarks ?? "")
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
        }else if (eventType == .customerIntent) {
            
            if (!customerIntentInfoIsModify) {
                return
            }
            
            LoadView.storeLabelText = "正在加载意向客户信息"
            
            let queryYXKHInfoAPICmd = QueryYXKHInfoAPICmd()
            queryYXKHInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            queryYXKHInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","CID":addUpdateYXKHInfoModel.CID ?? ""]
            queryYXKHInfoAPICmd.loadView = LoadView()
            queryYXKHInfoAPICmd.loadParentView = self.view
            queryYXKHInfoAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.addUpdateYXKHInfoModel = AddUpdateYXKHInfoModel.yy_model(withJSON: dict["info"].rawString() ?? {})!
                    self.initData()
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
        }
        
    }
    
    func freshLSTextFiledTableViewCell (_ cell: LSTextFiledTableViewCell, indexPath: IndexPath) {
        cell.loadData()
        cell.contentTextFiled.tag = indexPath.section * 1000 + indexPath.row
        cell.textFiledDelegate = self
        cell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
//        cell.contentTextFiled.inputAccessoryView = BaseTool.addBar(withTarget: self, action: #selector(EventAddViewController.tap))
    }
    
    func createUI() {
        
        self.view.backgroundColor = UIColor.white
        
        var titleName = ""
        
        if (eventType == .eventCustomer) {
            titleName = "新增客户事件"
        }else if (eventType == .eventSudden){
            titleName = "新增重大事件"
        }else if (eventType == .warehouseIn) {
            titleName = "入仓单详情"
        }else if (eventType == .warehouseOut) {
            titleName = "出仓单详情"
        }else if (eventType == .customerIntent) {
            titleName = "客户资料"
        }else if (eventType == .energyMeterUnit) {
            if (energyMeterReadingModel.Type?.compare("0") == .orderedSame) {
                titleName = (energyMeterReadingModel.CustomerName?.appending("[").appending(energyMeterReadingModel.MeterName!).appending("]"))!
            }else {
                titleName = energyMeterReadingModel.MeterName ?? ""
            }
            
        }else if (eventType == .customerComeIn) {
            titleName = "新增跟进"
            if (customerComeInIsModify) {
                titleName = "修改跟进"
            }
        }else if (eventType == .customerNeedInfo) {
            titleName = "客户需求资料"
        }
        
        self.setTitleView(titles: [titleName as NSString])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49 - kNavbarHeight), hasHeader: false, hasFooter: false)
        
        var commitName = ""
        
        if (eventType == .eventCustomer || eventType == .energyMeterUnit) {
            commitName = "保存"
            if (eventType == .eventCustomer && eventCustomerIsModify) {
                commitName = "修改"
            }
        }else if (eventType == .eventSudden) {
            commitName = "提交"
            if (eventSuddenIsModify) {
                commitName = "上报"
            }
        }else if (eventType == .warehouseIn || eventType == .warehouseOut) {
            commitName = "添加"
        }else if (eventType == .customerIntent || eventType == .customerComeIn) {
            commitName = "新增"
            if (eventType == .customerComeIn && customerComeInIsModify) {
                commitName = "修改"
            }else if (eventType == .customerIntent && customerIntentInfoIsModify) {
                commitName = "修改"
            }
        }else if (eventType == .customerNeedInfo) {
            commitName = "更新"
        }
        
        if (commitName.compare("") != .orderedSame) {
            buttonAction(titles: ["返回",commitName], actions: [#selector(pop),#selector(commit)], target: self)
        }else {
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }
        
        if (eventType == .warehouseIn || eventType == .warehouseOut) {
            self.contentTableView?.isScrollEnabled = false
        }
        
    }
    
    func getHeight(_ tag: Int) -> CGFloat {
        let section = tag / 1000 - 1
        let row = tag % 1000
        var height = row * 44
        if (section < 0) {
            return CGFloat(height)
        }else {
            height = (titleNames[section] as! NSArray).count * 44 + row * 44
        }
        
        return CGFloat(height - 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.contentTableView?.frame = (self.contentTableView?.frame.offsetBy(dx: 0,  dy: movement))!
        UIView.commitAnimations()
    }
    
    //MARK: 提交数据
    @objc func commit() {
        if (eventType == .eventCustomer) {
            if (addCustomerEventModel.TenantCode?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "没有选择客户")
                return
            }else if (addCustomerEventModel.EvetnTypeId?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "没有选择事件类别")
                return
            }else if (addCustomerEventModel.Content?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "事件说明不可为空！")
                return
            }
            
            if (eventCustomerIsModify) {
                addCustomerEventModel.update()
            }else {
                addCustomerEventModel.save()
            }
            LocalToastView.toast(text: "保存成功！")
            pop()
        }else if (eventType == .eventSudden) {
            
            if (eventSuddenIsModify) {
                self.upData()
                return
            }
            
            if (addSuddenEventModel.EventTypeName?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "事件类别不可为空！")
                return
            }else if (addSuddenEventModel.EventLevelName?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "事件级别不可为空！")
                return
            }else if (addSuddenEventModel.EventDate?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "事发日期不可为空！")
                return
            }else if (addSuddenEventModel.organizepk?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "相关部门不可为空！")
                return
            }else if (addSuddenEventModel.Address?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "事发地点不可为空！")
                return
            }else if (addSuddenEventModel.SpecificTime?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "时间不可为空！")
                return
            }
            
            let tips = NSMutableArray(capacity: 20)
            
            if (addSuddenEventModel.RelatedPersonnel?.compare("") == .orderedSame) {
                tips.add("相关人员")
            }
            if (addSuddenEventModel.EvetSummary?.compare("") == .orderedSame) {
                tips.add("事件摘要")
            }
            if (addSuddenEventModel.Casualties?.compare("") == .orderedSame) {
                tips.add("人员伤亡")
            }
            if (addSuddenEventModel.PropertyLoss?.compare("") == .orderedSame) {
                tips.add("财产损失")
            }
            
            if (tips.count != 0) {
                
                var tipString = "["
                
                for (index, name) in tips.enumerated() {
                    tipString.append(name as! String)
                    if (index != tips.count - 1) {
                        tipString.append(",")
                    }
                }
                
                tipString.append("]没有填写，继续提交？")
                
                let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: tipString, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                })
                let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    self.continueCommit()
                })
                tipAlertView.addAction(cancelAction)
                tipAlertView.addAction(confirmAction)
                self.present(tipAlertView, animated: true, completion: { 
                    
                })
                
//                alert(title: "提示", message: tipString as NSString, buttonAction: [#selector(EventAddViewController.continueCommit),#selector(EventAddViewController.continueCancel)], buttonNames: ["确认","返回"], type: 1)
                
                return;
                
            }
            
            continueCommit()
            
        }else if (eventType == .customerComeIn) {
            
            let tips = NSMutableArray(capacity: 20)
            
            if (addCustomerComeInModel.Way?.compare("") == .orderedSame) {
                tips.add("跟进方式")
            }
            if (addCustomerComeInModel.IntentionState?.compare("") == .orderedSame) {
                tips.add("意向状态")
            }
            if (addCustomerComeInModel.Content?.compare("") == .orderedSame) {
                tips.add("跟进内容")
            }
            
            if (tips.count != 0) {
                
                var tipString = "["
                
                for (index, name) in tips.enumerated() {
                    tipString.append(name as! String)
                    if (index != tips.count - 1) {
                        tipString.append(",")
                    }
                }
                
                tipString.append("]没有填写，继续提交？")
                
                let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: tipString, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                })
                let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    self.continueCommit()
                })
                tipAlertView.addAction(cancelAction)
                tipAlertView.addAction(confirmAction)
                self.present(tipAlertView, animated: true, completion: {
                    
                })
                
                return;
                
            }
            
            self.continueCommit()
            
        }else if (eventType == .customerNeedInfo) {
            customerNeedInfoIsModify = true
            requestData()
        }else if (eventType == .customerIntent) {
            //客户意向 UpdateYXKHInfoAPICmd-新增或更新客户意向
            
            if (addUpdateYXKHInfoModel.CName?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "客户名称不可为空!")
                return
            }
            
            if (customerIntentInfoIsModify) {
                LoadView.storeLabelText = "加载客户意向"
            }else {
                LoadView.storeLabelText = "新增客户意向"
            }
            
            let updateYXKHInfoAPICmd = UpdateYXKHInfoAPICmd()
            updateYXKHInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            updateYXKHInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","info":addUpdateYXKHInfoModel.yy_modelToJSONString() ?? ""]
            updateYXKHInfoAPICmd.loadView = LoadView()
            updateYXKHInfoAPICmd.loadParentView = self.view
            updateYXKHInfoAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.pop()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }
        else if (eventType == .warehouseIn || eventType == .warehouseOut) {
            
            let price = wareHouseGoodDictionary.object(forKey: "Price") as? String
            let num = wareHouseGoodDictionary.object(forKey: "Num") as? String
            
            if eventType == .warehouseIn && (price?.compare("") == .orderedSame
                || num?.compare("") == .orderedSame) {
                if num?.compare("") == .orderedSame {
                    LocalToastView.toast(text: "请填写数量!")
                }else if price?.compare("") == .orderedSame {
                    LocalToastView.toast(text: "请填写单价!")
                }
                return
            }
            
            if eventType == .warehouseOut && num?.compare("") == .orderedSame {
                LocalToastView.toast(text: "请填写数量!")
                return
            }
            
            if (warehouseInOutListModel.WarehouseID?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "没有选择名称")
                return
            }
            
            if (warehouseInOutListModel.WarehouseWarrantType?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "没有选择类型")
                return
            }
            
            /*
            var index = 0
            
            for dict in wareHouseGoods {
                let tempDict = dict as! NSDictionary
                if (tempDict["Code"] as! String).compare(wareHouseGoodDictionary["Code"] as! String) == .orderedSame {
                    //如果存在该数据，则更新
                    wareHouseGoods.replaceObject(at: index, with: NSMutableDictionary(dictionary: wareHouseGoodDictionary))
                    break
                }
                index = index + 1
            }
            if (wareHouseGoods.count == index) {
                wareHouseGoods.add(NSMutableDictionary(dictionary: wareHouseGoodDictionary))
            }
            */
            
            if wareHouseInfoIsModify {
                
                var index = 0
                
                for dict in wareHouseGoods {
                    let tempDict = dict as! NSDictionary
                    if (tempDict["Code"] as! String).compare(wareHouseGoodDictionary["Code"] as! String) == .orderedSame {
                        //如果存在该数据，则更新
                        wareHouseGoods.replaceObject(at: index, with: NSMutableDictionary(dictionary: wareHouseGoodDictionary))
                        break
                    }
                    index = index + 1
                }
            }else {
                wareHouseGoods.add(NSMutableDictionary(dictionary: wareHouseGoodDictionary))
            }
            
            wareHouseGoodDictionary.removeAllObjects()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            warehouseInOutListModel.InDate = formatter.string(from: NSDate() as Date)
            warehouseInOutListModel.ListItems = wareHouseGoods.yy_modelToJSONString()
            
//            if (wareHouseInfoIsModify) {
//                warehouseInOutListModel.update()
//            }else {
//                warehouseInOutListModel.save()
//            }
//            
            warehouseInOutListModel.saveOrUpdate()
            
            self.contentTableView?.reloadData()
            
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }else if (eventType == .energyMeterUnit) {
            energyMeterReadingModel.isModify = "1"
            
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateStr = dateFmt.string(from: Date())
            let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
            let finalTime = (dateForeStr as! String).replacingOccurrences(of: "T", with: " ")
            energyMeterReadingModel.InputTime = finalTime
            
            energyMeterReadingModel.update()
            self.pop()
        }
    }
    
    //MARK: 继续创建
    func continueCommit() {
        //新增AddMajorEventAPICmd
        
        if (eventType == .eventSudden) {
            
            AddSuddenEventModel.upgrateDataBase(["commitStatus"])
            
            if !BaseTool.isExistenceNetwork() {
                self.addSuddenEventModel.commitStatus = "0"
                self.addSuddenEventModel.saveOrUpdate()
                return
            }
            
            addSuddenEventModel.out_trade_no = GUIDGenarate.stringWithUUID()
            
            let json = addSuddenEventModel.yy_modelToJSONString()
            
            let data = json?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let changeDict = NSMutableDictionary(dictionary: dictionary!)
            
            let object = NSMutableArray(object: changeDict)
            
            LoadView.storeLabelText = "新增重大事件"
            
            let addMajorEventAPICmd = AddMajorEventAPICmd()
            addMajorEventAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            addMajorEventAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","infos":object.yy_modelToJSONString() ?? ""]
            addMajorEventAPICmd.loadView = LoadView()
            addMajorEventAPICmd.loadParentView = self.view
            addMajorEventAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.addSuddenEventModel.code = dict["infos"][0]["ServerPK"].stringValue
                    self.addSuccess()
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                self.addSuddenEventModel.commitStatus = "0"
                self.addSuddenEventModel.saveOrUpdate()
                LocalToastView.toast(text: DisNetWork)
            }
            
        }else if (eventType == .customerComeIn) {
            
            addCustomerComeInModel.out_trade_no = GUIDGenarate.stringWithUUID()
            
            
            
            let json = addCustomerComeInModel.yy_modelToJSONString()
            
            let data = json?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let changeDict = NSMutableDictionary(dictionary: dictionary!)
            changeDict["IntentionState"] = selectContentModel.customerComeInWant
            
            let object = NSMutableArray(object: changeDict)
            
            var addFollowRecordAPICmd = XYCBaseRequest()
            
            if (customerComeInIsModify) {
                //修改-更新
                LoadView.storeLabelText = "修改跟进记录"
                addFollowRecordAPICmd = UpdateFollowRecordAPICmd()
            }else {
                //新增
                LoadView.storeLabelText = "新增跟进记录"
                addFollowRecordAPICmd = AddFollowRecordAPICmd()
            }
            
            addFollowRecordAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            addFollowRecordAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Infos":object.yy_modelToJSONString() ?? ""]
            addFollowRecordAPICmd.loadView = LoadView()
            addFollowRecordAPICmd.loadParentView = self.view
            addFollowRecordAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.pop()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
        }
    }
    
    func addSuccess() {
        buttonAction(titles: ["返回","上报"], actions: [#selector(pop),#selector(upData)], target: self)
        self.perform(#selector(EventAddViewController.delayAction), with: nil, afterDelay: 1.0)
    }
    
    @objc func delayAction() {
        
        let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "提交成功，是否上报", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "否", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.pop()
            self.addSuddenEventModel.save()
        })
        let confirmAction = UIAlertAction(title: "是", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.upData()
        })
        tipAlertView.addAction(cancelAction)
        tipAlertView.addAction(confirmAction)
        self.present(tipAlertView, animated: true, completion: {
            
        })
        
//        alert(title: "提示", message: "提交成功，是否上报", buttonAction: [#selector(EventAddViewController.upData)], buttonNames: ["是","否"], type: 1)
    }
    
    @objc func continueCancel() {
        
    }
    
    @objc func upData() {
        
        showActionSheet(title: "选择上报对象", cancelTitle: "取消", titles: ["直接上报主管","选择其他人员"], tag: "UpData")
    }
    
    @objc func inoutScan() {
        let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
        qrcodeVC.scanType = .inoutScan
        qrcodeVC.scanDelegate = self
        self.push(viewController: qrcodeVC)
    }
    
    func tap() {
        self.view.endEditing(true)
    }
    
    override func pop() {
        if self.isPresent {
            self.dismiss(animated: true, completion: nil);
            return;
        }
        var isPop = true
        if (eventType == .warehouseIn
            || eventType == .warehouseOut) {
            
            if (eventType == .warehouseIn) {
                if (wareHouseGoods.count == 0 && WarehouseInOutListModel.find(byCriteria:  " WHERE IsWarehouseRecepit = '1'").count != 0) {
                    isPop = false
                }
            }else {
                if (wareHouseGoods.count == 0 && WarehouseInOutListModel.find(byCriteria:  " WHERE IsWarehouseRecepit = '0'").count != 0) {
                    isPop = false
                }
            }
            
            
            if !(isPop) {
                alert(title: "提示", message: "该单据没有物品列表，退出将删除该单据！", buttonAction: [#selector(EventAddViewController.goodsDeleteConfirm),#selector(EventAddViewController.continueCancel)], buttonNames: ["确认","返回"], type: 7775)
            }
        }else if (eventType == .energyMeterUnit) {
            //能耗抄表
            var isTip = false
            if let isFirst = UserDefaults.standard.object(forKey: "EnergyMeterUnitBackTipFirst") {
                if ((isFirst as! String).compare("YES") != .orderedSame) {
                    isTip = true
                }
            }else {
                isTip = true
            }
            if isTip {
                
                let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "返回将不会保存被更改的数据", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "不退出", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    
                })
                let confirmAction = UIAlertAction(title: "继续退出", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    isPop = true
                    super.pop()
                })
                let notip = UIAlertAction(title: "不再提示", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                    isPop = true
                    UserDefaults.standard.set("YES", forKey: "EnergyMeterUnitBackTipFirst")
                    super.pop()
                })
                tipAlertView.addAction(cancelAction)
                tipAlertView.addAction(confirmAction)
                tipAlertView.addAction(notip)
                self.present(tipAlertView, animated: true, completion: {
                    
                })
            }
        }
        
        if isPop {
            super.pop()
        }
    }

}
