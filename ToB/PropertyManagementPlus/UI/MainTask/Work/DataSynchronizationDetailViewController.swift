//
//  DataSynchronizationDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/21.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class DataSynchronizationDetailViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,DataSynchronizationManagerDelegate {

    @IBOutlet weak var contentTableView: UITableView!
    
    //,NSMutableArray(objects: "0","0","0","0","0","0","0","0","0"),NSMutableArray(objects: "0","0","0")
    var actionSelectItemValueArray = [NSMutableArray(objects: "0","0","0","0","0","0")]
    var tips = NSMutableArray(capacity: 20)
    var showTips = NSMutableArray(capacity: 20)
    
    var itemSyn = -1
    var indexSyn = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips.add("同步开始")
        
        DataSynchronizationManager.delegate = self
        findSynStart()

        self.setTitleView(titles: ["数据同步"])
        
        contentTableView.estimatedRowHeight = 0
        contentTableView.estimatedSectionHeaderHeight = 0
        contentTableView.estimatedSectionFooterHeight = 0
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        buttonAction(titles: ["返回","正在同步..."], actions: [#selector(pop),#selector(synchronization)], target: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showTips.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tip = showTips[indexPath.row] as! String
        
        if (indexPath.row%2 == 0 || tip.compare("同步开始") == .orderedSame) {
            //DataSynchronizationStartTableViewCell
            
            let cellID = "cellID"
            var startCell = tableView.dequeueReusableCell(withIdentifier: cellID)
            
            if startCell == nil {
                startCell = Bundle.main.loadNibNamed("DataSynchronizationStartTableViewCell", owner: nil, options: nil)?.first as! DataSynchronizationStartTableViewCell
            }
            
            let dataSynCell = startCell as! DataSynchronizationStartTableViewCell
            
            var array = tip.components(separatedBy: "@")
            
            dataSynCell.contentLabel.text = array[0]
            
            if (tip.compare("同步结束") == .orderedSame
                || tip.compare("同步开始") == .orderedSame) {
                dataSynCell.contentLabel.textColor = UIColor.black
                if (tip.compare("同步开始") == .orderedSame) {
                    dataSynCell.contentLabel.font = UIFont.systemFont(ofSize: 15)
                }else {
                    dataSynCell.contentLabel.font = UIFont.systemFont(ofSize: 18)
                }
            }else {
                dataSynCell.contentLabel.textColor = UIColor(red: 90.0/255.0, green: 255.0/255.0, blue: 54.0/255.0, alpha: 1.0)
                
            }
            
            return startCell!
        }
        
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = Bundle.main.loadNibNamed("DataSynchronizationEndTableViewCell", owner: nil, options: nil)?.first as! DataSynchronizationEndTableViewCell
        }
        
        let dataSynCell = cell as! DataSynchronizationEndTableViewCell
        
        var array = tip.components(separatedBy: "@")
        
        dataSynCell.tipLabel.text = array[0]
        if ((array.count) > 1) {
            dataSynCell.numberTipLabel.text = array[1]
        }
        
        if (dataSynCell.tipLabel.text?.contains("失败") == true) {
            dataSynCell.tipLabel.textColor = UIColor.red
        }else {
            dataSynCell.tipLabel.textColor = UIColor.darkGray
        }
        
        return cell!
    }
    
    @objc func synchronization() {
        
    }
    
    //MARK: DataSynchronizationManagerDelegate
    
    func startSynchronization(synchronizationType: NSInteger) {

        var tip = "开始同步["
        tip.append(name(synchronizationType: synchronizationType))
        tip.append("]信息")
        
        tips.add(tip)
        reverseTips()
    }
    
    func failSynchronization(synchronizationType: NSInteger) {

        var tip = "同步["
        tip.append(name(synchronizationType: synchronizationType))
        tip.append("]信息失败！@")
        
        tips.add(tip)
        reverseTips()
        findSynStart()
    }
    
    func endSynchronization(synchronizationType: NSInteger, itemNumber: NSString) {
        
        var tip = "同步["
        tip.append(name(synchronizationType: synchronizationType))
        tip.append("]信息成功！@")
        
        tip.append("共有[" + String(itemNumber) + "]条记录正在被存储......")
        tips.add(tip)
        reverseTips()
        findSynStart()
    }
    
    func synchronizationOver() {
        
        tips.add("同步结束")
        reverseTips()
        self.contentTableView.reloadData()
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
    }
    
    func name(synchronizationType: NSInteger) -> String {
        
        var tip = ""
        
        if (synchronizationType == 1) {
            tip.append("组织机构")
        }else if (synchronizationType == 2) {
            tip.append("房产结构")
        }else if (synchronizationType == 3) {
            tip.append("数据字典")
        }else if (synchronizationType == 4) {
            tip.append("同事")
        }else if (synchronizationType == 5) {
            tip.append("客户")
        }else if (synchronizationType == 6) {
            tip.append("外协单位")
        }
        
        return tip
        
    }
    
    func reverseTips() {
        
        showTips.removeAllObjects()
        
        for content in tips.reversed() {
            showTips.add(content)
        }
        self.contentTableView.reloadData()
    }
    
    func findSynStart() {
        
        var isExist = false
        
        for (item, array) in actionSelectItemValueArray.enumerated() {
            
            if (item < itemSyn) {
                continue
            }
            
            for (index, value) in array.enumerated() {
                
                if (index <= indexSyn) {
                    continue
                }
                
                if ((value as! String).compare("1") == .orderedSame) {
                    itemSyn = item
                    indexSyn = index
                    DataSynchronizationManager.startSynItem(item: itemSyn, index: indexSyn + 1)
                    isExist = true
                    break;
                }
                
            }
            
            if (isExist) {
                break;
            }
            
        }
        
        if (!isExist) {
            itemSyn = -1
            indexSyn = -1
            DataSynchronizationManager.startSynItem(item: -1, index: -1)
        }
        
    }
    
    override func pop() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
