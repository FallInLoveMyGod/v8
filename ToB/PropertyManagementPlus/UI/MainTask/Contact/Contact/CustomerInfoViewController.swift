//
//  CustomerInfoViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

enum CustomerInfoType {
    case customerArea
    case commonArea
    case customerMaterial
    case customerEvent
}

//TODO:
@objc public protocol CustomerInfoDelegate {
    @objc optional func confirmWithObject(object: AnyObject)
    @objc optional func confirmWithAddress(address: NSString, pcode: NSString, bcode: NSString, fname: NSString, rcode: NSString, ownerCode: NSString)
}


class CustomerInfoViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var contentTableView: UITableView!
    
    var delegate : CustomerInfoDelegate?
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    var isTopLevelShow: Bool = false
    
    //Range
    var range: String? = "客户区域"
    var address: String = ""
    var customerInfoType = CustomerInfoType.customerArea
    
    var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueLinkPersonsDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var isLinkShow: Bool = false
    
    //楼盘编号
    var pcode = ""
    //楼阁编号
    var bcode = ""
    //楼层名称
    var fname = ""
    //房间编号
    var rcode = ""
    
    var ownerCode = ""
    
    var levelIndex = 0
    var titleNames: NSMutableArray = NSMutableArray(capacity: 20)
    var levelHouseStructureModel: HouseStructureModel = HouseStructureModel()
    var levelResultDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var topSelectedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        
        if (isTopLevelShow) {
            requestTopInfo()
        }else {
            refreshData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createUI () {
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        if (customerInfoType == .customerArea) {
            self.setTitleView(titles: ["客户信息"])
        }else if (customerInfoType == .commonArea) {
            self.setTitleView(titles: ["房产结构"])
            buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(confirm)], target: self)
        }else {
            if (customerInfoType == .customerEvent) {
                range = "房产结构"
            }else if (customerInfoType == .customerMaterial) {
                range = "业户资料"
            }
            self.setTitleView(titles: [(range! as NSString)])
        }
        
        self.contentTableView.estimatedRowHeight = 0;
        self.contentTableView.estimatedSectionHeaderHeight = 0;
        self.contentTableView.estimatedSectionFooterHeight = 0;
        contentTableView.delegate = self
        contentTableView.dataSource = self
    
        let heightTop: CGFloat = 50.0
        topSelectedView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: heightTop))
        
        let button = self.createButton(frame: CGRect(x: 0, y: 0, width: heightTop, height: heightTop), title: "", titleColor: UIColor.clear, backGroundColor: UIColor.clear, textAlignment: .left, image: UIImage(named: "icon_menu_root")!, target: self, action: #selector(pop))
        
        topSelectedView.backgroundColor = UIColor.white
        topSelectedView.addSubview(button)
        
        self.view.addSubview(topSelectedView)
        
    }
    
    func refreshData() {
        
        var nextArray = customerDataSource as? NSArray
        
        if (!isTopLevelShow) {
            
            pcode = levelHouseStructureModel.Code!
            
            nextArray = levelHouseStructureModel.PBuildings
            // 排序
            let ldArr = NSMutableArray();
            let fldArr = NSMutableArray();
            for tempDic in nextArray! {
                if (tempDic as! NSDictionary)["buildType"] as! String == "楼栋" {
                    ldArr.add(tempDic);
                }
                else {
                    fldArr.add(tempDic);
                }
            }
            ldArr.sort { (dic1, dic2) -> ComparisonResult in
                let tempDic1 = dic1 as! NSDictionary;
                let tempDic2 = dic2 as! NSDictionary;
                return ((tempDic1["Code"] as! String).compare((tempDic2["Code"] as! String)))
            }
            ldArr.addObjects(from: fldArr as! [Any]);
            nextArray = ldArr;
            
            if (levelIndex == 1) {
                nextArray = levelHouseStructureModel.PFloors
            }else if (levelIndex == 2) {
                nextArray = levelHouseStructureModel.PRooms
            }
        }else {
            
            if (levelIndex == 0) {
                
            }else if (levelIndex == 1) {
                nextArray = levelHouseStructureModel.PBuildings
                // 排序
                let ldArr = NSMutableArray();
                let fldArr = NSMutableArray();
                for tempDic in nextArray! {
                    if (tempDic as! NSDictionary)["buildType"] as! String == "楼栋" {
                        ldArr.add(tempDic);
                    }
                    else {
                        fldArr.add(tempDic);
                    }
                }
                ldArr.sort { (dic1, dic2) -> ComparisonResult in
                    let tempDic1 = dic1 as! NSDictionary;
                    let tempDic2 = dic2 as! NSDictionary;
                    return ((tempDic1["Code"] as! String).compare((tempDic2["Code"] as! String)))
                }
                ldArr.addObjects(from: fldArr as! [Any]);
                nextArray = ldArr;
                print(nextArray![0])
                
            }else if (levelIndex == 2) {
                
                let arr:NSArray = levelHouseStructureModel.PFloors ?? NSArray();
                let mArr:NSMutableArray = arr.mutableCopy() as! NSMutableArray;
//                mArr.sort { (dic1, dic2) -> ComparisonResult in
//                    let tempDic1 = dic1 as! NSDictionary;
//                    let tempDic2 = dic2 as! NSDictionary;
//                    return ((tempDic1["Name"] as! String).compare((tempDic2["Name"] as! String)))
//                }
                nextArray = mArr;
//                nextArray = arr.sortedArray { (dic1, dic2) -> ComparisonResult in
//                    let tempDic1 = dic1 as! NSDictionary;
//                    let tempDic2 = dic2 as! NSDictionary;
//                    return ((tempDic1["Code"] as! String).compare((tempDic2["Code"] as! String)))
//                    } as NSArray
                
            }else if (levelIndex == 3) {
                nextArray = levelHouseStructureModel.PRooms
            }
            
        }
        if nextArray != nil && nextArray?.count != 0 {
            changeTopView();
        }
        
        var tempArray: NSMutableArray = NSMutableArray(capacity: 20)
        
        if (isTopLevelShow && levelIndex == 0) {
            tempArray = nextArray as! NSMutableArray
        }else {
            if nextArray == nil  {
                if levelIndex != 0 {
                    levelIndex = levelIndex - 1;
                    titleNames.removeLastObject();
                }
                return;
            }
        
            for (_,tempDict) in (nextArray?.enumerated())!{
                
                if let houseStructureLevelModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON: JSON(tempDict).rawString() ?? {}) {
                    tempArray.add(houseStructureLevelModel)
                }
            }
            
            tempArray.sort(comparator: { (modelF, modelS) -> ComparisonResult in
                let modelFT = modelF as! HouseStructureModel
                let modelST = modelS as! HouseStructureModel
                return (modelFT.Code?.compare(modelST.Code!))!
            });
//            if (levelIndex == 2) {
//                tempArray.sort(comparator: { (modelF, modelS) -> ComparisonResult in
//                    let modelFT = modelF as! HouseStructureModel
//                    let modelST = modelS as! HouseStructureModel
//                    return (modelFT.Name?.compare(modelST.Name!))!
//                });
//            }
        }
        
        levelResultDataSource[levelIndex] = tempArray
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.contentTableView?.backgroundColor = UIColor.groupTableViewBackground
        self.contentTableView?.reloadData()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (levelResultDataSource.count != 0) {
            
            if (isLinkShow) {
                return self.colleagueLinkPersonsDataSource.count
            }
            return (levelResultDataSource[levelIndex] as! NSArray).count
            
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (isLinkShow) {
            return 55
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
//        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
//        backView.backgroundColor = UIColor.white
//        let titleLable = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth, height: 30))
//        titleLable.font = UIFont.boldSystemFont(ofSize: 16)
//        if (isLinkShow) {
//            titleLable.text = "联系人"
//        }else {
//            titleLable.text = "房产结构"
//        }
//        
//        backView.addSubview(titleLable)
//        return backView
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
        backView.backgroundColor = UIColor.groupTableViewBackground
        
        return backView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (isLinkShow) {
            
            let cellIdentifier = "CellIdentifier"
            var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if tableViewCell == nil {
                
                tableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
                tableViewCell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            }
            
            tableViewCell?.imageView?.image = UIImage(named: "icon_cricle_green@2x")
            tableViewCell?.imageView?.contentMode = .scaleAspectFit
            
            let model = colleagueLinkPersonsDataSource[indexPath.row] as! GetContactsDataModel
            tableViewCell?.textLabel?.text = model.Name?.appending("    ").appending(model.Type!)
            tableViewCell?.detailTextLabel?.text = model.MobileNum
            tableViewCell?.detailTextLabel?.textColor = UIColor.darkGray
            
            addLabelWithName(contentView: (tableViewCell?.imageView)!, contentTitle: (model.Name)!)
            
            return tableViewCell!
            
        }else {
            
            let cellIdentifier = "NormalCellIdentifier"
            var normalTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if normalTableViewCell == nil {
                
                normalTableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
                normalTableViewCell?.accessoryType = .disclosureIndicator
                normalTableViewCell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                normalTableViewCell?.separatorInset = .zero
                normalTableViewCell?.layoutMargins = .zero
                normalTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            let model: HouseStructureModel = (levelResultDataSource[levelIndex] as! NSArray)[indexPath.row] as! HouseStructureModel
            
            if (isTopLevelShow) {
                
                if (levelIndex == 0) {
                    normalTableViewCell?.textLabel?.text = model.Name
                }else if (levelIndex == 1) {
                    normalTableViewCell?.textLabel?.text = model.Name
                }else if (levelIndex == 2) {
                    normalTableViewCell?.textLabel?.text = model.Name
                }else if (levelIndex == 3) {
                    normalTableViewCell?.textLabel?.text = model.Name?.appending("    ".appending(model.TenantName!))
                }
                
            }else {
                if (levelIndex == 0) {
                    normalTableViewCell?.textLabel?.text = model.Name
                }else if (levelIndex == 1) {
                    normalTableViewCell?.textLabel?.text = model.Name
                }else if (levelIndex == 2) {
                    normalTableViewCell?.textLabel?.text = model.Name?.appending("    ".appending(model.TenantName!))
                }
            }
            return normalTableViewCell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (colleagueLinkPersonsDataSource.count != 0) {
            
            if (isTopLevelShow) {
                
                delegate?.confirmWithObject!(object: colleagueLinkPersonsDataSource[indexPath.row] as AnyObject)
                addressformate()
                pop()
                
            }else {
                
                tableView.deselectRow(at: indexPath, animated: true)
                
                let infoDetail = MaterialDataInfoDetailViewController()
                infoDetail.materialDataInfoType = .dataCustomer
                infoDetail.model = colleagueLinkPersonsDataSource[indexPath.row] as AnyObject?
                self.push(viewController: infoDetail)
                
            }
            return
        }
        
        levelHouseStructureModel = (levelResultDataSource[levelIndex] as! NSArray)[indexPath.row] as! HouseStructureModel
        
        let tableViewCell = tableView.cellForRow(at: indexPath)
        
        if (isTopLevelShow) {
            
            if (levelIndex == 3) {
                titleNames.add("/" + levelHouseStructureModel.Name!)
            }else {
                titleNames.add("/" + (tableViewCell?.textLabel?.text)!)
            }
            
            if (levelIndex == 0) {
                pcode = levelHouseStructureModel.Code!
            }else if (levelIndex == 1) {
                bcode = levelHouseStructureModel.Code!
            }else if (levelIndex == 2) {
                fname = levelHouseStructureModel.PFloorName!
                if (customerInfoType == .customerEvent) {
                    buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(confirm)], target: self)
                }
            }else if (levelIndex == 3) {
                
                if (customerInfoType == .customerEvent) {
                    confirm()
                }else if (customerInfoType == .customerMaterial) {
                    
                    let infoVC = CustomerMaterialViewController()
                    infoVC.pcode = pcode
                    infoVC.bcode = bcode
                    infoVC.fname = fname
                    infoVC.rcode = levelHouseStructureModel.Code!
                    infoVC.pRoomCode = levelHouseStructureModel.Code!
                    self.push(viewController: infoVC)
                    
                }else {
                    if (range != nil && customerInfoType == .commonArea) {
                        confirm()
                    }else {
                        buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(confirm)], target: self)
                        
                        rcode = levelHouseStructureModel.Code!
                        ownerCode = levelHouseStructureModel.OwnerCode!
                        isLinkShow = true
                        requestLinkLists()
                    }
                }
            }
            
        }else {
            
            if (levelIndex == 2) {
                titleNames.add("/" + levelHouseStructureModel.Name!)
            }else {
                titleNames.add("/" + (tableViewCell?.textLabel?.text)!)
            }
            
            if (levelIndex == 0) {
                bcode = levelHouseStructureModel.Code!
            }else if (levelIndex == 1) {
                fname = levelHouseStructureModel.PFloorName!
            }else if (levelIndex == 2) {
                rcode = levelHouseStructureModel.Code!
                isLinkShow = true
                requestLinkLists()
            }
        }
        
        levelIndex += 1;
        
        refreshData()
    }
    
    func changeTopView() {
        
        var startX: CGFloat = 0.0
        var width: CGFloat = 40
        var titleNameStr = ""
        
        if (topSelectedView.subviews.count == 0 || levelIndex == 0) {
            
        }else {
            
            titleNameStr = titleNames[levelIndex - 1] as! String;
            
            for (_,subButton) in topSelectedView.subviews.enumerated() {
                let changeButton = subButton as! UIButton
                changeButton.setTitleColor(kThemeColor, for: .normal)
            }
            
            let button = topSelectedView.subviews[topSelectedView.subviews.count - 1];
            startX = CGFloat(button.frame.origin.x) + CGFloat(button.frame.size.width)
            
            width = self.getButtonWidth(text: titleNameStr, attributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 15)])
        }
        
        let addButton = self.createButton(frame: CGRect(x: startX, y: 0, width: width, height: 50), title: titleNameStr, titleColor: UIColor.gray, backGroundColor: UIColor.clear, textAlignment: .left, image: UIImage(named: ""), target: self, action: #selector(selectButtonClick(button:)))
        addButton.tag = levelIndex
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        topSelectedView.backgroundColor = UIColor.white
        topSelectedView.addSubview(addButton)
        
    }
    
    /**
     计算label的宽度和高度
     
     :param: text       label的text的值
     :param: attributes label设置的字体
     
     :returns: 返回计算后label的CGRece
     */
    func getButtonWidth(text:String ,attributes : [NSAttributedStringKey : Any]) -> CGFloat{
        var size = CGRect();
        let size2 = CGSize(width: 0, height: 40);//设置view的最大宽度
        size = text.boundingRect(with: size2, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes , context: nil);
        return size.width
    }
    
    @objc func selectButtonClick(button: UIButton) {
        
        //var deleteIndex = button.tag
        
        isLinkShow = false
        colleagueLinkPersonsDataSource.removeAllObjects()
        
        while (titleNames.count > button.tag) {
            titleNames.removeLastObject()
        }
        
        while (topSelectedView.subviews.count > button.tag + 2) {
            topSelectedView.subviews[topSelectedView.subviews.count - 1].removeFromSuperview()
        }
        
        while (levelResultDataSource.count > button.tag + 1) {
            levelResultDataSource.removeLastObject()
        }
        
        for (index,subButton) in topSelectedView.subviews.enumerated() {
            let changeButton = subButton as! UIButton
            if (index == topSelectedView.subviews.count - 1) {
                changeButton.setTitleColor(UIColor.gray, for: .normal)
            }else {
                changeButton.setTitleColor(kThemeColor, for: .normal)
            }
        }
        
        levelIndex = levelResultDataSource.count - 1
        
        if (isTopLevelShow) {
            if (levelIndex <= 3) {
                
                if (range != nil && !(range?.compare("") == .orderedSame)) {
                    
                }else {
                    buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
                }
                
            }else {
                buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(confirm)], target: self)
            }
        }
        
        self.contentTableView.reloadData()
        
    }
    
    func requestTopInfo() {
        
        self.customerDataSource.removeAllObjects()
        
        let response = UserDefaults.standard.object(forKey: HouseStructureDataSynchronization)
        
        let dict = JSON(response ?? {})
        
        for (_,tempDict) in dict["PProjects"] {
            
            if let houseStructureModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                self.customerDataSource.add(houseStructureModel)
            }
        }
        
        self.refreshData()
        
    }
    
    func requestLinkLists() {
        
        LoadView.storeLabelText = "正在加载联系人信息"
        
        let getContactsDataAPICmd = GetContactsDataAPICmd()
        getContactsDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getContactsDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","pcode":pcode,"bcode":bcode,"fname":fname,"rcode":rcode]
        getContactsDataAPICmd.loadView = LoadView()
        getContactsDataAPICmd.loadParentView = self.view
        getContactsDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                self.colleagueLinkPersonsDataSource.removeAllObjects()
                for (_,tempDict) in dict["contactsInfo"] {
                    
                    if let getContactsDataModel:GetContactsDataModel = JSONDeserializer<GetContactsDataModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                        self.colleagueLinkPersonsDataSource.add(getContactsDataModel)
                    }
                    
                }
                
                self.contentTableView.reloadData()
                
            }else {
                LocalToastView.toast(text: "获取联系人信息失败！")
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    @objc func confirm() {
        
        
        delegate?.confirmWithObject!(object: levelHouseStructureModel)
        addressformate()
        
        pop()
    }
    
    func addressformate() {
        for (_, name) in titleNames.enumerated() {
            address.append(name as! String)
        }
        let index = address.index(address.startIndex, offsetBy: 1)
        address = address.substring(from: index)
        
        delegate?.confirmWithAddress!(address: address as NSString, pcode: pcode as NSString, bcode: bcode as NSString, fname: fname as NSString, rcode: rcode as NSString, ownerCode:ownerCode as NSString)
    }
    
    func addLabelWithName(contentView: UIImageView, contentTitle: String ) {
        
        contentView.viewWithTag(5555)?.removeFromSuperview()
        
        //let frame = contentView.frame
        
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        contentLabel.tag = 5555;
        contentLabel.textAlignment = .center
        contentLabel.font = UIFont.systemFont(ofSize: 11)
        contentLabel.textColor = UIColor.white
        contentLabel.backgroundColor = UIColor.clear
        contentView.addSubview(contentLabel)
        
        let name = NSString(string: contentTitle)
        if (name.length <= 2) {
            contentLabel.text = name as String
        }else {
            contentLabel.text = name.substring(from: name.length - 2)
        }
        
    }

}
