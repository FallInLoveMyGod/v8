//
//  MenuViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class MenuViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var manageTypeLabel: UILabel!
    
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var rightSpaceConstraint: NSLayoutConstraint!
    var listArray = ["参数设置", "系统更新", "帮助与反馈", "关于我们"];
    var icons = ["icon_xtgx","icon_sjtb_min","icon_help","icon_gywm"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightSpaceConstraint.constant = kScreenWidth * 0.35
        
        let userInfo = LocalStoreData.getUserInfo()
        
        self.userNameLabel.text = userInfo?.name
        self.domainLabel.text = LocalStoreData.getPMSAddress().PMSAddress
        
        if (userInfo?.type?.compare("1") == .orderedSame) {
            self.manageTypeLabel.text = "普通用户"
        }else {
            self.manageTypeLabel.text = "管理员"
        }
        contentTableView.backgroundColor = UIColor.clear
        contentTableView.estimatedRowHeight = 0
        contentTableView.estimatedSectionHeaderHeight = 0
        contentTableView.estimatedSectionFooterHeight = 0
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.separatorStyle = .none
        contentTableView.tableFooterView = UIView.init();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier  = "cellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.backgroundColor = UIColor.clear
            cell?.textLabel?.textColor = UIColor.white
        }
        
        cell?.textLabel?.text = listArray[indexPath.row];
        cell?.imageView?.image = UIImage(named: icons[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func logoutButtonClick(_ sender: UIButton) {
        //登出
        
        let loginInfo = LocalStoreData.getLoginInfo()

        LoadView.storeLabelText = "正在验证"
        
        let signOutAPICmd = SignOutAPICmd()
        signOutAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        signOutAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","userCode":loginInfo?.userCode ?? ""]
        signOutAPICmd.loadView = LoadView()
        signOutAPICmd.loadParentView = self.view
        signOutAPICmd.transactionWithSuccess({ (response) in
            
            //https://github.com/SwiftyJSON/SwiftyJSON
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.logoutClearData();
                
            }else {
                
                let alertVC: LSAlertViewController = LSAlertViewController.alert(withTitle: "提示", message: "服务器登出失败，是否继续本地登出？",placeHolder: "", type: CKAlertViewType(rawValue: UInt(1))!)
                
                var buttonActions = [#selector(MenuViewController.cancel),#selector(MenuViewController.confirmAction)]
                
                for (index, name) in ["取消","确认"].enumerated() {
                    
                    let alertAction = CKAlertAction(title: name, handler: { (action) in
                        self.perform(buttonActions[index])
                    })
                    alertVC.addAction(alertAction)
                }
                
                self.present(alertVC, animated: false, completion: {() in })
                
            }
            
        }) { (response) in
//            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    func logoutClearData() {
        LocalStoreData.clearLocalData()
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logoutSuccess()
        delegate.notificationAction(loginState: 2)
    }
    
    @objc func cancel() {
        
    }
    
    @objc func confirmAction() {
        logoutClearData();
    }
}
