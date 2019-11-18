//
//  LinkItemSendTaskViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class LinkItemSendTaskViewController: BaseTableViewController,RepairChooseSenderResultDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var billCode = ""
//    var dataSource = ["选择派单人","选择派单人+离线","选择维修人","选择维修人+离线","发起抢单","发起抢单+离线"]
    var dataSource = ["选择派单人","选择维修人","发起抢单"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.setTitleView(titles: ["选择分派方式"])
        
        refreshUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 49))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (tableViewCell == nil) {
            tableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        tableViewCell?.textLabel?.text = dataSource[indexPath.row]
        
        return tableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let choose = RepairChooseSenderViewController()
        choose.delegate = self
        choose.billCode = billCode
        choose.accountCode = loginInfo?.accountCode ?? ""
        choose.upk = userInfo?.upk ?? ""
        choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
        
        if (LocalStoreData.getIsRepairOn()?.compare("YES") == .orderedSame) {
            choose.lineState = "0"
        }else {
            choose.lineState = "1"
        }
        
        /*
        if (indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5) {
            choose.lineState = "1"
        }else {
            choose.lineState = "0"
        }*/
        
        //choose.chooseTitle = actionSheet.buttonTitle(at: buttonIndex)
        choose.chooseTitle = dataSource[indexPath.row]
        self.navigationController?.pushViewController(choose, animated: true)
    }
    
    override func requestData() {
        self.stopFresh()
    }
    
    func popAction(_ result: String!, message: String!) {
        if (result.compare("success") == .orderedSame) {
            popToLinksHome()
        }else {
            if (message.compare("") == .orderedSame) {
                self.back()
            }else {
                LocalToastView.toast(text: message)
            }
            
        }
    }
    
    func popAction(_ result: String!) {
        self.popAction(result, message: "")
    }
    
    override func pop() {
        
        alert(title: "提示", message: "未完成派送任务，退出后只能通过PC端进行分派！", buttonAction: [#selector(back),#selector(LinkItemSendTaskViewController.sendTask)], buttonNames: ["确认","返回"], type: 1)
        
    }
    
    @objc func sendTask() {
        
    }
    
    @objc func back() {
        super.pop()
    }

}
