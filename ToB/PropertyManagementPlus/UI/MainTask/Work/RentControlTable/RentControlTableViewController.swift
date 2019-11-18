//
//  RentControlTableViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import Alamofire

class RentControlTableViewController: BaseTableViewController,LMReportViewDatasource,LMReportViewDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var reportView = LMReportView()
    var rentControlScrollView = RentControlScrollView()
    var hud: MBProgressHUD = MBProgressHUD()
    
    
    var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var stateDescArray: NSMutableArray = NSMutableArray(capacity: 20)
    var reportArray: NSMutableArray = NSMutableArray(capacity: 20)
    var reportDictionary: NSDictionary = NSDictionary(dictionary: ["cols":"0","rows":"0"])
    
    var buildIndex = 0
    var roomIndex = -1
    var tempDataSource:NSMutableArray = NSMutableArray();
    
    let tableHeight = 88 + 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 8;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if materialDataInfoDetailTableViewCell == nil {
            
            materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
            materialDataInfoDetailTableViewCell?.selectionStyle = .none
            
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
            lineView.backgroundColor = UIColor.groupTableViewBackground
            materialDataInfoDetailTableViewCell?.contentView.addSubview(lineView)
        }
        
        let tempCell: MaterialDataInfoDetailTableViewCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
        
        let model = self.customerDataSource[buildIndex] as! HouseStructureModel
        
        if (indexPath.row == 0) {
            tempCell.nameLabel.text = "楼盘"
            tempCell.contentLabel.text = model.Name ?? ""
        }else {
            
            if (roomIndex != -1) {
                tempCell.contentLabel.text = (tempDataSource[roomIndex] as! NSDictionary)["Name"] as? String
            }else {
                tempCell.contentLabel.text = ""
            }
            
            tempCell.nameLabel.text = "楼阁"
        }
        
        return materialDataInfoDetailTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var titles = Array<Any>()
        var index = 0
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                for model in self.customerDataSource {
                    let tempModel: HouseStructureModel = model as! HouseStructureModel
                    titles.insert(tempModel.Name ?? "", at: index)
                    index = index + 1
                }
                showActionSheet(title: "选择楼盘", cancelTitle: "取消", titles: titles, tag: "1357")
            }else {
                tempDataSource .removeAllObjects();
                let tempModel = self.customerDataSource[buildIndex] as! HouseStructureModel
                let ldArr = NSMutableArray();
                let otherArr = NSMutableArray();
                for tempDict in tempModel.PBuildings! {
                    let dic = tempDict as! NSDictionary;
//                    if (dic.allKeys as NSArray).contains("buildType") {
                        let str:String = dic["buildType"] as! String;
                        if str == "楼栋" {
                            ldArr.add(tempDict);
                        }
                        else {
                            otherArr.add((tempDict as! NSDictionary)["Name"] ?? "")
                            tempDataSource.add(tempDict);
                        }
//                    }
//                    else {
//                       otherArr.add((tempDict as! NSDictionary)["Name"] ?? "")
//                    }
                }
                let arr = ldArr.sorted { (obj1, obj2) -> Bool in
                    let dic1 = obj1 as! NSDictionary;
                    let dic2 = obj2 as! NSDictionary;
                    if dic1["Code"] as! String > dic2["Code"] as! String {
                        return true
                    }
                    else {
                        return false
                    }
                }
                for tempDic in arr {
                    print((tempDic as! NSDictionary)["Code"]!);
                    otherArr.insert((tempDic as! NSDictionary)["Name"] ?? "", at: 0);
                    tempDataSource.insert(tempDic as! NSDictionary, at: 0)
                }
                titles = otherArr as! [Any];
                
                showActionSheet(title: "选择楼阁", cancelTitle: "取消", titles: titles, tag: "1377")
            }
        }
    }
    
    
    //MARK:  LMReportViewDatasource
    
    func numberOfRows(in reportView: LMReportView!) -> Int {
        if (self.reportArray.count == 0) {
            return 0
        }
        return Int(BaseTool.toStr(self.reportDictionary["cols"]))!
    }
    
    func numberOfCols(in reportView: LMReportView!) -> Int {
        if (self.reportArray.count == 0) {
            return 0
        }
        return Int(BaseTool.toStr(self.reportDictionary["rows"]))!
    }
    
    func reportView(_ reportView: LMReportView!, gridAt indexPath: IndexPath!) -> LMRGrid! {
        let grid = LMRGrid()

        print("indexPath.section:\(indexPath.section)")
        print("indexPath.row:\(indexPath.row)")
        
        let datas = self.reportArray[indexPath.section] as! NSArray
        
        if (datas.count - 1 < indexPath.row) {
            grid.text = ""
            grid.backgroundColor = UIColor.white
        }else {
            let result = datas[indexPath.row] as! NSDictionary
            grid.text = result["name"] as! String
            grid.backgroundColor = BaseTool.color(withHexString: result["color"] as! String)
        }
        return grid
    }
    
    //MARK: LMReportViewDelegate
    
    func reportView(_ reportView: LMReportView!, didTap label: LMRLabel!) {
        print("indexPath.section:\(label.indexPath.section)")
        print("indexPath.row:\(label.indexPath.row)")
        
        let datas = self.reportArray[label.indexPath.section] as! NSArray
        
        if (datas.count - 1 < label.indexPath.row || label.indexPath.row == 0) {
            
        }else {
            let result = datas[label.indexPath.row] as! NSDictionary
            print(result)
            
            let tenantName: String = "租户名称：".appending(result["tenantName"] as! String).appending("\n")
            let brandName: String = "经营品牌：".appending(result["brandName"] as! String).appending("\n")
            let rentStartDate: String = "合同起始日期：".appending(result["rentStartDate"] as! String).appending("\n")
            let rentEndDate: String = "合同终止日期：".appending(result["rentEndDate"] as! String).appending("\n")
            
            var advanceEnd = "是"
            if (BaseTool.toStr(result["advanceEnd"]).compare("0") == .orderedSame) {
                advanceEnd = "否"
            }
            
            let advanceEndVert: String = "是否提前退租：".appending(advanceEnd).appending("\n")
            let tip = tenantName.appending(brandName).appending(rentStartDate).appending(rentEndDate).appending(advanceEndVert)
            
            let tipAlertView: UIAlertController = UIAlertController(title: "房间号：  ".appending(result["name"] as! String), message: tip, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
                (action: UIAlertAction) -> Void in
            })
            let confirmAction = UIAlertAction(title: "更多详细信息", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                self.moreInfomation(code: result["code"] as! String)
            })
            tipAlertView.addAction(cancelAction)
            tipAlertView.addAction(confirmAction)
            self.present(tipAlertView, animated: true, completion: {})
            
        }
    }
    
    func createUI() {
        
        self.setTitleView(titles: ["租控表" as NSString])
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: Int(kScreenWidth), height: tableHeight), hasHeader: false, hasFooter: false)
        contentTableView?.isScrollEnabled = false
        contentTableView?.separatorStyle = .none
        
        reportView.datasource = self
        reportView.delegate = self
        reportView.style = LMRStyle.default()
        self.view.addSubview(reportView)
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
    }
    
    func moreInfomation(code: String) {
        let detail = DataInfoDetailViewController()
        detail.dataInfoDetailType = .dataInfoRentControl
        detail.code = code
        self.push(viewController: detail)
    }
    
    func loadData() {
        
        self.customerDataSource.removeAllObjects()
        
        let response = UserDefaults.standard.object(forKey: HouseStructureDataSynchronization)
        
        let dict = JSON(response ?? {})
        
        for (_,tempDict) in dict["PProjects"] {
            
            if let houseStructureModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                self.customerDataSource.add(houseStructureModel)
            }
            
        }
        
    }
    
    override func requestData() {
        super.requestData()
        
        hud.label.text = "正在加载租控表信息"
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)

        
        let model = self.customerDataSource[buildIndex] as! HouseStructureModel
        
