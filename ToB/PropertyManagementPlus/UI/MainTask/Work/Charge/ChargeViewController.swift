//
//  ChargeViewController.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/8/26.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class ChargeViewController: BaseViewController {

    fileprivate var topSelectedView: UIView!
    fileprivate var itemBackView: UIView!
    fileprivate var managementItemView: ManagementItemView!
    fileprivate let chooseType = "Choose-Lesoft"
    
    fileprivate let loginInfo = LocalStoreData.getLoginInfo()
    fileprivate let userInfo = LocalStoreData.getUserInfo()
    
    fileprivate var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    fileprivate var colleagueLinkPersonsDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    //楼盘编号
    fileprivate var pcode = ""
    //楼阁编号
    fileprivate var bcode = ""
    //楼层名称
    fileprivate var fname = ""
    //房间编号
    fileprivate var rcode = ""
    
    fileprivate var ownerCode = ""
    
    fileprivate var levelIndex = 0
    fileprivate var titleNames: NSMutableArray = NSMutableArray(capacity: 20)
    fileprivate var levelHouseStructureModel: HouseStructureModel = HouseStructureModel()
    fileprivate var levelResultDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    fileprivate var queryNoPayFeeDatas: [QueryNoPayFeeDataModel] = []
    fileprivate var selectQueryNoPayFeeDatas: [Int] = []
    
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.requestTopInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ChargeViewController {
    
    func refreshData() {
        
        var nextArray = customerDataSource as? NSArray
        
        if (levelIndex == 0) {
            
        }else if (levelIndex == 1) {
            nextArray = levelHouseStructureModel.PBuildings
        }else if (levelIndex == 2) {
            nextArray = levelHouseStructureModel.PFloors
        }else if (levelIndex == 3) {
            nextArray = levelHouseStructureModel.PRooms
        }
        
        
        changeTopView();
        
        var tempArray: NSMutableArray = NSMutableArray(capacity: 20)
        
        if (levelIndex == 0) {
            tempArray = nextArray as! NSMutableArray
        }else {
            
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
        }
        
        levelResultDataSource[levelIndex] = tempArray
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.contentTableView?.backgroundColor = UIColor.groupTableViewBackground
        self.contentTableView?.reloadData()
        
    }
    
    func createUI () {
        
        self.setTitleView(titles: [("上门收费" as NSString)])
        
        contentTableView.estimatedRowHeight = 0
        contentTableView.estimatedSectionHeaderHeight = 0
        contentTableView.estimatedSectionFooterHeight = 0
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        contentTableView.emptyDataSetSource = self;
        contentTableView.emptyDataSetDelegate = self;
        
        let heightTop: CGFloat = 50.0
        topSelectedView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: heightTop))
        
        let button = self.createButton(frame: CGRect(x: 0, y: 0, width: heightTop, height: heightTop), title: "", titleColor: UIColor.clear, backGroundColor: UIColor.clear, textAlignment: .left, image: UIImage(named: "icon_menu_root")!, target: self, action: #selector(pop))
        
        topSelectedView.backgroundColor = UIColor.white
        topSelectedView.addSubview(button)
        
        self.view.addSubview(topSelectedView)
        
        itemBackView = UIView(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: 50))
        managementItemView = ManagementItemView(frame: CGRect(x: 0, y: 10, width: kScreenWidth, height: 40), titles: ["项目","年月","单价","应收","未收",chooseType], lastItemWidth:50)
        managementItemView?.delegate = self
        managementItemView?.tag = 1
        itemBackView.isHidden = true
        itemBackView.backgroundColor = UIColor.groupTableViewBackground
        itemBackView.addSubview(managementItemView!)
        self.view.addSubview(itemBackView)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
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
        topHeightConstraint.constant = 50
        itemBackView.isHidden = true
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        self.contentTableView.reloadData()
    }
    
    fileprivate func requestTopInfo() {
        
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
    
    func requestQueryNoPayFeeData() {
        
        LoadView.storeLabelText = "正在查询未缴费列表"
        
        let queryNoPayFeeDataAPICmd = QueryNoPayFeeDataAPICmd()
        queryNoPayFeeDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        queryNoPayFeeDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","code": levelHouseStructureModel.Code!]
        queryNoPayFeeDataAPICmd.loadView = LoadView()
        queryNoPayFeeDataAPICmd.loadParentView = self.view
        queryNoPayFeeDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                //QueryNoPayFeeDataModel
                self.queryNoPayFeeDatas.removeAll()
                self.selectQueryNoPayFeeDatas.removeAll()
                self.selectQueryNoPayFeeDatas.append(0)
                for (_,tempDict) in dict["nopayfeeinfo"] {
                    
                    if let queryNoPayFeeDataModel:QueryNoPayFeeDataModel = QueryNoPayFeeDataModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        self.queryNoPayFeeDatas.append(queryNoPayFeeDataModel)
                        self.selectQueryNoPayFeeDatas.append(0)
                    }
                    
                }
                if self.queryNoPayFeeDatas.count == 0 {
                    self.itemBackView.isHidden = true
                } else {
                    self.itemBackView.isHidden = false
                }
                self.contentTableView.reloadData()
                
            }else {
                LocalToastView.toast(text: "获取未缴费列表失败！")
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    @objc func totalPrice() {
        
    }
    
    func addLabelWithName(contentView: UIImageView, contentTitle: String ) {
        
        contentView.viewWithTag(5555)?.removeFromSuperview()
        
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

extension ChargeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if levelIndex == 4 {
            return self.queryNoPayFeeDatas.count
        }
        
        if (levelResultDataSource.count != 0) {
            
            return (levelResultDataSource[levelIndex] as! NSArray).count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
        backView.backgroundColor = UIColor.groupTableViewBackground
        
        return backView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let detailCellIdentifier = "DetailCellIdentifier"
        let normalCellIdentifier = "NormalCellIdentifier"
        
        if levelIndex == 4 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier)
            
            if cell == nil {
                
                cell = UITableViewCell(style: .default, reuseIdentifier: detailCellIdentifier)
                cell?.selectionStyle = .none
            }
            
            for subView in (cell?.contentView.subviews)! {
                if subView is SafePatrolDetailView {
                    subView.removeFromSuperview()
                }
            }
            
            let safePatrolDetailView = SafePatrolDetailView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), lastWidth: 50.0, count: 6)
            safePatrolDetailView?.tag = indexPath.row + 1000
            if selectQueryNoPayFeeDatas.count > indexPath.row + 1 {
                safePatrolDetailView?.safePatrolDetailSelect = selectQueryNoPayFeeDatas[indexPath.row + 1]
            }
            safePatrolDetailView?.delegate = self
            
            let model = self.queryNoPayFeeDatas[indexPath.row]
            
            safePatrolDetailView?.reload(withTitles: [
                model.FeeName ?? "",
                model.DateTimeYM ?? "",
                NSString(format: "%.2f", BaseTool.toFloat(model.Price)),
                NSString(format: "%.2f", BaseTool.toFloat(model.Ramount)),
                NSString(format: "%.2f", BaseTool.toFloat(model.Ramount)),
                ""
                ], image: chooseType, colors: [
                    UIColor.black,
                    UIColor.black,
                    UIColor.black,
                    UIColor.black,
                    UIColor.black,
                    UIColor.black
                ])
            cell?.contentView.addSubview(safePatrolDetailView!)
            return cell!
            
            
        } else {
            
            var normalTableViewCell = tableView.dequeueReusableCell(withIdentifier: normalCellIdentifier)
            
            if normalTableViewCell == nil {
                
                normalTableViewCell = UITableViewCell(style: .default, reuseIdentifier: normalCellIdentifier)
                normalTableViewCell?.accessoryType = .disclosureIndicator
                normalTableViewCell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                normalTableViewCell?.separatorInset = .zero
                normalTableViewCell?.layoutMargins = .zero
                normalTableViewCell?.preservesSuperviewLayoutMargins = false
            }
            
            let model: HouseStructureModel = (levelResultDataSource[levelIndex] as! NSArray)[indexPath.row] as! HouseStructureModel
            
            if (levelIndex == 0) {
                normalTableViewCell?.textLabel?.text = model.Name
            }else if (levelIndex == 1) {
                normalTableViewCell?.textLabel?.text = model.Name
            }else if (levelIndex == 2) {
                normalTableViewCell?.textLabel?.text = model.Name
            }else if (levelIndex == 3) {
                normalTableViewCell?.textLabel?.text = model.Name?.appending("    ".appending(model.TenantName!))
            }
            return normalTableViewCell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        levelHouseStructureModel = (levelResultDataSource[levelIndex] as! NSArray)[indexPath.row] as! HouseStructureModel
        
        let tableViewCell = tableView.cellForRow(at: indexPath)
        
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
        }else if (levelIndex == 3) {
            self.requestQueryNoPayFeeData()
            topHeightConstraint.constant = itemBackView.height + 50
            itemBackView.isHidden = false
            buttonAction(titles: ["返回","总费用(0)"], actions: [#selector(pop),#selector(totalPrice)], target: self)
            setBottomView()
        }
        
        levelIndex += 1;
        
        refreshData()
    }
    
}

