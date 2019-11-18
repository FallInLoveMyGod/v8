//
//  EnergyMeterReadingListViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class EnergyMeterReadingListViewController: BaseTableViewController,FJFloatingViewDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    let itemNames = ["表总数","已抄数","未抄数","未上传"]
    
    var commonNumber = 0
    var unitNumber = 0
    var noUploadNumber = 0
    var noCommonNumber = 0
    var noUnitNumber = 0
    var noUnitUploadNumber = 0
    
    var dataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var dataCommonSource: NSMutableArray = NSMutableArray(capacity: 20)
    var dataUnitSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth - 10, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if (section == 0) {
            label.text = "单元表"
        }else {
            label.text = "公用表"
        }
        backView.addSubview(label)
        
        return backView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var taskNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskNumberTableViewCell == nil {
            
            taskNumberTableViewCell = Bundle.main.loadNibNamed("TaskNumberTableViewCell", owner: nil, options: nil)?.first as! TaskNumberTableViewCell
            
            let lineView = UIView(frame: CGRect(x: 0, y: 43.5, width: kScreenWidth, height: 0.5))
            lineView.backgroundColor = UIColor.groupTableViewBackground
            taskNumberTableViewCell?.contentView.addSubview(lineView)
        }
        
        let tempCell: TaskNumberTableViewCell = taskNumberTableViewCell as! TaskNumberTableViewCell
        if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                tempCell.numberLabel.text = String(self.commonNumber)
            case 1:
                tempCell.numberLabel.text = String(self.noCommonNumber)
            case 2:
                tempCell.numberLabel.text = String(self.commonNumber - self.noCommonNumber)
            case 3:
                tempCell.numberLabel.text = String(self.noUploadNumber)
            default:
                tempCell.numberLabel.text = ""
            }
            
        } else {
            
            switch indexPath.row {
            case 0:
                tempCell.numberLabel.text = String(self.unitNumber)
            case 1:
                tempCell.numberLabel.text = String(self.noUnitNumber)
            case 2:
                tempCell.numberLabel.text = String(self.unitNumber - self.noUnitNumber)
            case 3:
                tempCell.numberLabel.text = String(self.noUnitUploadNumber)
            default:
                tempCell.numberLabel.text = ""
            }
            
        }
        
        tempCell.nameLabel.text = itemNames[indexPath.row]
        
        return taskNumberTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0) {
            if (self.unitNumber == 0) {
                LocalToastView.toast(text: "没有相关数据，请先下载能耗表！")
                return
            }
        }else if (indexPath.section == 1) {
            if (self.commonNumber == 0) {
                LocalToastView.toast(text: "没有相关数据，请先下载能耗表！")
                return
            }
        }
        
        let detailList = EnergyMeterReadingViewController()
        detailList.commonNumber = self.commonNumber
        detailList.unitNumber = self.unitNumber
        detailList.type = EnergyMeterReadingType(rawValue: indexPath.row)!
        if (indexPath.section == 0) {
            detailList.isCommon = false
            if (indexPath.row == 0) {
                detailList.dataSource = self.dataUnitSource
            } else if (indexPath.row == 1 || indexPath.row == 2) {
                
                let source = self.dataUnitSource.filter{ indexPath.row == 1 ? (($0 as! EnergyMeterReadingModel).isTake?.compare("1") == .orderedSame) : (($0 as! EnergyMeterReadingModel).isTake?.compare("1") != .orderedSame) }
                let dataArr:NSMutableArray = NSMutableArray();
                for model in source {
                    let tempModel = model as! EnergyMeterReadingModel
                    dataArr.add(tempModel)
                }
//                let array:NSArray = source.reversed() as NSArray;
//                detailList.dataSource = array as! NSMutableArray
                detailList.dataSource = dataArr;
                
            } else {
                let source = self.dataUnitSource.filter{ ($0 as! EnergyMeterReadingModel).isModify?.compare("1") == .orderedSame }
                detailList.dataSource = source as! NSMutableArray
            }
            
            
        }else {
            detailList.dataSource = self.dataCommonSource
        }
        
        self.push(viewController: detailList)
    }
    
    //MARK: FJFloatingViewDelegate
    
    func floatingViewClick() {
        let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
        self.push(viewController: qrcodeVC)
    }
    
    func initData() {
        self.clearData()
        self.dataSource = NSMutableArray(array: EnergyMeterReadingModel.findAll())
        for model in self.dataSource {
            let energyMeterReadingModel = model as! EnergyMeterReadingModel
            
            self.addSourceWithModel(energyMeterReadingModel: energyMeterReadingModel)
        }
        self.contentTableView?.reloadData()
        
        if (Int(self.noUploadNumber) != 0 || Int(self.noUnitUploadNumber) != 0) {
            buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commit)], target: self)
        }
    }
    
    func createUI() {
        
        self.setTitleView(titles: ["能耗抄表" as NSString])
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), hasHeader: false, hasFooter: false)
        
        contentTableView?.separatorStyle = .none
        
        floatingView.delegate = self
        floatingView.iconImageView.image = UIImage(named: "icon_sys_pressed")
        self.view.addSubview(floatingView)
        
        buttonAction(titles: ["返回","下载"], actions: [#selector(pop),#selector(downLoad)], target: self)
    }
    
    @objc func downLoad() {
        
        super.requestData()
        
        let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "下载能耗表", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "立即下载", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.downloadAction()
        })
        let confirmAction = UIAlertAction(title: "取消", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.downloadCancel()
        })
        
        tipAlertView.addAction(cancelAction)
        tipAlertView.addAction(confirmAction)
        self.present(tipAlertView, animated: true, completion: {
            
        })
        
    }
    
    @objc func commit() {
        
        var meteInfo = Array<NSDictionary>()
        for model in self.dataSource {
            let energyMeterReadingModel = model as! EnergyMeterReadingModel
            
            var isAdd = false
            
            if (energyMeterReadingModel.isModify?.compare("1") == .orderedSame) {
                isAdd = true
            }
            
            if isAdd {
                let item = NSMutableDictionary()
                item.setValue(energyMeterReadingModel.ID, forKey: "ID")
                item.setValue(energyMeterReadingModel.Type, forKey: "Type")
                item.setValue(energyMeterReadingModel.CurDegree, forKey: "CurDegree")
                item.setValue(energyMeterReadingModel.QuantityAdjust, forKey: "QuantityAdjust")
                let finalTime = energyMeterReadingModel.InputTime?.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: ":", with: "&")
                
                item.setValue(finalTime, forKey: "InputTime")
                item.setValue(energyMeterReadingModel.InputPerson, forKey: "InputPerson")
                item.setValue(energyMeterReadingModel.Memo, forKey: "Memo")
                
                meteInfo.append(item)
            }
        }
        
        
        
        LoadView.storeLabelText = "获取表数据"

        let updateMeterInfoAPICmd = UpdateMeterInfoAPICmd()
        updateMeterInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        updateMeterInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "",
                                            "upk":userInfo?.upk ?? "",
                                            "meterInfo":BaseTool.toJson(meteInfo) ?? ""]
        updateMeterInfoAPICmd.loadView = LoadView()
        updateMeterInfoAPICmd.loadParentView = self.view
        updateMeterInfoAPICmd.transactionWithSuccess({ (response) in

            print(response)
            let dict = JSON(response)

            print(dict)

            let resultStatus = dict["result"].string

            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                
                for model in self.dataSource {
                    
                    let energyMeterReadingModel = model as! EnergyMeterReadingModel
                    
                    if (energyMeterReadingModel.isModify?.compare("1") == .orderedSame) {
                        energyMeterReadingModel.isModify = "0"
                        energyMeterReadingModel.isTake = "1"
                        energyMeterReadingModel.update()
                    }
                }
                
                //成功
                self.pop()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    func downloadAction() {
        
        LoadView.storeLabelText = "正在下载能耗抄表信息"
        
        let getMeterInfoAPICmd = GetMeterInfoAPICmd()
        getMeterInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getMeterInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        getMeterInfoAPICmd.loadView = LoadView()
        getMeterInfoAPICmd.loadParentView = self.view
        getMeterInfoAPICmd.transactionWithSuccess({ (response) in

            let dict = JSON(response)
            
            print(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                EnergyMeterReadingModel.clearTable()
                self.clearData()
                for (_,tempDict) in dict["Records"] {
                    
                    if let energyMeterReadingModel:EnergyMeterReadingModel = EnergyMeterReadingModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        self.addSourceWithModel(energyMeterReadingModel: energyMeterReadingModel)
                        energyMeterReadingModel.isModify = "0"
                        energyMeterReadingModel.isTake = "0"
                        self.dataSource.add(energyMeterReadingModel)
                        energyMeterReadingModel.save()
                    }
                    
                }
                LocalToastView.toast(text: "下载完成！")
                
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
    
    func addSourceWithModel(energyMeterReadingModel: EnergyMeterReadingModel) {
        
        if (BaseTool.toStr(energyMeterReadingModel.Type).compare("1") == .orderedSame) {
            self.commonNumber = self.commonNumber + 1
            if (energyMeterReadingModel.isTake?.compare("1") == .orderedSame) {
                self.noCommonNumber = self.noCommonNumber + 1
            }
            if (energyMeterReadingModel.isModify == "1") {
                self.noUploadNumber = self.noUploadNumber + 1
            }
            self.dataCommonSource.add(energyMeterReadingModel)
        }else {
            self.unitNumber = self.unitNumber + 1
            if (energyMeterReadingModel.isTake == "1") {
                self.noUnitNumber = self.noUnitNumber + 1
            }
            if energyMeterReadingModel.isModify == "1" {
                self.noUnitUploadNumber = self.noUnitUploadNumber + 1
            }
            self.dataUnitSource.add(energyMeterReadingModel)
        }
    }
    
    func clearData() {
        self.commonNumber = 0
        self.unitNumber = 0
        self.noUploadNumber = 0
        self.noUnitNumber = 0
        self.noCommonNumber = 0
        self.noUnitUploadNumber = 0
        self.dataCommonSource = NSMutableArray(capacity: 20)
        self.dataUnitSource = NSMutableArray(capacity: 20)
    }
    
    func downloadCancel() {
        
    }
    
}
