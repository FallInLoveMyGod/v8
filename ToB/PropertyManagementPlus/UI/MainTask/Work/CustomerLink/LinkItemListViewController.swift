//
//  LinkItemListViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class LinkItemListViewController: BaseTableViewController {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var titleContent: NSString? = ""
    var state: String! = "1"
    
    var searchContactFormDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: kNotificationCenterFreshLinkItemList as NSNotification.Name, object: nil)
        
        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: [titleContent!])
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49))
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        self.requestData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterFreshLinkItemList as NSNotification.Name, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchContactFormDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.searchContactFormDataSource[indexPath.section] as! SearchContactFormModel
        
        let linkDetailVC = LinkItemDetailViewController()
        linkDetailVC.contentModel = model
        if model.state == "0" {
            linkDetailVC.isNeedDeal = true;
        }
        else {
            linkDetailVC.isNeedDeal = false;
        }
        self.push(viewController: linkDetailVC)
        
    }
    
    override func requestData() {
        super.requestData()
        
        LoadView.storeLabelText = "正在加载我的联系单信息"
        
        let searchContactFormAPICmd = SearchContactFormAPICmd()
        searchContactFormAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        searchContactFormAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","PageIndex":self.pageIndex,"PageSize":self.pageSize,"type":2,"state":state]
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
                
                let title = (self.titleContent! as String) + String(self.searchContactFormDataSource.count) + ")条"
                self.setTitleView(titles: [title as NSString])
                
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
    
    @objc func refreshData() {
        self.pageIndex = 1
        requestData()
    }
    
    func specialAttribute(content: String, rangeStr: String) -> NSMutableAttributedString {
        
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string: content)
        let str = NSString(string: content)
        let theRange = str.range(of: rangeStr)
        attrstring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: theRange)
        
        return attrstring
    }

}
