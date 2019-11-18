//
//  CustomerMaterialViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class CustomerMaterialViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var contentTableView: UITableView!
    
    //楼盘编号
    var pcode = ""
    //楼阁编号
    var bcode = ""
    //楼层名称
    var fname = ""
    //房间编号
    var rcode = ""
    var pRoomCode = ""
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var titleNames: NSMutableDictionary = NSMutableDictionary(capacity: 20)
    var sectionTitles: NSMutableArray = NSMutableArray(capacity: 20)
    let sortArray: NSMutableArray = NSMutableArray(array: ["PRoomInfo","OwnerInfo","HouseholdsInfo","MemberInfo"])
    var qrContent = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTitleView(titles: ["业户信息"])
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sortArray.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (titleNames.count == 0) {
            return 0
        }
        let key = (sortArray[section] as! String).appending("Content")
        if ((sortArray[section] as! String).compare("MemberInfo") == .orderedSame) {
            let resultArray = (titleNames[key] as! NSArray)
            return resultArray.count;
        }
        let resultDict = (titleNames[key] as! NSDictionary)
        if (resultDict.count == 0) {
            return 0
        }
        let keys = BaseTool.seperate(byContent: resultDict["key"], seperate: "|")
        return keys!.count
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
        
        if (titleNames.count != 0) {
            contentLabel.text = " ".appending(self.titleNames[sortArray[section]] as! String)
        }
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
        tempCell.iconImageView.isHidden = true
        tempCell.iconTailConstraint.constant = -15;
        
        let key = sortArray[indexPath.section]
        
        if (key as! String).compare("MemberInfo") == .orderedSame {
            tempCell.accessoryType = .disclosureIndicator
        }else {
            tempCell.accessoryType = .none
        }
        
        
        if (key as! String).compare("MemberInfo") == .orderedSame {
            let resultArray = (titleNames[(sortArray[indexPath.section] as! String).appending("Content")] as! NSArray)
            let dict = resultArray[indexPath.row] as! NSDictionary
            
            tempCell.nameLabel.text = dict["联系人姓名"] as? String
            tempCell.contentLabel.text = dict["联系电话"] as? String
            
            return materialDataInfoDetailTableViewCell!
        }
        
        let resultDict = (titleNames[(sortArray[indexPath.section] as! String).appending("Content")] as! NSDictionary)
        let keys = BaseTool.seperate(byContent: resultDict["key"], seperate: "|")

        
        let content = resultDict[keys![indexPath.row]]
        tempCell.nameLabel.text = keys![indexPath.row] as? String
        tempCell.contentLabel.text = content as? String
        return materialDataInfoDetailTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let key = sortArray[indexPath.section]
        
        if (key as! String).compare("MemberInfo") == .orderedSame {
            
            /*
             
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
             
             */
            
            let resultArray = (titleNames[(sortArray[indexPath.section] as! String).appending("Content")] as! NSArray)
            let dict = resultArray[indexPath.row] as! NSDictionary
            self.requestLinkLists(idStr: dict["Id"] as! NSString)
//
//            var model = GetContactsDataModel()
//            model.Name = dict["联系人姓名"] as? String
//            model.MobileNum = dict["移动电话"] as? String
//            model.TelNum = dict["联系电话"] as? String
//            
            
        }
    }
    
    public func requestData() {
        
        let getPRoomOwnerInfo = GetPRoomOwnerInfo()
        getPRoomOwnerInfo.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getPRoomOwnerInfo.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","pRoomCode":pRoomCode,"version":"1.0"]
        getPRoomOwnerInfo.loadView = LoadView()
        getPRoomOwnerInfo.loadParentView = self.view
        getPRoomOwnerInfo.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            print(dict);
            
            if ((response as! NSDictionary)["QRContent"] != nil) {
                self.qrContent = BaseTool.toJson((response as! NSDictionary)["QRContent"])
            }
            
            if (self.qrContent.compare("") != .orderedSame) {
                //存在二维码
                
                let button = self.createTitleButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40.0), title: "", titleColor: UIColor.white, backGroundColor: UIColor.clear, textAlignment: .center, target: self, action: #selector(CustomerMaterialViewController.qrCode))
                button.setImage(UIImage(named: "ic_more_normal"), for: .normal)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
                
            }
            
            let array = BaseTool.lenghtValue(withContent: dict["showmodel"].string!)
            let sorts = NSArray(array: self.sortArray)
            for (index, value) in sorts.enumerated() {
                
                let valueTemp = (value as! NSString)
                let valueKey = valueTemp.appending("Content")
                
                self.titleNames[valueKey] = dict[value as! String].rawValue
                
                if (valueTemp.compare("PRoomInfo") == .orderedSame) {
                    self.titleNames[value] = "房间信息"
                }else if (valueTemp.compare("OwnerInfo") == .orderedSame) {
                    self.titleNames[value] = "业主信息"
                }
                
                if (array?[index] as! NSString).compare("1") == .orderedSame {
                    //显示
                    if (valueTemp.compare("HouseholdsInfo") == .orderedSame) {
                        if (dict["vertype"].string?.compare("zz") == .orderedSame) {
                           self.titleNames[value] = "住户信息"
                        }else {
                            self.titleNames[value] = "租户信息"
                        }
                        
                    }else if (valueTemp.compare("MemberInfo") == .orderedSame) {
                        
                        if (dict["vertype"].string?.compare("zz") == .orderedSame) {
                            self.titleNames[value] = "家庭成员"
                        }else {
                            self.titleNames[value] = "联系人"
                        }
                    }
                }else {
                    self.sortArray.remove(value)
                }
            }
            
            self.contentTableView.reloadData()
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    func requestLinkLists(idStr : NSString) {
        
        LoadView.storeLabelText = "正在加载联系人信息"
        
        let getContactsDataAPICmd = GetContactsDataAPICmd()
        getContactsDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getContactsDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":idStr,"pcode":pcode,"bcode":bcode,"fname":fname,"rcode":rcode]
        getContactsDataAPICmd.loadView = LoadView()
        getContactsDataAPICmd.loadParentView = self.view
        getContactsDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                var model = GetContactsDataModel()
                
                for (_,tempDict) in dict["contactsInfo"] {
                    
                    if let getContactsDataModel:GetContactsDataModel = JSONDeserializer<GetContactsDataModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                        if (getContactsDataModel.Id?.compare(idStr as String) == .orderedSame) {
                            model = getContactsDataModel
                            break
                        }
                    }
                    
                }

                let detail = MaterialDataInfoDetailViewController()
                detail.materialDataInfoType = .dataCustomer
                detail.model = model
                self.push(viewController: detail)
                
            }else {
                LocalToastView.toast(text: dict["msg"].rawValue as! String)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    @objc func qrCode() {
        //跳转
        let chat = CustomerQRViewController()
        let chatNav = UINavigationController(rootViewController: chat)
        chat.qrCodeStr = self.qrContent
        self.present(chatNav, animated: false, completion: {})
    }

}
