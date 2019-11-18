//
//  MessageDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/3/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class MessageDetailViewController: BaseTableViewController {

    var model: GetMyMSGListModel = GetMyMSGListModel()
    var messageViewController: MessageViewController = MessageViewController()
    /*
     "IsCheck" : false,
     "SendTime" : "2017-03-13T15:50:11",
     "Tittle" : "",
     "Type" : "投诉",
     "Content" : "投诉处理单：CJ0000000181 \n  投诉人地址：永新国际广场\/A座\/第01层\/101 \n  投诉内容：服务态度监督",
     "ID" : 76,
     "SendPerson" : "System"
     
     */
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (model.Tittle != nil && model.Tittle?.compare("") != .orderedSame) {
            self.setTitleView(titles: [model.Tittle! as NSString])
        }else {
            self.setTitleView(titles: ["消息详情"])
        }
        
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 50.0), hasHeader: false, hasFooter: false)
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        
        let sendPersonTitleLable = UILabel(frame: CGRect(x: 10, y: 50, width: kScreenWidth - 20, height: 25))
        sendPersonTitleLable.textAlignment = .left
        sendPersonTitleLable.font = UIFont.systemFont(ofSize: 16)
        sendPersonTitleLable.text = model.SendPerson
        backView.addSubview(sendPersonTitleLable)
        
        let sendTimetitleLable = UILabel(frame: CGRect(x: 10, y: 70, width: kScreenWidth - 20, height: 25))
        sendTimetitleLable.textAlignment = .right
        sendTimetitleLable.font = UIFont.systemFont(ofSize: 16)
        sendTimetitleLable.text = model.SendTime?.components(separatedBy: "T").joined(separator: " ")
        backView.addSubview(sendTimetitleLable)

        return backView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.selectionStyle = .none
            
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: kScreenWidth - 30, height: 120))
            label.textAlignment = .left
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 15.0)
            label.text = model.Content
            cell?.contentView.addSubview(label)
        }
        return cell!
    }
    
    
    override func requestData() {
        
        LoadView.storeLabelText = "正在加载"
        
        
        
        if (self.messageViewController.selectIndex == 0) {
            let setMSGDownloadAPICmd = SetMSGDownloadAPICmd()
            setMSGDownloadAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            setMSGDownloadAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","strIDWH":model.ID ?? ""]
            setMSGDownloadAPICmd.loadView = LoadView()
            setMSGDownloadAPICmd.loadParentView = self.view
            setMSGDownloadAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    LocalToastView.toast(text: "消息已读！")
                    self.messageViewController.requestData()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
        }else {
            
            let setAlarmDownloadAPICmd = SetAlarmDownloadAPICmd()
            setAlarmDownloadAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            setAlarmDownloadAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","strIDWH":model.ID ?? ""]
            setAlarmDownloadAPICmd.loadView = LoadView()
            setAlarmDownloadAPICmd.loadParentView = self.view
            setAlarmDownloadAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    LocalToastView.toast(text: "消息已读！")
                    self.messageViewController.requestData()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
        }
        
        
        
    }
    
}
