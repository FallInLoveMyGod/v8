//
//  SafePatrolViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafePatrolViewController: BaseTableViewController {
    
    var dataSource = NSMutableArray(capacity: 20)
    var totalSource = NSMutableArray(capacity: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let select = totalSource[section] as! NSString
        return Int(select.intValue)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10.0
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var taskNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskNumberTableViewCell == nil {
            
            taskNumberTableViewCell = Bundle.main.loadNibNamed("TaskNumberTableViewCell", owner: nil, options: nil)?.first as! TaskNumberTableViewCell
            taskNumberTableViewCell?.selectionStyle = .none
            
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
            lineView.backgroundColor = UIColor.groupTableViewBackground
            taskNumberTableViewCell?.contentView.addSubview(lineView)
        }
        
        let tempCell: TaskNumberTableViewCell = taskNumberTableViewCell as! TaskNumberTableViewCell
        
        let dict = dataSource[indexPath.section] as! NSDictionary
        let array = dict["Lines"] as! NSArray
        if (indexPath.row == 0) {
            tempCell.accessoryType = .none
            tempCell.nameLabel.text = DataInfoDetailManager.shareInstance().safePatrol(withData: dict)
        }else {
            tempCell.accessoryType = .disclosureIndicator
            tempCell.nameLabel.text = (array[indexPath.row - 1] as! NSDictionary)["LineName"] as? String
            tempCell.leftMarginConstraint.constant = 30
        }
        
        return taskNumberTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dict = dataSource[indexPath.section] as! NSDictionary
        let array = dict["Lines"] as! NSArray
        
        if (indexPath.row != 0) {
            
            //跳转
            let detail = SafePatrolDetailViewController()
            detail.info = array[indexPath.row - 1] as! NSDictionary
            detail.projectInfo = dict
//            detail.linePK = dictNext["LinePK"] as! String
//            detail.secuchkProjectPK = dict["SecuchkProjectPK"] as! String
            self.push(viewController: detail)
            
        }else {
            
            let select = totalSource[indexPath.section] as! NSString
            
            if (select.compare("1") == .orderedSame) {
                totalSource[indexPath.section] = String(array.count + 1)
            }else {
                totalSource[indexPath.section] = "1"
            }
            
            self.contentTableView?.reloadData()
        }
        
    }
    
    func initData() {
        
        guard let _ = UserDefaults.standard.object(forKey: QuerySecuchkLinesKey) as? NSArray else {
            return
        }
        dataSource = NSMutableArray(array: UserDefaults.standard.object(forKey: QuerySecuchkLinesKey) as! NSArray)
        totalSource = NSMutableArray(capacity: 20)
        
        //Lines
        var index = 0
        for sub in dataSource {
            index = index + 1
            var subIndex = 1
            if let subDict = sub as? NSDictionary, let array = subDict["Lines"] as? NSArray {
                for _ in array {
                    subIndex += 1
                }
            }
            totalSource.add(String(subIndex))
        }
        self.contentTableView?.reloadData()
    }
    
    func createUI() {
        
        self.setTitleView(titles: ["选择巡检项目"])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49), hasHeader: false, hasFooter: false)
        
        contentTableView?.separatorStyle = .none
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
}
