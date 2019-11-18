//
//  EquipmentPatrolGroupViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class EquipmentPatrolGroupViewController: BaseTableViewController {

    var scanResult = ""
    var dataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var itemDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var itemResult = NSDictionary()
    var selectedSegmentIndex: Int = 0
    var rowSectionSelected: Int = 0
    
    //展开控制
    var expandControlProject = [String]()
    var expandControlItem = [String]()
    
    var expandControlSelectProject = [[String]]()
    var expandControlSelectItem = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedSegmentIndex == 1 {
            return dataSource.count != 0 ? 1 : 0
        }
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegmentIndex == 0 {
            if expandControlProject[section] == "1" {
                return 1
            }
            return (itemDataSource[section] as! NSArray).count + 1
        }
        if expandControlItem[section] == "1" {
            return 1
        }
        return (itemDataSource[section] as! NSArray).count + 1
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = Bundle.main.loadNibNamed("EquipmentPatrolGroupTableViewCell", owner: nil, options: nil)?.first as! EquipmentPatrolGroupTableViewCell
            cell?.selectionStyle = .none
        }
        
        let tempCell: EquipmentPatrolGroupTableViewCell = cell as! EquipmentPatrolGroupTableViewCell
        tempCell.tag = indexPath.section * 1000 + indexPath.row + 1
        tempCell.delegate = self
        
        if (indexPath.row == 0) {
            if selectedSegmentIndex == 0 {
                tempCell.nameLabel.text = (dataSource[indexPath.section] as! NSDictionary)["ProjectName"] as? String
            } else {
                tempCell.nameLabel.text = (dataSource[indexPath.section] as! NSDictionary)["EquipmentName"] as? String
            }
        }else {
            
            tempCell.leftArrowImageView.isHidden = true
            
            tempCell.leadConstraint.constant = 30
            
            let dict = (itemDataSource[indexPath.section] as! NSArray)[indexPath.row - 1] as! NSDictionary
            
            if selectedSegmentIndex == 0 {
                
                tempCell.nameLabel.text = (dict["EquipmentName"] as? String)?.appending("(").appending((dict["EquipmentCode"] as? String)!).appending(")")
            }else {
                
                tempCell.nameLabel.text = (dict["ProjectName"] as? String)?.appending("(").appending((dict["ProjectCode"] as? String)!).appending(")")
            }

        }
        
        if (expandControlProject.count > indexPath.section && expandControlProject[indexPath.section] == "1")
            || (expandControlItem.count > indexPath.section && expandControlItem[indexPath.section] == "1") {
            tempCell.arrowImageName = "more_unfold"
        }else {
            tempCell.arrowImageName = "less"
        }
        
        if selectedSegmentIndex == 0 {
            if expandControlSelectProject.count > indexPath.section && expandControlSelectProject[indexPath.section][indexPath.row] == "1" {
                tempCell.selectImageName = "checked"
            } else {
                tempCell.selectImageName = "unchecked"
            }
        } else {
            if expandControlSelectItem.count > indexPath.section && expandControlSelectItem[indexPath.section][indexPath.row] == "1" {
                tempCell.selectImageName = "checked"
            } else {
                tempCell.selectImageName = "unchecked"
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedSegmentIndex == 0 {
            
            if (indexPath.row == 0) {
                if expandControlProject[indexPath.section].compare("1") == .orderedSame {
                    expandControlProject[indexPath.section] = "0"
                }else {
                    expandControlProject[indexPath.section] = "1"
                }
            }
            
        }else {
            if (indexPath.row == 0) {
                if expandControlItem[indexPath.section].compare("1") == .orderedSame {
                    expandControlItem[indexPath.section] = "0"
                }else {
                    expandControlItem[indexPath.section] = "1"
                }
            }
            
        }
        
        tableView.reloadData()
    }
    
    func initData() {
        
    }
    
    func createUI() {
        
        self.setTitleView(titles: ["选择巡检标准"])
        
        self.initSegmentView(titles: ["项目分组","对象分组"])
        segmentView.frame = CGRect(x: 50, y: 8, width: kScreenWidth - 100, height: 30)
        
        
        let backView = UIView(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: 46))
        backView.backgroundColor = kThemeColor
        backView.addSubview(segmentView)
        self.view.addSubview(backView)
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: backView.frame.origin.y + backView.frame.size.height, width: kScreenWidth, height: kScreenHeight - 89), hasHeader: false, hasFooter: false)
        
        contentTableView?.separatorStyle = .none
        
        buttonAction(titles: ["返回","开始巡检"], actions: [#selector(pop),#selector(startPatrol)], target: self)
        
        self.contentTableView?.reloadData()
    }
    
    @objc func startPatrol() {
        let start = EquipmentPatrolGroupStartViewController()
        let project: NSMutableArray = NSMutableArray()
        let item: NSMutableArray = NSMutableArray()
        var index = 0
        if selectedSegmentIndex == 0 {
            for projectContent in dataSource {
                
                var subIndex = 1
                for equips in (itemDataSource[index] as! NSArray) {
                    
                    if expandControlSelectProject[index][subIndex] == "1"{
                        project.add(projectContent)
                        item.add(equips)
                    }
                    subIndex = subIndex + 1
                }
                
                index = index + 1
            }
        } else {
            //项目
            for subArray in itemDataSource {
                
                var subIndex = 1
                for sub in (subArray as! NSArray) {
                    if expandControlSelectItem[index][subIndex] == "1" {
                        project.add(sub)
                        item.add(dataSource[index])
                    }
                    subIndex = subIndex + 1
                }
                
                index = index + 1
            }
        }
        if project.count == 0 {
            LocalToastView.toast(text: "没有选择任何标准")
            return 
        }
        start.result = project
        start.item = item
        //条件定义
        start.pInfo = itemResult["Pinfo"] as! NSArray
        self.push(viewController: start)
    }
    
    func selectControl(index: Int) {
        
        let indexSection = index / 1000
        let indexRow = index % 1000
        
        if selectedSegmentIndex == 0 {
            //项目分组
            var item = "0"
            
            if expandControlSelectProject[indexSection][0] == "0" {
                item = "1"
            }
            
            if indexRow == 0 {
                var subIndex = 0
                for _ in expandControlSelectProject[indexSection] {
                    expandControlSelectProject[indexSection][subIndex] = item
                    subIndex = subIndex + 1
                }
            } else {
                let value = expandControlSelectProject[indexSection][indexRow]
                expandControlSelectProject[indexSection][indexRow] = value == "0" ? "1" :"0"
                expandControlSelectProject[indexSection][0] = "0"
            }
            
            var selectIndex = 0
            var isExistZore = false
            for str in expandControlSelectProject[indexSection] {
                if str == "0" && selectIndex != 0 {
                    isExistZore = true
                    break
                }
                selectIndex = selectIndex + 1
            }
            
            if !isExistZore {
                expandControlSelectProject[indexSection][0] = "1"
            }
            
            
        }else {
            
            var item = "0"
            
            //对象分组
            if expandControlSelectItem[indexSection][0] == "0" {
                item = "1"
            }
            
            if indexRow == 0 {
                var subIndex = 0
                for _ in expandControlSelectItem[indexSection] {
                    expandControlSelectItem[indexSection][subIndex] = item
                    subIndex = subIndex + 1
                }
            } else {
                let value = expandControlSelectItem[indexSection][indexRow]
                expandControlSelectItem[indexSection][indexRow] = value == "0" ? "1" :"0"
                expandControlSelectItem[indexSection][0] = "0"
            }
            
            var selectIndex = 0
            var isExistZore = false
            for str in expandControlSelectItem[indexSection] {
                if str == "0" && selectIndex != 0 {
                    isExistZore = true
                    break
                }
                selectIndex = selectIndex + 1
            }
            
            if !isExistZore {
                expandControlSelectItem[indexSection][0] = "1"
            }
            
            
        }
        
        contentTableView?.reloadData()
        
    }
    
    func selectProject(index: Int) {
        var i = 1
        for _ in dataSource {
            expandControlSelectProject[i][0] = (index == 1 ? "1" : "0")
            i = i + 1
        }
    }
    
    func fetchData(type: Int) {
        
        itemResult = DataInfoDetailManager.shareInstance().fetchEquipmentPatrol(withData: UserDefaults.standard.object(forKey: QueryInspectionItemsKey), type: type, key: scanResult) as NSDictionary
        
        dataSource = NSMutableArray(array: (itemResult["Projects"] as! NSArray))
        itemDataSource = NSMutableArray(array: (itemResult["Item"] as! NSArray))
        
        print(itemDataSource)
        print(dataSource)
        
        expandControlItem.removeAll()
        expandControlProject.removeAll()
        expandControlSelectItem.removeAll()
        expandControlSelectProject.removeAll()
        for _ in dataSource {
            expandControlProject.append("0")
            expandControlItem.append("0")
            
            var items = [String]()
            items.append("0")
            for _ in itemDataSource {
                items.append("0")
            }
            if selectedSegmentIndex == 1 {
                items.append("0")
            }
            expandControlSelectItem.append(Array(items))
            expandControlSelectProject.append(Array(items))
        }
        self.contentTableView?.reloadData()
    }
    
    override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        print(segmentView.selectedSegmentIndex)
        selectedSegmentIndex = segmentView.selectedSegmentIndex
        fetchData(type: segmentView.selectedSegmentIndex)
    }

}

extension EquipmentPatrolGroupViewController: GroupSelectDelegte {
    func check(index: Int) {
        self.selectControl(index: index - 1)
    }
}
