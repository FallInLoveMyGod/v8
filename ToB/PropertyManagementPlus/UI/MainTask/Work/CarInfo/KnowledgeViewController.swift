//
//  KnowledgeViewController.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/7/5.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class KnowledgeViewController: BaseTableViewController {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var content: String? = ""
    var ppk: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTitleView(titles: ["知识详情"])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49), hasHeader: false, hasFooter: false)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kScreenHeight - 50 - 64
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
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if tableViewCell == nil {
            
            tableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        let contentTV = UITextView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 50 - 64))
        contentTV.text = content!
        tableViewCell?.contentView.addSubview(contentTV)
        
        return tableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getHeight() -> CGFloat {
        let height = BaseTool.calculateHeight(withText: content, textLabel: UIFont.systemFont(ofSize: 15), isCaculateWidth: true, widthOrHeightData: kScreenWidth)
        if (height < 44) {
            return 44.0
        }
        return height + 10
    }
    
    override func requestData() {
        
        //GetKnowLedgeDetailAPICmd
        
        LoadView.storeLabelText = "正在加载"
        
        let getKnowLedgeDetailAPICmd = GetKnowLedgeDetailAPICmd()
        getKnowLedgeDetailAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getKnowLedgeDetailAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","ppk":ppk ?? ""]
        getKnowLedgeDetailAPICmd.loadView = LoadView()
        getKnowLedgeDetailAPICmd.loadParentView = self.view
        getKnowLedgeDetailAPICmd.transactionWithSuccess({ (response) in
            
            print(response)
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                self.content = dict["infos"][0]["protext"].string
                self.contentTableView?.reloadData()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
}