//        let resultDictionary = (model.PBuildings?[roomIndex] as! NSDictionary)
        let resultDictionary = (tempDataSource[roomIndex] as! NSDictionary)
        
        let getrentstatesummaryAPICmd = GetrentstatesummaryAPICmd()
        getrentstatesummaryAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        print(resultDictionary);
        getrentstatesummaryAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","pbuildingcode":(resultDictionary["Code"] as! String) ]
        getrentstatesummaryAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功

        
                let array = (response as! NSDictionary)["stateDesc"] as! NSArray
                self.stateDescArray = NSMutableArray(array: array)
        
                self.rentControlScrollView.removeFromSuperview()
                self.rentControlScrollView = RentControlScrollView(frame: CGRect(x: 0, y: self.tableHeight + 10, width: Int(kScreenWidth), height: 60), titles: self.stateDescArray)
                self.view.addSubview(self.rentControlScrollView)
                
                self.requestGetrentstatetable()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            self.stopFresh()
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
        
    }
    
    func requestGetrentstatetable() {
        let model = self.customerDataSource[buildIndex] as! HouseStructureModel
        
        let resultDictionary = (tempDataSource[roomIndex] as! NSDictionary)
        
        let getrentstatetableAPICmd = GetrentstatetableAPICmd()
        getrentstatetableAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getrentstatetableAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","pbuildingcode":(resultDictionary["Code"] as! String) ]
        getrentstatetableAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.reportDictionary = (response as! NSDictionary)
                self.reportArray = NSMutableArray(array: (self.reportDictionary["stateTable"]) as! NSArray)
//                self.reportArray.insert(self.reportArray[0], at: 0)
                self.reportView.frame = CGRect(x: 0, y: (self.rentControlScrollView.frame.origin.y) + 70, width: kScreenWidth, height: kScreenHeight - ((self.rentControlScrollView.frame.origin.y) + 70) - 10)
                self.reportView.reloadData()
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            self.stopFresh()
            self.hud.hide(animated: true)
        }) { (response) in
            self.hud.hide(animated: true)
            LocalToastView.toast(text: DisNetWork)
            self.stopFresh()
        }
    }
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if (tag.compare("1357") == .orderedSame) {
            buildIndex = buttonIndex - 1
            roomIndex = -1
        }else {
            roomIndex = buttonIndex - 1
            self.requestData()
        }
        
        self.contentTableView?.reloadData()
    }
}
