//
//  DataInfoDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/31.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

enum DataInfoDetailType {
    case dataInfoDetailCar
    case dataInfoDetailEquipment
    case dataInfoRentControl
}

class DataInfoDetailViewController: BaseTableViewController {

    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var rentControlView = RentControlTipView()
    var isPresnet:Bool = false
    
    var code = ""
    var equipmentModel = InfoEquipmentMaterialModel()
    var titles: NSMutableArray = NSMutableArray(array: ["车辆信息","车主信息","租赁信息"])
    var titleItems: NSMutableArray = NSMutableArray()
    var values: NSMutableArray = NSMutableArray()
    var dataInfoDetailType = DataInfoDetailType.dataInfoDetailCar
    
    var titleName: NSString = NSString(string: "")
    
    var selectSection = 0
    var selectRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        initData()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = titleItems[section] as! NSArray
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (dataInfoDetailType == .dataInfoRentControl) {
            return 5.0
        }
        return 40;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (dataInfoDetailType == .dataInfoRentControl) {
            return nil
        }
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        let titleLable = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth, height: 30))
        titleLable.font = UIFont.boldSystemFont(ofSize: 16)
        titleLable.text = titles[section] as? String
        backView.addSubview(titleLable)
        return backView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        //WarehouseInNumberTableViewCell
        let wareHouseCellID = "WareHouseCellID"
        
        if (dataInfoDetailType == .dataInfoRentControl
            && ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2)) || indexPath.section == 1 && indexPath.row == 1)) {
            
            var wareHouseCell = tableView.dequeueReusableCell(withIdentifier: wareHouseCellID)
            
            if wareHouseCell == nil {
                
                wareHouseCell = Bundle.main.loadNibNamed("WarehouseInNumberTableViewCell", owner: nil, options: nil)?.first as! WarehouseInNumberTableViewCell
                wareHouseCell?.selectionStyle = .none
                
                wareHouseCell?.separatorInset = .zero
                wareHouseCell?.layoutMargins = .zero
                wareHouseCell?.preservesSuperviewLayoutMargins = false
            }
            let tempCell = wareHouseCell as! WarehouseInNumberTableViewCell
            
            let array = values[indexPath.section] as! NSArray
            let value = array[indexPath.row] as? String
            
            let valueArray: NSArray = (value?.components(separatedBy: "=") as? NSArray)!
            if (valueArray.count == 2) {
                tempCell.numberTextField.text = valueArray[0] as? String
                tempCell.priceTextField.text = valueArray[1] as? String
            }
            
            if (indexPath.section == 0 && indexPath.row == 1) {
                tempCell.numberNameLabel.text = "建筑面积"
                tempCell.priceNameLabel.text = "计费面积"
            }else if (indexPath.section == 0 && indexPath.row == 2) {
                tempCell.numberNameLabel.text = "物业类型"
                tempCell.priceNameLabel.text = "物业状态"
            }else if (indexPath.section == 1 && indexPath.row == 1) {
                tempCell.numberNameLabel.text = "企业性质"
                tempCell.priceNameLabel.text = "法人代表"
            }
            tempCell.numberNameConstraint.constant = 80
            tempCell.priceNameConstraint.constant = 80
            tempCell.numberTextFieldConstraint.constant = 80
            tempCell.priceTextFieldConstraint.constant = 80
            tempCell.numberTextField.isUserInteractionEnabled = false
            tempCell.priceTextField.isUserInteractionEnabled = false
            return wareHouseCell!
        }
        
        var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if materialDataInfoDetailTableViewCell == nil {
            
            materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
            materialDataInfoDetailTableViewCell?.selectionStyle = .none
            
            materialDataInfoDetailTableViewCell?.separatorInset = .zero
            materialDataInfoDetailTableViewCell?.layoutMargins = .zero
            materialDataInfoDetailTableViewCell?.preservesSuperviewLayoutMargins = false
        }
        
        let tempCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
        tempCell.iconImageView.isHidden = true
        let array = titleItems[indexPath.section] as! NSArray
        tempCell.nameLabel.text = array[indexPath.row] as? String
        let arrayValue = values[indexPath.section] as! NSArray
        tempCell.contentLabel.text = arrayValue[indexPath.row] as? String
        
        if (dataInfoDetailType == .dataInfoDetailCar) {
            
            if (indexPath.section == 1 && indexPath.row == 1) {
                tempCell.iconImageView.isHidden = false
                tempCell.iconImageView.image = UIImage(named: "icon_phone")
            }
            
        }
        
        if dataInfoDetailType == .dataInfoRentControl {
            if indexPath.section == 2 && (indexPath.row == 2 || indexPath.row == 3) {
                tempCell.nameLabel.numberOfLines = 0
            }
            if indexPath.section == 1 && indexPath.row == 4 {
                tempCell.contentLabel.textColor = UIColor.red
            }
        }
        
        return materialDataInfoDetailTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (dataInfoDetailType == .dataInfoDetailCar && indexPath.section == 1 && indexPath.row == 1) {
            selectSection = indexPath.section
            selectRow = indexPath.row
            action()
        }
    }
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return;
        }
        
        let arrayValue = values[selectSection] as! NSArray
        let number = arrayValue[selectRow] as? String
        
        if (tag.compare("Select") == .orderedSame) {
            
            if (number == nil || number?.compare("") == .orderedSame) {
                return
            }
            
            if (buttonIndex == 1) {
                UIPasteboard.general.string = number
            }else if (buttonIndex == 2
                || buttonIndex == 3) {
                
                if (buttonIndex == 3) {
                    if (Validate.phoneNum(number!).isRight) {
                        let phone = "sms://".appending(number!)
                        UIApplication.shared.openURL(URL(string: phone)!)
                    }else {
                        LocalToastView.toast(text: "不是有效的手机号码")
                    }
                }else {
                    let sms = "tel:".appending(number!)
                    UIApplication.shared.openURL(URL(string: sms)!)
                }
            }
        }
        
    }
    
    func initData() {
        
        if (dataInfoDetailType == .dataInfoDetailCar) {
            
            titles = NSMutableArray(array: ["车辆信息","车主信息","租赁信息"])
            titleItems = NSMutableArray(array: [["车辆种类","车卡编号","品牌类型","车重","颜色","备注"],
                                                ["车主姓名","联系电话","单位名称","单位编号"],
                                                ["固定车位","起租日期","止租日期","已收款至"]])
            values = NSMutableArray(array: [["","","","","",""],
                                            ["","","",""],
                                            ["","","",""]])
            
        }else if (dataInfoDetailType == .dataInfoDetailEquipment) {
            titles = NSMutableArray(array: ["基础信息","厂家信息","资产信息"])
            titleItems = NSMutableArray(array: [["设备名称","规格型号","级别","品牌","数量","投用日期","使用年限","已用年数","位置","附加说明"],
                                                ["生产厂家","出厂序号","出厂日期","交接日期","维保商","启保日期","终保日期"],
                                                ["资产类别","资产编号","购买日期","原值","折旧率","折旧月数","折旧年限","累计折旧","残值"]])
        }else if (dataInfoDetailType == .dataInfoRentControl) {
            
            titles = NSMutableArray(array: ["","",""])
            titleItems = NSMutableArray(array: [["房屋编号","建筑面积.计费面积","物业类型.物业状态"],
                                                ["业户简称","企业性质.法人代表","联系人","联系电话","欠费总额"],
                                                ["合同编号","签约日期","合同起始日期","合同终止日期","起租日期","租赁用途","经营品牌","合同备注"]])
            values = NSMutableArray(array: [["","",""],
                                            ["","","","",""],
                                            ["","","","","","","",""]])
        }
        
        self.contentTableView?.reloadData()
        
    }
    
    func createUI() {
        
        var height: CGFloat = 0
        
        if (dataInfoDetailType == .dataInfoDetailCar
            || dataInfoDetailType == .dataInfoDetailEquipment) {
            self.setTitleView(titles: [titleName])
        }else if (dataInfoDetailType == .dataInfoRentControl) {
            self.setTitleView(titles: ["租户详情"])
            rentControlView = RentControlTipView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 60))
            height = rentControlView.frame.size.height
            self.view.addSubview(rentControlView)
        }
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: height, width: kScreenWidth, height: kScreenHeight - kNavbarHeight - 49 - height), hasHeader: true, hasFooter: false)
        if (dataInfoDetailType == .dataInfoRentControl) {
            self.view.bringSubview(toFront: rentControlView)
        }
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    override func requestData() {
        super.requestData()
        
        if (dataInfoDetailType == .dataInfoDetailCar) {
            
            LoadView.storeLabelText = "正在车辆资料信息"
            
            let searchCarInfoAPICmd = SearchCarInfoAPICmd()
            searchCarInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            searchCarInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","code":code]
            searchCarInfoAPICmd.loadView = LoadView()
            searchCarInfoAPICmd.loadParentView = self.view
            searchCarInfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                
                    if (dict["infos"]["OwerType"].string?.compare("房间业户") == .orderedSame) {
                        self.titleItems = NSMutableArray(array: [["车辆种类","车卡编号","品牌类型","车重","颜色","备注"],
                                                            ["车主姓名","联系电话","业主名称","业主编号","相关房屋"],
                                                            ["固定车位","起租日期","止租日期","已收款至"]])
                    }
                    
                    self.values = NSMutableArray(array: DataInfoDetailManager.shareInstance().dealCarInfo(withDatas: response))
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }else if (dataInfoDetailType == .dataInfoDetailEquipment) {
            
            //GetEquipmentListDetailAPICmd
            
            //初始化
            self.values = NSMutableArray(array: DataInfoDetailManager.shareInstance().dealEquipment(withEquipmentMaterialModel: self.equipmentModel, datas: nil))
            
            LoadView.storeLabelText = "正在设备资料信息"
            
            let getEquipmentListDetailAPICmd = GetEquipmentListDetailAPICmd()
            getEquipmentListDetailAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getEquipmentListDetailAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","equipmentpk":equipmentModel.equipmentpk ?? "", "version":"1.0"]
            getEquipmentListDetailAPICmd.loadView = LoadView()
            getEquipmentListDetailAPICmd.loadParentView = self.view
            getEquipmentListDetailAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.values = NSMutableArray(array: DataInfoDetailManager.shareInstance().dealEquipment(withEquipmentMaterialModel: self.equipmentModel, datas: response))
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
            
        }else if (dataInfoDetailType == .dataInfoRentControl) {
            
            LoadView.storeLabelText = "正在查询详细信息"
            
            let getunitinfoAPICmd = GetunitinfoAPICmd()
            getunitinfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getunitinfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","proomcode":code]
            getunitinfoAPICmd.loadView = LoadView()
            getunitinfoAPICmd.loadParentView = self.view
            getunitinfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    /*
                     @property (nonatomic, strong) UILabel *topTipLabel;
                     @property (nonatomic, strong) UILabel *bottomTipLabel;
                     */
                    
                    self.values = NSMutableArray(array: DataInfoDetailManager.shareInstance().dealRentControlInfo(withDatas: response))
                    self.rentControlView.bottomTipLabel.text = dict["info"]["tenantName"].stringValue
                    if dict["info"]["tenantName"].stringValue.compare("") == .orderedSame {
                        self.rentControlView.bottomTipLabel.text = "无租户"
                    }
                    self.rentControlView.topTipLabel.text = dict["info"]["pRoomFullName"].stringValue
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
    
    func action() {
        
        let arrayValue = values[selectSection] as! NSArray
        let number = arrayValue[selectRow] as? String
        
        if (number == nil || number?.compare("") == .orderedSame) {
            return
        }
        
        showActionSheet(title: "请选择", cancelTitle: "取消", titles: ["复制","拨打电话","发送短信"], tag: "Select")
    }
    
    override func pop() {
        if self.isPresnet {
            self.dismiss(animated: true, completion: nil);
            return;
        }
        super.pop()
    }

}
