//
//  LinkListViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/10.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class LinkListViewController: BaseTableViewController {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var selectIndex: NSInteger = 0
    
    var getContactFormInfoDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var searchContactFormDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    var notificationBillCode = ""
    var notificationType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: ["客服联系单"])
        self.addSegmentView(titles: ["我的联系单","所有联系单"])
        
        refreshUI(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: kScreenHeight - 115 - 49))
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        self.pageIndex = 1
        requestData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func netDisconnet() {
        
        DispatchQueue.main.async(execute: {
            
            self.changeTopUIFrame(height: 50)
        })
        
    }
    
    override func netConnect() {
        
        DispatchQueue.main.async(execute: {
            
            self.changeTopUIFrame(height: 0)
        })
        
    }
    
    func changeTopUIFrame(height: CGFloat) {
        
        self.view.viewWithTag(kSegmentViewTag)?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50 + height)
        self.segmentView.frame = CGRect(x: 40, y: height, width: kScreenWidth - 80, height: 40)
        
        self.contentTableView?.frame = CGRect(x: 0, y: 50 + height, width: kScreenWidth, height: kScreenHeight - (101 + height))
        
        self.view.viewWithTag(kNetDisConnectViewTag)?.removeFromSuperview()
        
        let netDisConnectView = Bundle.main.loadNibNamed("NetDisConnectView", owner: self, options: nil)?.first as! NetDisConnectView
        netDisConnectView.tag = kNetDisConnectViewTag
        netDisConnectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
        if (height == 50) {
            self.view.addSubview(netDisConnectView)
        }else {
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectIndex == 0 {
            return searchContactFormDataSource.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectIndex == 0 {
            return 1
        }
        return getContactFormInfoDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectIndex == 0 {
            return 110
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectIndex == 0 {
            return 8
        }
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        if selectIndex == 0 {
            
            var linkListTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if linkListTableViewCell == nil {
                
                linkListTableViewCell = Bundle.main.loadNibNamed("LinkListTableViewCell", owner: nil, options: nil)?.first as! LinkListTableViewCell
                linkListTableViewCell?.selectionStyle = .none
            }
            
            let model = self.searchContactFormDataSource[indexPath.section] as! SearchContactFormModel
            let tempCell = linkListTableViewCell as! LinkListTableViewCell
            tempCell.typeLabel.text = model.type?.appending("(").appending(model.code!).appending(")")
            tempCell.timeLabel.text = BaseTool.dealDate(withDateString: model.contactDate)
            tempCell.linkPersonLabel.text = String("联系人  " + model.contactName!)
            tempCell.linkPhoneLabel.text = String("联系电话  " + model.contactPhone!)
            tempCell.addressLabel.text = String("地址  " + model.address!)
            tempCell.contentLabel.text = String("内容  " + model.content!)
            
            tempCell.linkPersonLabel.attributedText = specialAttribute(content: tempCell.linkPersonLabel.text!, rangeStr: model.contactName!)
            tempCell.linkPhoneLabel.attributedText = specialAttribute(content: tempCell.linkPhoneLabel.text!, rangeStr: model.contactPhone!)
            tempCell.addressLabel.attributedText = specialAttribute(content: tempCell.addressLabel.text!, rangeStr: model.address!)
            tempCell.contentLabel.attributedText = specialAttribute(content: tempCell.contentLabel.text!, rangeStr: model.content!)
            
            return linkListTableViewCell!
            
        }
        
        var taskNumberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskNumberTableViewCell == nil {
            
            taskNumberTableViewCell = Bundle.main.loadNibNamed("TaskNumberTableViewCell", owner: nil, options: nil)?.first as! TaskNumberTableViewCell
            taskNumberTableViewCell?.selectionStyle = .none
            if (selectIndex == 1) {
                taskNumberTableViewCell?.accessoryType = .disclosureIndicator
            }else {
                taskNumberTableViewCell?.accessoryType = .none
            }
//            taskNumberTableViewCell?.separatorInset = .zero
//            taskNumberTableViewCell?.layoutMargins = .zero
//            taskNumberTableViewCell?.preservesSuperviewLayoutMargins = false
        }
        
        let model = self.getContactFormInfoDataSource[indexPath.row] as! ContactFormInfoModel
        let tempCell = taskNumberTableViewCell as! TaskNumberTableViewCell
        tempCell.nameLabel.text = model.name
        tempCell.numberLabel.text = model.num
        
        return taskNumberTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (selectIndex == 1) {
            
            let model = self.getContactFormInfoDataSource[indexPath.row] as! ContactFormInfoModel
            
            let linkVC = LinkItemListViewController()
            linkVC.titleContent = model.name! + ",共(" as NSString?
            linkVC.state = model.state
            self.push(viewController: linkVC)
            
        }else {
            
            let model = self.searchContactFormDataSource[indexPath.section] as! SearchContactFormModel
            
            let linkDetailVC = LinkItemDetailViewController()
            if (model.state == "0") {
                linkDetailVC.isNeedDeal = true
            }
            else {
                linkDetailVC.isNeedDeal = false
            }
            
            linkDetailVC.contentModel = model
            linkDetailVC.notificationType = notificationType
            self.push(viewController: linkDetailVC)
            
            notificationType = ""
        }
        
    }
    
    override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        selectIndex = segmentView.selectedSegmentIndex
        self.requestData()
    }
    
    override func requestData() {
        
        super.requestData()
        
        if (selectIndex == 0) {
            
            LoadView.storeLabelText = "正在加载我的联系单信息"
            
            let searchContactFormAPICmd = SearchContactFormAPICmd()
            searchContactFormAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            searchContactFormAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","PageIndex":self.pageIndex,"PageSize":self.pageSize,"type":2]
            searchContactFormAPICmd.loadView = LoadView()
            searchContactFormAPICmd.loadParentView = self.view
            searchContactFormAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    if (self.pageIndex == 1) {
                        self.searchContactFormDataSource.removeAllObjects()
                    }
                    
                    for (_,tempDict) in dict["Infos"] {
    
                        if let searchContactFormModel:SearchContactFormModel = JSONDeserializer<SearchContactFormModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                            self.searchContactFormDataSource.add(searchContactFormModel)
                        }
    
                    }
                    
                    self.searchContactFormDataSource.sort(comparator: { (modelF, modelS) -> ComparisonResult in
                        let modelFT = modelF as! SearchContactFormModel
                        let modelST = modelS as! SearchContactFormModel
                        return (modelST.contactDate?.compare(modelFT.contactDate!))!
                    });
                    
                    var index = 0
                    for model in self.searchContactFormDataSource {
                        let searchModel = model as! SearchContactFormModel
                        if searchModel.code == self.notificationBillCode {
                            self.tableView(self.contentTableView!, didSelectRowAt: IndexPath(row: index, section: 0))
                            self.notificationBillCode = ""
                            break
                        }
                        index += 1
                    }
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }else {
            
            LoadView.storeLabelText = "正在加载所有联系单信息"
            
            let getContactFormInfoAPICmd = GetContactFormInfoAPICmd()
            getContactFormInfoAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getContactFormInfoAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getContactFormInfoAPICmd.loadView = LoadView()
            getContactFormInfoAPICmd.loadParentView = self.view
            getContactFormInfoAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.getContactFormInfoDataSource.removeAllObjects()
                    for (_,tempDict) in dict["Infos"] {
    
                        if let contactFormInfoModel:ContactFormInfoModel = JSONDeserializer<ContactFormInfoModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
                            self.getContactFormInfoDataSource.add(contactFormInfoModel)
                        }
    
                    }
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }
        
    }
    
    func specialAttribute(content: String, rangeStr: String) -> NSMutableAttributedString {
        
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string: content)
        let str = NSString(string: content)
        let theRange = str.range(of: rangeStr)
        attrstring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: theRange)
        
        return attrstring
    }

}
