//
//  SearchResultsTableViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: BaseTableViewController {
    typealias BLOCK = (_ model:EnergyMeterReadingModel) -> ()
    @objc var filteredListContent: NSMutableArray = NSMutableArray()
    @objc var key: NSString = NSString()
    @objc var infoMaterialType = 0
    @objc var isCommon: Bool = true
    @objc var block:BLOCK?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 128, width: kScreenWidth, height: kScreenHeight - 64), hasHeader: false, hasFooter: false)
        self.navigationController?.navigationBar.isHidden = false;
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredListContent.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
        if infoMaterialType == 3 {
            
            var energyMeterReadingSearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if energyMeterReadingSearchTableViewCell == nil {
                
                energyMeterReadingSearchTableViewCell = Bundle.main.loadNibNamed("EnergyMeterReadingSearchTableViewCell", owner: nil, options: nil)?.first as! EnergyMeterReadingSearchTableViewCell
                energyMeterReadingSearchTableViewCell?.accessoryType = .none
            }
            
            let tempCell: EnergyMeterReadingSearchTableViewCell = energyMeterReadingSearchTableViewCell as! EnergyMeterReadingSearchTableViewCell
            
            let energyMeterTag = 7
            
            tempCell.contentView.viewWithTag(energyMeterTag)?.removeFromSuperview()
            
            let model = self.filteredListContent[indexPath.section] as! EnergyMeterReadingModel

            if (isCommon) {
                tempCell.titleLabel.text = model.MeterName!
            }else {
                tempCell.titleLabel.text = model.CustomerName?.appending("[").appending(model.MeterName!).appending("]")
            }
            
            if (model.isModify?.compare("1") == .orderedSame) {
                tempCell.readStatusImageView.isHidden = false
            }else {
                tempCell.readStatusImageView.isHidden = true
            }
            
            tempCell.codeLabel.text = ""
            
            var pBuildingName = ""
            if (model.PBuildingName?.compare("") != .orderedSame) {
                pBuildingName = "/".appending(model.PBuildingName!)
            }
            
            var pFloorName = ""
            if (model.PFloorName?.compare("") != .orderedSame) {
                pFloorName = "/".appending(model.PFloorName!)
            }
            
            var pRoomName = ""
            if (model.PRoomName != nil && model.PRoomName?.compare("") != .orderedSame) {
                pRoomName = "/".appending(model.PRoomName!)
            }
            
            tempCell.positionLabel.text = model.PProjectName?.appending(pBuildingName).appending(pFloorName).appending(pRoomName)
            
            let energyMeterReadingView = EnergyMeterReadingView(frame: CGRect(x: 0, y: 95, width: kScreenWidth, height: 30), names: ["上次","本次","用量"], contents: [model.PreDegree ?? "",model.CurDegree ?? "",model.Quantity ?? ""])
            energyMeterReadingView?.tag = energyMeterTag
            tempCell.contentView.addSubview(energyMeterReadingView!)
            
            BaseTool.changeColor(withKey: key as String!, content: tempCell.titleLabel.text, textLabel: tempCell.titleLabel)
            BaseTool.changeColor(withKey: key as String!, content: tempCell.positionLabel.text, textLabel: tempCell.positionLabel)
            
            return energyMeterReadingSearchTableViewCell!

        }
        
        var carInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if carInfoTableViewCell == nil {
            
            carInfoTableViewCell = Bundle.main.loadNibNamed("CarInfoTableViewCell", owner: nil, options: nil)?.first as! CarInfoTableViewCell
            carInfoTableViewCell?.selectionStyle = .none
        }
        
        let tempCell: CarInfoTableViewCell = carInfoTableViewCell as! CarInfoTableViewCell
        
        if (infoMaterialType == 0) {
            
            let model: InfoMaterialModel = self.filteredListContent[indexPath.section] as! InfoMaterialModel
            tempCell.statusLabel.isHidden = true
            tempCell.titleLabel.text = model.Code
            tempCell.materialCodeNameLabel.text = "车辆类型"
            tempCell.materialXHNameLabel.text = "车主名称"
            tempCell.locationNameLabel.text = "车位信息"
            tempCell.materialCodeLabel.text = model.Type
            tempCell.materialXHLabel.text = model.Name
            tempCell.locationLabel.text = model.Parkinglot
            
            BaseTool.changeColor(withKey: key as String!, content: tempCell.titleLabel.text, textLabel: tempCell.titleLabel)
            BaseTool.changeColor(withKey: key as String!, content: tempCell.materialCodeLabel.text, textLabel: tempCell.materialCodeLabel)
            BaseTool.changeColor(withKey: key as String!, content: tempCell.materialXHLabel.text, textLabel: tempCell.materialXHLabel)
            BaseTool.changeColor(withKey: key as String!, content: tempCell.locationLabel.text, textLabel: tempCell.locationLabel)
        }else if (infoMaterialType == 1) {
            let model: InfoEquipmentMaterialModel = self.filteredListContent[indexPath.section] as! InfoEquipmentMaterialModel
            tempCell.statusLabel.isHidden = false
            tempCell.statusLabel.text = model.equipmentstate
            tempCell.titleLabel.text = model.equipmentname
            tempCell.materialCodeNameLabel.text = "设备编号"
            tempCell.materialXHNameLabel.text = "设备型号"
            tempCell.locationNameLabel.text = "位置信息"
            tempCell.materialCodeLabel.text = model.equipmentno
            tempCell.materialXHLabel.text = model.equipmenttype
            tempCell.locationLabel.text = model.equipmentlocation
            
            BaseTool.changeColor(withKey: key as String!, content: tempCell.titleLabel.text, textLabel: tempCell.titleLabel)
            BaseTool.changeColor(withKey: key as String!, content: tempCell.materialCodeLabel.text, textLabel: tempCell.materialCodeLabel)
            BaseTool.changeColor(withKey: key as String!, content: tempCell.materialXHLabel.text, textLabel: tempCell.materialXHLabel)
        }else if (infoMaterialType == 2) {
            let model: InfoCustomerIntentMaterialModel = self.filteredListContent[indexPath.section] as! InfoCustomerIntentMaterialModel
            tempCell.statusLabel.isHidden = true
            tempCell.titleLabel.text = model.CName
            tempCell.materialCodeNameLabel.text = "跟进次数"
            tempCell.materialXHNameLabel.text = "首访时间"
            tempCell.locationNameLabel.text = "最近跟进"
            tempCell.materialCodeLabel.text = model.Num
            tempCell.materialXHLabel.text = model.FirstDate
            tempCell.locationLabel.text = model.RecentDate
            BaseTool.changeColor(withKey: key as String!, content: tempCell.titleLabel.text, textLabel: tempCell.titleLabel)
        }
        
        return carInfoTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.dismiss(animated: true) {
//
//        };
        let event = EventAddViewController();
        let navc = UINavigationController.init(rootViewController: event);
        let detail = DataInfoDetailViewController();
        let dataNavc = UINavigationController.init(rootViewController: detail);
//        var model:AnyObject? = nil;
        if (infoMaterialType == 0) {
            let model = self.filteredListContent[indexPath.section] as! InfoMaterialModel
            detail.code = model.Code!
            detail.titleName = model.Code! as NSString
            detail.dataInfoDetailType = .dataInfoDetailCar;
            detail.isPresnet = true
            self.present(dataNavc, animated: true, completion: nil)
        }
        else if (infoMaterialType == 1) {
            let model = self.filteredListContent[indexPath.section] as! InfoEquipmentMaterialModel
            detail.equipmentModel = model
            detail.isPresnet = true
            detail.titleName = model.equipmentno! as NSString
            detail.dataInfoDetailType = .dataInfoDetailEquipment;
            self.present(dataNavc, animated: true, completion: nil)
        }
        else if (infoMaterialType == 2) {
            let model = self.filteredListContent[indexPath.section] as! InfoCustomerIntentMaterialModel
            event.addCustomerNeedInfoModel = model;
            event.eventType = .customerNeedInfo;
            event.isPresent = true
            self.present(navc, animated: true, completion: nil);
        }
        else {
            let model = self.filteredListContent[indexPath.section] as! EnergyMeterReadingModel
            event.energyMeterReadingModel = model;
            event.eventType = .energyMeterUnit;
            event.isPresent = true
            self.present(navc, animated: true, completion: nil);
        }
//        event.energyMeterReadingModel = model as! EnergyMeterReadingModel;
        
        
        
        if self.block != nil {
//            self.block!(model);
        }
        
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func changeOffSet() {
//        self.contentTableView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        refreshSetHeaderFooterUI(frame: CGRect(x:0,y:60,width:kScreenWidth,height:kScreenHeight - 60), hasHeader: false, hasFooter: false);
    }

}
