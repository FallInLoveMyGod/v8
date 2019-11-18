//
//  SafeCheckViewController.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import ObjectMapper

class SafeCheckViewController: BaseTableViewController {

    fileprivate var lat: CLLocationDegrees?
    fileprivate var lon: CLLocationDegrees?
    fileprivate var topLineView: SafeCheckTopLineView?
    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    fileprivate var dataSource: [SafeCheckHouseModel] = []
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createContentUI()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTopData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func createContentUI() {
        
        self.setTitleView(titles: ["安全检查"])
        
        topLineView = SafeCheckTopLineView(frame: CGRect(x: 0, y: 8, width: kScreenWidth, height: 40))
        self.view.addSubview(topLineView!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickLocationTitle(tap:)))
        self.topLineView?.isUserInteractionEnabled = true
        self.topLineView?.addGestureRecognizer(tap)
        
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        contentTableView?.register(SafeCheckListTableViewCell.self, forCellReuseIdentifier: "SafeCheckListTableViewCell")
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: CGFloat((topLineView?.height)! + (topLineView?.top)!), width: kScreenWidth, height: kScreenHeight - kNavbarHeight - 50 - (topLineView?.height)! - 16), hasHeader: true, hasFooter: true)
        buttonAction(titles: ["返回", "更新标准", "定位"], actions: [#selector(pop), #selector(update), #selector(location)], target: self)
        
        self.view.bringSubview(toFront: topLineView!)
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        floatingView.iconImageView.image = UIImage(named: "icon_sys_pressed")
        
        floatingView.delegate = self
        self.view.addSubview(floatingView)
    }
    
    @objc func clickLocationTitle(tap: UIGestureRecognizer) {
        let unCommitVC = SafeCheckUnCommitViewController()
        self.push(viewController: unCommitVC)
    }
    
    @objc fileprivate func location() {
        let manager = LocationManager.share()
        manager?.locationResult = { [weak self] (lat, lon) in
            guard let `self` = self else { return }
            self.lat = lat
            self.lon = lon
            self.reloadData()
        }
        manager?.location()
    }
    
    @objc fileprivate func isAppendDatas(lat: Double, lng: Double) -> Bool {
//        if fabs(lat - Double(self.lat!)) <= 0.001 && fabs(lng - Double(self.lon!)) <= 0.001 {
//            return true
//        }
        if fabs(lat - Double(self.lat!)) <= 100 && fabs(lng - Double(self.lon!)) <= 100 {
            return true
        }
        return false
    }
    
    /*
    fileprivate func fetchModelDatas(section: Int, row: Int) -> (SafeCheckHouseModel?, SafeCheckBuildHouseModel?, SafeCheckFloorHouseModel?, SafeCheckHouseRoomModel?) {
        let safeCheckHouseModel = self.dataSource[section]
        var buildModel: SafeCheckBuildHouseModel?
        var floorModel: SafeCheckFloorHouseModel?
        var roomModel: SafeCheckHouseRoomModel?
        var index = 0
        for build in safeCheckHouseModel.PBuildings {
            for floor in build.PFloors {
                let lat = BaseTool.toFloat(floor.LAT)
                let lng = BaseTool.toFloat(floor.LNG)
                if isAppendDatas(lat: Double(lat), lng: Double(lng)) {
                    for room in floor.PRooms {
                        if index == row {
                            buildModel = build
                            floorModel = floor
                            roomModel = room
                            break
                        }
                        index += 1
                    }
                    if floorModel != nil {
                        break
                    }
                }
            }
            if buildModel != nil {
                break
            }
        }
        return (safeCheckHouseModel, buildModel, floorModel, roomModel)
    }
 */
    fileprivate func fetchModelDatas(section: Int, row: Int) -> (SafeCheckHouseModel?, SafeCheckBuildHouseModel?, SafeCheckFloorHouseModel?, SafeCheckHouseRoomModel?) {
        let safeCheckHouseModel = self.dataSource[section]
        var buildModel: SafeCheckBuildHouseModel?
        var floorModel: SafeCheckFloorHouseModel?
        var roomModel: SafeCheckHouseRoomModel?
        var index = 0
        for build in safeCheckHouseModel.PBuildings {
            for floor in build.PFloors {
                for room in floor.PRooms {
                    let lat = BaseTool.toFloat(room.LAT)
                    let lng = BaseTool.toFloat(room.LNG)
                    if isAppendDatas(lat: Double(lat), lng: Double(lng)) {
                        if index == row {
                            buildModel = build;
                            floorModel = floor;
                            roomModel = room;
                            break;
                        }
                        index += 1;
                    }
                }
                if floorModel != nil {
                    break;
                }
//                let lat = BaseTool.toFloat(floor.LAT)
//                let lng = BaseTool.toFloat(floor.LNG)
//                if isAppendDatas(lat: Double(lat), lng: Double(lng)) {
//                    for room in floor.PRooms {
//                        if index == row {
//                            buildModel = build
//                            floorModel = floor
//                            roomModel = room
//                            break
//                        }
//                        index += 1
//                    }
//                    if floorModel != nil {
//                        break
//                    }
//                }
            }
            if buildModel != nil {
                break
            }
        }
        return (safeCheckHouseModel, buildModel, floorModel, roomModel)
    }
    
    override func requestData() {
        super.requestData()
        location()
        update()
    }
    
    @objc fileprivate func refreshTopData() {
        if SafeCheckResultModel.findAllExceptions(["Contents"]).count != 0 {
            let uncommit = SafeCheckUnCommitViewController()
            let count = uncommit.fetchSortDatas().count
            topLineView?.numberLabel.text = "\(count)"
        } else {
            topLineView?.numberLabel.text = ""
        }
    }
    
    @objc fileprivate func reloadData() {
        refreshTopData()
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFmt.string(from: Date())
        let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
        
        LoadView.storeLabelText = "正在加载房产信息"
        
        let safeCheckGetHouseStructure = SafeCheckGetHouseStructure()
        safeCheckGetHouseStructure.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        safeCheckGetHouseStructure.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "", "version": "8.2", "BeginDate": dateForeStr as! String]
        safeCheckGetHouseStructure.loadView = LoadView()
        safeCheckGetHouseStructure.loadParentView = self.view
        safeCheckGetHouseStructure.transactionWithSuccess({ [weak self] (response) in
            guard let `self` = self else { return }
            
            let dict = JSON(response)
            print(dict)
            let resultStatus = dict["result"].string
            
            if resultStatus == "success"  {
                self.dataSource.removeAll()
                for tempDict in dict["PProjects"] {
                    let itemModel = Mapper<SafeCheckHouseModel>().map(JSONString: tempDict.1.rawString()!)
//                    SafeCheckHouseModel
                    self.dataSource.append(itemModel!)
                    self.contentTableView?.reloadData()
                }
            } else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            self.stopFresh()
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
    }
    
    @objc fileprivate func update() {
        
        LoadView.storeLabelText = "正在加载安全检查信息"
        
        let safeCheckUpdateStandardAPICmd = SafeCheckUpdateStandardAPICmd()
        safeCheckUpdateStandardAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        safeCheckUpdateStandardAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","version":"8.2"]
        safeCheckUpdateStandardAPICmd.loadView = LoadView()
        safeCheckUpdateStandardAPICmd.loadParentView = self.view
        safeCheckUpdateStandardAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string

            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功

                SafeCheckItemModel.clearTable()
                SafeCheckDInfosModel.clearTable()
                SafeCheckPInfosModel.clearTable()

                for (_,tempDict) in dict["items"] {

                    if let itemModel:SafeCheckItemModel = SafeCheckItemModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        itemModel.save()
                    }

                }

                for (_,tempDict) in dict["dinfos"] {

                    if let dinfoModel:SafeCheckDInfosModel = SafeCheckDInfosModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        dinfoModel.save()
                    }

                }

                for (_,tempDict) in dict["pinfos"] {

                    if let pinfoModel:SafeCheckPInfosModel = SafeCheckPInfosModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        pinfoModel.save()
                    }

                }
                self.contentTableView?.reloadData()
                LocalToastView.toast(text: "同步完成")
            } else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            self.stopFresh()
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
    }
    
    func jump(section: Int, row: Int) {
        
        let tuples = self.fetchModelDatas(section: section, row: row)
        let start = SafeCheckStartViewController()
        var items: [SafeCheckItemModel] = []
        for item in SafeCheckItemModel.findAll() {
            let itemModel = item as! SafeCheckItemModel
            items.append(itemModel)
        }
        start.items = items
        var pinfos: [SafeCheckPInfosModel] = []
        for item in SafeCheckPInfosModel.findAll() {
            let itemModel = item as! SafeCheckPInfosModel
            pinfos.append(itemModel)
        }
        start.pinfos = pinfos
        start.tuples = tuples
        //(SafeCheckHouseModel?, SafeCheckBuildHouseModel?, SafeCheckFloorHouseModel?, SafeCheckHouseRoomModel?)
        let roomModel = tuples.3
        start.name = roomModel?.Name ?? ""
        start.pRoomCode = tuples.3?.Code ?? ""
        start.itemAssociateCode = "\(tuples.0?.Name ?? "")-\(tuples.0?.Code ?? ""):\(tuples.1?.Name ?? "")-\(tuples.1?.Code ?? ""):\(tuples.2?.Name ?? "")-\(tuples.2?.PUnitCode ?? ""):\(tuples.3?.TenantName ?? "")-\(tuples.3?.Name ?? "")-\(tuples.3?.Code ?? "")"
        self.push(viewController: start)
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
          print(self.dataSource.count)
        return self.dataSource.count
      
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var totalCount = 0
        let model = self.dataSource[section]
        print(model.Code)
        for build in model.PBuildings {
            for floor in build.PFloors {
                for room in floor.PRooms {
                    let lat = BaseTool.toFloat(room.LAT)
                    let lng = BaseTool.toFloat(room.LNG)
                    if isAppendDatas(lat: Double(lat), lng: Double(lng)) {
                        totalCount += floor.PRooms.count
                    }
                }
            }
        }
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8.0
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SafeCheckListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SafeCheckListTableViewCell") as? SafeCheckListTableViewCell
        cell = (SafeCheckListTableViewCell.reuseNib.instantiate(withOwner: self, options: nil)).first as? SafeCheckListTableViewCell
        let tuples = self.fetchModelDatas(section: indexPath.section, row: indexPath.row)
        let _ = tuples.0
        let _ = tuples.1
        let floorModel = tuples.2
        let roomModel = tuples.3
        cell?.nameLabel.text = "\(roomModel?.TenantName ?? "")"
        cell?.subNameLabel.text = "\(floorModel?.PFloorName ?? "")/\(roomModel?.Name ?? "")"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        jump(section: indexPath.section, row: indexPath.row)
    }

}

