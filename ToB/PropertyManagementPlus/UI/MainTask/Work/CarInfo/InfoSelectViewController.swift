//
//  InfoSelectViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

enum InfoSelectType{
    case equipmentMaterial
    case knowleage
    case partment
}

protocol InfoSelectDelegate {
    func infoSuddenEventSelectItem(_ model: OrganizeDataModel, item: String)
}

class InfoSelectViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,ChooseAlertDelegate {

    
    @IBOutlet weak var contentTableView: UITableView!
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    var isTopLevelShow: Bool = false
    
    var infoSelectType = InfoSelectType.equipmentMaterial
    
    var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var levelIndex = 0
    var titleNames: NSMutableArray = NSMutableArray(capacity: 20)
    var levelInfoSelectModel: LevelInfoSelectModel = LevelInfoSelectModel()
    var levelResultDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var topSelectedView: UIView!
    
    var infoSelectDelegate: InfoSelectDelegate?
    var suddenEventItem: String = ""
    
    var chooseTitle:NSString? = ""
    
    var chooseCode:NSString? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createUI () {
        
        self.contentTableView.emptyDataSetSource = self
        self.contentTableView.emptyDataSetDelegate = self
        
        if (infoSelectType == .equipmentMaterial) {
            self.setTitleView(titles: [("设备资料" as NSString)])
            // 右按钮
            let rightBarBtn = UIBarButtonItem.init(image: UIImage(named: "SX.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(chooseArea))
            self.navigationItem.rightBarButtonItem = rightBarBtn;
        }else {
            self.setTitleView(titles: [("知识库" as NSString)])
        }
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
    
        let heightTop: CGFloat = 50.0
        topSelectedView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: heightTop))
//        kNavbarHeight
        let button = self.createButton(frame: CGRect(x: 0, y: 0, width: heightTop, height: heightTop), title: "", titleColor: UIColor.clear, backGroundColor: UIColor.clear, textAlignment: .left, image: UIImage(named: "icon_menu_root")!, target: self, action: #selector(selectButtonClick(button:)))
        button.tag = -1
        topSelectedView.backgroundColor = UIColor.white
        topSelectedView.addSubview(button)
        
        self.view.addSubview(topSelectedView)
        
        if (infoSelectType == .equipmentMaterial) {
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }else if (infoSelectType == .partment) {
            buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(confirm)], target: self)
        }
        else {
            buttonAction(titles: ["返回","更新知识库"], actions: [#selector(pop),#selector(update)], target: self)
        }
    }
    
    
    @objc func chooseArea() {
        if  (!HouseStructureModel.isExistInTable())  {
            let alertv = UIAlertController.init(title: "还未同步房产信息", message: "是否同步", preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction.init(title: "立即同步", style: .default) { (action) in
                DataSynchronizationManager.houseStructureDataSynchronization();
            }
            let cancleAction = UIAlertAction.init(title: "取消", style: .default) { (action) in
                
            }
            alertv.addAction(action1);
            alertv.addAction(cancleAction);
            self.present(alertv, animated: true, completion: nil);
            return;
        }
        let arr:NSArray = HouseStructureModel.findAll()! as NSArray;
        
        let alert = ChooseAlertView.init(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight));
        appDelegate.window?.addSubview(alert)
        alert.delegate = self;
        alert.dataSource = arr;
        alert.show()
    }
    
    func refreshData() {
        
        self.customerDataSource.removeAllObjects()
        
        if (infoSelectType == .equipmentMaterial) {
            levelInfoSelectModel.arrayFirst = InfoSelectManagement.shareInstance().dealWithInfoSelectArray() as NSArray?
            
        }else if (infoSelectType == .partment) {
            //OrganizeDataModel
            let datas: NSMutableArray = NSMutableArray(capacity: 20)
            let dataSecond: NSMutableArray = NSMutableArray(capacity: 20)
            let array = OrganizeDataModel.findAll()
            for model in array! {
                let tempModel = model as! OrganizeDataModel
                
                if (tempModel.superiorpk?.compare("") == .orderedSame) {
                    datas.add(model)
                }else {
                    dataSecond.add(model)
                }
            }
            
            levelInfoSelectModel.arrayFirst = datas
            levelInfoSelectModel.arraySecond = dataSecond
        }
        else {
            
            levelInfoSelectModel.arrayFirst = InfoSelectManagement.shareInstance().dealWithKnowleageInfoSelectArray() as NSArray?
        }
        
        levelResultDataSource.removeAllObjects();
        levelResultDataSource.addObjects(from: levelInfoSelectModel.arrayFirst as! [Any])
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.contentTableView?.backgroundColor = UIColor.groupTableViewBackground
        self.contentTableView?.reloadData()
        
    }
    
    func tableViewSelectWithHouseModel(model: HouseStructureModel) {
        print(model.Code ?? "");
        self.chooseTitle = model.Name! as NSString;
        self.chooseCode = model.Code! as NSString;
        self.setTitleView(titles: [(("设备资料-" + (model.Name! as String))  as NSString)])
        
//        // 筛选
//        let mArr:NSMutableArray = NSMutableArray();
//        for item in self.dataSource {
//            let tempItem:InfoEquipmentMaterialModel = item as! InfoEquipmentMaterialModel
//            if tempItem.PProjectCode == model.Code {
//                mArr.add(tempItem);
//            }
//        }
//        self.dataSource.removeAllObjects()
//        self.dataSource.addObjects(from: mArr as! [Any]);
//        print(self.dataSource.count)
//        self.contentTableView?.reloadData()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return levelResultDataSource.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
        backView.backgroundColor = UIColor.groupTableViewBackground
        
        return backView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        
        if (infoSelectType == .partment) {
            let organizeDataModel: OrganizeDataModel = levelResultDataSource[indexPath.row] as! OrganizeDataModel
            normalTableViewCell?.textLabel?.text = organizeDataModel.organizename
            
            return normalTableViewCell!
        }
        
        let info = levelResultDataSource[indexPath.row] as! NSDictionary
        
        if (infoSelectType == .equipmentMaterial) {
            normalTableViewCell?.textLabel?.text = info["equipmentname"] as? String
        }
        else {
            if (levelIndex == 0) {
                normalTableViewCell?.textLabel?.text = info["mname"] as? String
            }else {
                normalTableViewCell?.textLabel?.text = info["pname"] as? String
            }
            
        }
        
        return normalTableViewCell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (levelIndex >= 2) {
            levelIndex = 1;
        }
        
        levelIndex += 1;
        
        //跳转
        if (levelIndex == 2) {
            
            if (infoSelectType == .equipmentMaterial) {
                let info = levelResultDataSource[indexPath.row] as! NSDictionary
                let infoMaterial = InfoMaterialViewController()
                infoMaterial.infoMaterialType = .equipmentMaterial
                infoMaterial.equipmenttypepk = (info["equipmentpk"] as? String)!
                infoMaterial.chooseTitle = self.chooseCode;
                if chooseTitle == "" || chooseCode == nil {
                    
                }
                else {
                    infoMaterial.titleContent = "设备列表" + (self.chooseTitle! as String)
                }
                self.push(viewController: infoMaterial)
            }else if (infoSelectType == .partment) {
                if let delegate = infoSelectDelegate {
                    let organizeDataModel: OrganizeDataModel = levelResultDataSource[indexPath.row] as! OrganizeDataModel
                    suddenEventItem.appending("/").appending(organizeDataModel.organizename!)
                    delegate.infoSuddenEventSelectItem(organizeDataModel, item: suddenEventItem)
                }
                pop()
            }
            else {
                //知识库详情
                //显示详情
                
                let info = levelResultDataSource[indexPath.row] as! NSDictionary
                let detail = KnowledgeViewController()
                detail.ppk = BaseTool.toStr(info["ppk"])
                self.push(viewController: detail)
                
            }
            
            return;
        }
        
        if (levelIndex == 1) {
            
            if (infoSelectType == .partment) {
                
                let info = levelResultDataSource[indexPath.row] as! OrganizeDataModel
                suddenEventItem = info.organizename!
                
            }else if (infoSelectType == .equipmentMaterial) {
                let info = levelResultDataSource[indexPath.row] as! NSDictionary
                levelInfoSelectModel.arraySecond = InfoSelectManagement.shareInstance().deal(withInfoSelectID: info["equipmentpk"] as? String) as NSArray?
            }else {
                let info = levelResultDataSource[indexPath.row] as! NSDictionary
                levelInfoSelectModel.arraySecond = InfoSelectManagement.shareInstance().deal(withKnowleageInfoSelectID: BaseTool.toStr(info["mpk"])) as NSArray?
            }
            
            levelResultDataSource.removeAllObjects();
            levelResultDataSource.addObjects(from: levelInfoSelectModel.arraySecond as! [Any])
        }
        
        let tableViewCell = tableView.cellForRow(at: indexPath)
        titleNames.add("/" + (tableViewCell?.textLabel?.text)!)
        changeTopView();
        
        self.contentTableView?.reloadData()
    }
    
    //MARK: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate
    
    //空页面
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if (self.noDataImgName.compare("") != .orderedSame) {
            return UIImage(named: self.noDataImgName)
        }
        return UIImage(named: "")
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let text = "暂时无内容"
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0),NSAttributedStringKey.foregroundColor:UIColor.gray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return self.isShowEmptyData
    }
    
    public func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0.0
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
        
        if (button.tag == -1) {
            
            topSelectedView.subviews.last?.removeFromSuperview()
            titleNames.removeLastObject()
            levelIndex = 0;
            
            refreshData()
            
        }else {
            
            while (titleNames.count > button.tag) {
                titleNames.removeLastObject()
            }
            
            while (topSelectedView.subviews.count > button.tag + 2) {
                topSelectedView.subviews[topSelectedView.subviews.count - 1].removeFromSuperview()
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
            
            self.contentTableView.reloadData()
        }
        
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
    
    func requestData() {
        
        if (infoSelectType == .equipmentMaterial) {
            
            LoadView.storeLabelText = "正在加载设备资料信息"
            
            let getEquipmentMenuAPICmd = GetEquipmentMenuAPICmd()
            getEquipmentMenuAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getEquipmentMenuAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getEquipmentMenuAPICmd.loadView = LoadView()
            getEquipmentMenuAPICmd.loadParentView = self.view
            getEquipmentMenuAPICmd.transactionWithSuccess({ (response) in
                
                print(response)
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    UserDefaults.standard.set((response as! NSDictionary)["infos"], forKey: GetEquipmentMenuKey)
                    UserDefaults.standard.synchronize()
                    
                    self.refreshData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }else if (infoSelectType == .partment) {
            refreshData()
        }
        else {
            if (UserDefaults.standard.object(forKey: "GetKnowleageMenuKey") != nil) {
                refreshData()
            }
        }
        
    }
    
    @objc func update() {
        
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var time = timeFormatter.string(from: date as Date) as String
        
        if (UserDefaults.standard.object(forKey: "GetKnowleageMenuKey") == nil) {
            time = ""
        }
        
        LoadView.storeLabelText = "正在加载知识库"
        
        let synchroniseKnowLedgeAPICmd = SynchroniseKnowLedgeAPICmd()
        synchroniseKnowLedgeAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        synchroniseKnowLedgeAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","time":time]
        synchroniseKnowLedgeAPICmd.loadView = LoadView()
        synchroniseKnowLedgeAPICmd.loadParentView = self.view
        synchroniseKnowLedgeAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                InfoSelectManagement.shareInstance().incrementalUpdateCategory(withData: response)
                
                self.refreshData()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    @objc func confirm() {
        
    }

}
