//
//  DataSynchronizationViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class DataSynchronizationViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,RSCheckGroupDelegate {


    @IBOutlet weak var contentTableView: UITableView!
    
    //,"0","0"
    var actionSelectArray = ["0"]
    //,NSMutableArray(objects: "0","0","0","0","0","0","0","0","0"),NSMutableArray(objects: "0","0","0")
    var actionSelectItemValueArray = [NSMutableArray(objects: "0","0","0","0","0","0")]
    //,"资料","任务"
    var titles: NSArray = ["基础"]
    var contentTitles: NSArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "DataSync", ofType: "plist")!)!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTitleView(titles: ["数据同步"])
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        buttonAction(titles: ["返回","立即同步"], actions: [#selector(pop),#selector(synchronization)], target: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contentTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2;
        }else if (section == 0) {
            return 3;
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            
            let width = kScreenWidth / 3.0
            let checkButtons = NSMutableArray(capacity: 20)
            
            
            if (indexPath.row == 0) {
                
                cell?.textLabel?.text = titles[indexPath.section] as? String
                cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)

                let box = RSCheckBox(frame: CGRect(x: kScreenWidth - 75 , y: 0, width: 75, height: 44))
                box.text = "全选"
                box.value = indexPath.section
                checkButtons.add(box)
                
                let lineView = UIView(frame: CGRect(x: 0 , y: 43.5, width: kScreenWidth, height: 0.5))
                lineView.backgroundColor = UIColor.lightGray
                cell?.contentView.addSubview(lineView)

            }else {
                
                for index in 0..<3 {
                    let box = RSCheckBox(frame: CGRect(x: width * CGFloat(index) , y: 0, width: kScreenWidth / 3.0, height: 44))
                    
                    if 3 * (indexPath.row - 1) + index < (contentTitles[indexPath.section] as! NSArray).count {
                        
                        box.value = indexPath.section * 1000 + 3 * (indexPath.row - 1) + index
                        box.text = (contentTitles[indexPath.section] as! NSArray)[3 * (indexPath.row - 1) + index] as? String
                        checkButtons.add(box)
                    }
                    
                }

            }
            
            let checkGroup = RSCheckGroup(frame: CGRect(x: 0 , y: 0, width: kScreenWidth, height: 44), withCheckBtns: checkButtons as [AnyObject])
            checkGroup?.isCheck = true;
            
            checkGroup?.delegate = self;
            
            cell?.contentView.addSubview(checkGroup!)
            
            
        }
        
        for view in (cell?.contentView.subviews)! {
            
            if (view.isKind(of: RSCheckGroup.self)) {
                view.tag = indexPath.section * 1000 + 1
                break;
            }
            
        }
        
        let select = (actionSelectArray[indexPath.section].caseInsensitiveCompare("1") == .orderedSame) ? true:false
        let tempCheckGroup = cell?.contentView.viewWithTag(indexPath.section * 1000 + 1) as! RSCheckGroup
        for checkBtn in tempCheckGroup.subviews {
            if checkBtn.isKind(of: RSCheckBox.self) {
                (checkBtn as! RSCheckBox).isSelected = select
            }
        }
        
        return cell!
    }
    
    //Mark:RSCheckGroupDelegate
    
    @available(iOS 2.0, *)
    public func click(withItem item: Int, index: Int, isAll: Bool, isSelected: Bool, sender: UIButton!) {
        print(item, index, isAll, isSelected)
        
        if isAll {
            //print(actionSelectArray)
            actionSelectArray[index] = isSelected ? "1":"0";
            self.contentTableView.reloadData()
        }
        
        var subItemIndexArray = NSMutableArray(array: actionSelectItemValueArray[item])
        
        if (isAll) {
            if (index == 0) {
                subItemIndexArray = NSMutableArray(objects: "1","1","1","1","1","1")
            }else if (index == 1) {
                subItemIndexArray = NSMutableArray(objects: "1","1","1","1","1","1","1","1","1")
            }else {
                subItemIndexArray = NSMutableArray(objects: "1","1","1")
            }
            actionSelectItemValueArray[index] = subItemIndexArray
        }else {
            subItemIndexArray[index] = isSelected ? "1":"0";
            actionSelectItemValueArray[item] = subItemIndexArray
        }
        
    }
    
    @objc func synchronization() {
        
        var isExist = false
        
        for (index, array) in actionSelectItemValueArray.enumerated() {
            
            if (index != 0) {
                continue
            }
            
            for (_, value) in array.enumerated() {
                
                if ((value as! String).compare("1") == .orderedSame) {
                    isExist = true
                    break;
                }
                
            }
            
            if (isExist) {
                break;
            }
            
        }
        
        if (isExist) {
            let dataSyn = DataSynchronizationDetailViewController()
            dataSyn.actionSelectItemValueArray = actionSelectItemValueArray
            self.push(viewController: dataSyn)
        }
        
    }

}
