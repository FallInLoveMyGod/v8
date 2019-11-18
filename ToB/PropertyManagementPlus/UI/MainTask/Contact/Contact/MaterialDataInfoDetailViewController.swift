//
//  MaterialDataInfoDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/20.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

enum MaterialDataInfoType {
    case dataInfoUnit
    case dataInfoColleague
    case dataCustomer
}

open class MaterialDataInfoDetailViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var materialDataInfoType:MaterialDataInfoType = .dataInfoUnit
    var model: AnyObject?
    var titleNames: NSMutableArray = NSMutableArray(capacity: 20)
    
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var nameContentLabel: UILabel!
    
    @IBOutlet weak var showNameLabel: UILabel!
    
    var selectIndex = -1
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if (materialDataInfoType == .dataInfoColleague) {
            titleNames = [["单位名称",
                           "单位简称",
                           "单位地址",
                           "单位类型",
                           "法人代表",
                           "联系人",
                           "手机号码",
                           "电话"]]
            
            let tempModel = model as! OutsourcingDataModel
            
//            let name = NSString(string: tempModel.name!)
//            if (name.length <= 2) {
//                showNameLabel.text = name as String
//            }else {
//                showNameLabel.text = name.substring(from: name.length - 2)
//            }
            
//            nameContentLabel.text = tempModel.name!
            
        }else if (materialDataInfoType == .dataCustomer)  {
            //客户资料
            titleNames = [["名称",
                "手机号码",
                "电话",
                "用户类型",
                "关系"],
            ["民族",
            "籍贯",
            "政治面貌",
            "文化程度",
            "身份证号码",
            "工作单位",
            "附加说明"]]
            
//            let tempModel = model as! GetContactsDataModel
//
//            let name = NSString(string: tempModel.Name!)
//            if (name.length <= 2) {
//                showNameLabel.text = name as String
//            }else {
//                showNameLabel.text = name.substring(from: name.length - 2)
//            }
//            
//            nameContentLabel.text = tempModel.Name!
        }
        else {
            titleNames = [["名称",
                           "编号",
                           "职位",
                           "手机号码",
                           "联系电话",
                           "紧急联系人",
                           "紧急联系电话",
                           "电子邮箱"]]
            
//            let tempModel = model as! WorkerDataModel
//            
//            let name = NSString(string: tempModel.workername!)
//            if (name.length <= 2) {
//                showNameLabel.text = name as String
//            }else {
//                showNameLabel.text = name.substring(from: name.length - 2)
//            }
//            
//            nameContentLabel.text = tempModel.workername!
            
        }
        
        if (materialDataInfoType == .dataCustomer) {
            self.setTitleView(titles: ["客户资料"])
        }else {
            self.setTitleView(titles: [materialDataInfoType == .dataInfoColleague ? "单位资料":"同事资料"])
        }

        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        self.contentTableView.estimatedRowHeight = 0;
        self.contentTableView.estimatedSectionHeaderHeight = 0;
        self.contentTableView.estimatedSectionFooterHeight = 0;
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        //backGroundView.backgroundColor = kThemeColor
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        
        
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return titleNames.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (titleNames[section] as! NSArray).count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35.0))
        contentLabel.backgroundColor = UIColor.groupTableViewBackground
        contentLabel.textColor = kMarkColor
        contentLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        contentLabel.text = "    基本信息"
        
        if (materialDataInfoType == .dataCustomer) {
            if section == 1 {
                contentLabel.text = "    社会信息"
            }
        }
        
        /*
        if (materialDataInfoType == .dataCustomer) {
            contentLabel.text = "客户资料"
        }else {
            contentLabel.text = (materialDataInfoType == .dataInfoColleague ? "单位资料":"同事资料")
        }
 */
    
        return contentLabel;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var materialDataInfoDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if materialDataInfoDetailTableViewCell == nil {
            
            materialDataInfoDetailTableViewCell = Bundle.main.loadNibNamed("MaterialDataInfoDetailTableViewCell", owner: nil, options: nil)?.first as! MaterialDataInfoDetailTableViewCell
            materialDataInfoDetailTableViewCell?.selectionStyle = .none
            
            materialDataInfoDetailTableViewCell?.separatorInset = .zero
            materialDataInfoDetailTableViewCell?.layoutMargins = .zero
            materialDataInfoDetailTableViewCell?.preservesSuperviewLayoutMargins = false
        }
        
        let tempCell = materialDataInfoDetailTableViewCell as! MaterialDataInfoDetailTableViewCell
        
        tempCell.nameLabel.text = (titleNames[indexPath.section] as! NSArray)[indexPath.row] as? String
        tempCell.iconImageView.image = UIImage(named: "")
        
        var content = ""
        
        if (materialDataInfoType == .dataInfoUnit) {
            
            
            let tempModel = model as! WorkerDataModel
            
            if (indexPath.row == 0) {
                content = tempModel.workername!
            }else if (indexPath.row == 1) {
                content = tempModel.workernum!
            }else if (indexPath.row == 2) {
                content = tempModel.position!
            }else if (indexPath.row == 3) {
                content = tempModel.phonenum!
                tempCell.iconImageView.image = UIImage(named: "icon_phone")
            }else if (indexPath.row == 4) {
                content = tempModel.tellphone!
                tempCell.iconImageView.image = UIImage(named: "icon_phone")
            }else if (indexPath.row == 5) {
                content = tempModel.jjperson!
            }else if (indexPath.row == 6) {
                content = tempModel.jjphone!
                tempCell.iconImageView.image = UIImage(named: "icon_phone")
            }else if (indexPath.row == 7) {
                content = tempModel.email!
            }
            
        }else if (materialDataInfoType == .dataCustomer) {
            let tempModel = model as! GetContactsDataModel
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    content = tempModel.Name!
                }else if (indexPath.row == 1) {
                    content = tempModel.MobileNum!
                    tempCell.iconImageView.image = UIImage(named: "icon_phone")
                }else if (indexPath.row == 2) {
                    content = tempModel.TelNum!
                    tempCell.iconImageView.image = UIImage(named: "icon_phone")
                }else if (indexPath.row == 3) {
                    content = tempModel.Type!
                }
            }
            
            
        }else {
            
            let tempModel = model as! OutsourcingDataModel
            
            if (indexPath.row == 0) {
                content = tempModel.name!
            }else if (indexPath.row == 1) {
                content = tempModel.simplename!
            }else if (indexPath.row == 2) {
                content = tempModel.address!
            }else if (indexPath.row == 3) {
                content = tempModel.type!
            }else if (indexPath.row == 4) {
                content = tempModel.legal!
            }else if (indexPath.row == 5) {
                content = tempModel.contacts!
            }else if (indexPath.row == 6) {
                content = tempModel.tel!
                tempCell.iconImageView.image = UIImage(named: "icon_phone")
            }else if (indexPath.row == 7) {
                content = tempModel.phone!
                tempCell.iconImageView.image = UIImage(named: "icon_phone")
            }
            
        }
        tempCell.contentLabel.text = content
        return materialDataInfoDetailTableViewCell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectIndex = indexPath.row
        
        if (materialDataInfoType == .dataInfoUnit) {
            
            if (indexPath.row == 3
                || indexPath.row == 4
                || indexPath.row == 6) {
                action()
            }
            
        }else if (materialDataInfoType == .dataCustomer) {
            
            if (indexPath.row == 1
                || indexPath.row == 2) {
                action()
            }
            
        }else {
            
            if (indexPath.row == 6
                || indexPath.row == 7) {
                action()
            }
        }
    }
    
    func action() {
        showActionSheet(title: "请选择", cancelTitle: "取消", titles: ["复制","拨打电话"], tag: "Select")
    }
    
    public func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if (tag.compare("Select") == .orderedSame) {
            
            var pastStr = ""
            
            if (materialDataInfoType == .dataInfoUnit) {
                let tempModel = model as! WorkerDataModel
                
                if (selectIndex == 3) {
                    pastStr = tempModel.phonenum!
                }else if (selectIndex == 4) {
                    pastStr = tempModel.tellphone!
                }else if (selectIndex == 6) {
                    pastStr = tempModel.jjphone!
                }
                
            }else if (materialDataInfoType == .dataCustomer) {
                let tempModel = model as! GetContactsDataModel
                
                if (selectIndex == 1) {
                    pastStr = tempModel.MobileNum!
                }else if (selectIndex == 2) {
                    pastStr = tempModel.TelNum!
                }
                
            }else {
                let tempModel = model as! OutsourcingDataModel
                
                if (selectIndex == 6) {
                    pastStr = tempModel.tel!
                }else if (selectIndex == 7) {
                    pastStr = tempModel.phone!
                }
                
            }
            
            if (buttonIndex == 1) {
                UIPasteboard.general.string = pastStr
            }else {
                dailNumber(phoneNumber: pastStr)
            }
            
        }
    }

}