extension SafeCheckViewController: FJFloatingViewDelegate {
    func floatingViewClick() {
        let qrcodeVC:QRCodeScanViewController = QRCodeScanViewController()
        qrcodeVC.scanType = .safeCheck
        qrcodeVC.scanDelegate = self
        self.push(viewController: qrcodeVC)
    }
}

extension SafeCheckViewController: ScanResultDelegate {
    func scan(result: String) {
        
        var roomCode = "-10000"
        
        for dinfo in SafeCheckDInfosModel.findAll() {
            let dInfoModel = dinfo as! SafeCheckDInfosModel
            if dInfoModel.FlagNo == result {
                roomCode = dInfoModel.RoomCode
            }
        }
        
        if roomCode == "-10000" {
            return
        }
        
        var sectionOut = -1
        var rowOut = -1
        for (section, model) in self.dataSource.enumerated() {
            var totalCount = 0
            for build in model.PBuildings {
                for floor in build.PFloors {
                    let lat = BaseTool.toFloat(floor.LAT)
                    let lng = BaseTool.toFloat(floor.LNG)
                    if isAppendDatas(lat: Double(lat), lng: Double(lng)) {
                        for (row, room) in floor.PRooms.enumerated() {
                            if room.Code == roomCode {
                                sectionOut = section
                                rowOut = row
                                break
                            }
                        }
                        totalCount += floor.PRooms.count
                    }
                }
                if sectionOut != -1 && rowOut != -1 {
                    break
                }
            }
            if sectionOut != -1 && rowOut != -1 {
                break
            }
        }
        jump(section: sectionOut, row: rowOut)
    }
}
