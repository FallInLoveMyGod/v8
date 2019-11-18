//
//  EquipmentPatrolDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/8/20.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

open class EquipmentPatrolDetailViewController: BaseTableViewController {

    var dInfoModel: EquipmentPatrolGroupDInfosModel?
    
    fileprivate var dataSource: [EquipmentPatrolGroupModel] = []
    
    fileprivate let equipmentPatrolTag = 77
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        initData()
        createUI()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initData() {
        let sql = "  WHERE PollingPK = '".appending(dInfoModel?.PollingPK ?? "").appending("'")
        //let noCommitSQL = sql.appending(" AND isCommit = '0'")
        dataSource = EquipmentPatrolGroupModel.find(byCriteria: sql) as! [EquipmentPatrolGroupModel]
    }
    
    func createUI() {
        
        if let equipmentName = dInfoModel?.EquipmentName {
            self.setTitleView(titles: [equipmentName as NSString])
        }
    
        let managementItemView = ManagementItemView(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: 40), titles: ["序号","巡检项目","巡检时间","状态"], width:50)
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: (managementItemView?.frame.size.height)!, width: kScreenWidth, height: kScreenHeight - 49 - (managementItemView?.frame.size.height)!), hasHeader: false, hasFooter: false)
        
        self.view.addSubview(managementItemView!)
        
        contentTableView?.separatorStyle = .none
        self.contentTableView?.reloadData()
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.selectionStyle = .none
        }
        
        let safePatrolDetailView = SafePatrolDetailView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44.0), width: 50.0, count: 4)
        safePatrolDetailView?.tag = equipmentPatrolTag
        
        if let subViews = cell?.contentView.subviews {
            for subView in subViews {
                if subView is SafePatrolDetailView {
                    subView.removeFromSuperview()
                }
            }
        }
        
        let itemModel = dataSource[indexPath.row]
        
        var startTime = ""
        if let time = itemModel.FinishTime, time != "" {
            let times = time.components(separatedBy: " ")[1].components(separatedBy: ":")
            startTime = times[0].appending(":").appending(times[1])
        }
        
        let commitStatus = itemModel.isCommit == "0" ? "未提交" : "已提交"
        let colorStatus = itemModel.isCommit == "0" ? UIColor.red : UIColor.darkText
        
        safePatrolDetailView?.reload(withTitles: [
            String(indexPath.row + 1),
            dInfoModel?.EquipmentName ?? "",
            startTime,
            commitStatus], image:"", colors:[UIColor.darkText,UIColor.darkText,UIColor.darkText,colorStatus])
        safePatrolDetailView?.delegate = self
        safePatrolDetailView?.tag = indexPath.row + 1000
        cell?.contentView.addSubview(safePatrolDetailView!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(indexPath: indexPath)
    }

}

extension EquipmentPatrolDetailViewController {
    func didSelect(indexPath: IndexPath) {
        let modify = EquipmentPatrolGroupStartViewController()
        let itemModel = dataSource[indexPath.row]
        let datas = BaseTool.dictionary(withJsonString: itemModel.jsonContent) as! [NSDictionary]
        
        var contentModels = Array<EquipmentPatrolGroupConentModel>()
        for tempDict in datas {
            
            if let itemModel:EquipmentPatrolGroupConentModel = EquipmentPatrolGroupConentModel.yy_model(withJSON: BaseTool.toJson(tempDict)) {
                contentModels.append(itemModel)
            }
            
        }
        itemModel.Contents = contentModels
        
        modify.contents = [itemModel]
        if itemModel.isCommit == "1" {
            return
        }
        self.push(viewController: modify)
    }
}

extension EquipmentPatrolDetailViewController: SafePatrolDetailViewDelegate {
    public func selectSafePatrolDetailViewItem(_ tag: Int) {
        didSelect(indexPath: IndexPath(row: tag, section: 0))
    }
}