extension ChargeViewController {
    func totalCount() {
        var total: CGFloat = 0
        for (index, item) in selectQueryNoPayFeeDatas.enumerated() {
            if index == 0 {
                continue
            }
            if item == 1 {
                let model = queryNoPayFeeDatas[index - 1]
                total += BaseTool.toFloat(model.Ramount)
            }
        }
        
        buttonAction(titles: ["返回","总费用(\(NSString(format: "%.2f", total)))"], actions: [#selector(pop),#selector(totalPrice)], target: self)
        setBottomView()
    }
    
    func setBottomView() {
        let bottomView = self.view.viewWithTag(bottomActionTag)
        let btn = bottomView?.viewWithTag(2) as! UIButton
        //btn.setTitleColor(UIColor.red, for: .normal)
    }
}

extension ChargeViewController: ManagementItemViewDelegate {
    func selectManagementItemViewItem(_ tag: Int) {
        if selectQueryNoPayFeeDatas.count == 0 || selectQueryNoPayFeeDatas[0] == 0 {
            for (index, _) in selectQueryNoPayFeeDatas.enumerated() {
                selectQueryNoPayFeeDatas[index] = 1
            }
        } else {
            for (index, _) in selectQueryNoPayFeeDatas.enumerated() {
                selectQueryNoPayFeeDatas[index] = 0
            }
        }
        managementItemView.managementItemSelect = selectQueryNoPayFeeDatas[0]
        totalCount()
        self.contentTableView.reloadData()
    }
}

extension ChargeViewController: SafePatrolDetailViewDelegate {
    func selectSafePatrolDetailViewItem(_ tag: Int) {
        
        selectQueryNoPayFeeDatas[tag + 1] = selectQueryNoPayFeeDatas[tag + 1] == 0 ? 1 : 0
        selectQueryNoPayFeeDatas[0] = 1
        
        for (index, _) in selectQueryNoPayFeeDatas.enumerated() {
            if index == 0 {
                continue
            }
            if selectQueryNoPayFeeDatas[index] == 0 {
                selectQueryNoPayFeeDatas[0] = 0
            }
        }
        managementItemView.managementItemSelect = selectQueryNoPayFeeDatas[0]
        totalCount()
        self.contentTableView.reloadData()
    }
}

extension ChargeViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
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
    
    public func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = self.noDataDetailTitle
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14.0),NSAttributedStringKey.foregroundColor:UIColor.lightGray,
                          NSAttributedStringKey.paragraphStyle:paragraph]
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
    
    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0)]
        if (self.btnTitle.compare("") != .orderedSame) {
            return NSAttributedString(string: self.btnTitle, attributes: attributes)
        }
        return nil
    }
    
    public func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage? {
        if (self.btnImgName.compare("") != .orderedSame) {
            return UIImage(named: self.btnImgName)
        }
        return nil
    }
    
}
