//
//  ModifyPwdViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class ModifyPwdViewController: BaseTableViewController,UITextFieldDelegate {

    var originalPwd: String? = ""
    var newPwd: String? = ""
    var confirmNewPwd: String? = ""
    
    var originalTextFiled: UITextField? = UITextField()
    var newTextFiled: UITextField? = UITextField()
    var confirmTextFiled: UITextField? = UITextField()
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createContentUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func createContentUI() {
        
        self.setTitleView(titles: ["修改密码"])
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), hasHeader: false, hasFooter: false)
        
        buttonAction(titles: ["返回","修改"], actions: [#selector(pop),#selector(modify)], target: self)
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var myTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if myTableViewCell == nil {
            
            myTableViewCell = Bundle.main.loadNibNamed("ModifyPwdTableViewCell", owner: nil, options: nil)?.first as! ModifyPwdTableViewCell
            myTableViewCell?.selectionStyle = .none
            
        }
        
        let tempMyTableViewCell: ModifyPwdTableViewCell = (myTableViewCell as! ModifyPwdTableViewCell)
        tempMyTableViewCell.contentTextFiled.delegate = self
        
        let textFiled = tempMyTableViewCell.contentTextFiled
        textFiled?.tag = indexPath.row + 1
        
        if (textFiled?.text?.compare("") == .orderedSame) {
            if (indexPath.row == 0) {
                textFiled?.placeholder = "原密码"
            }else if (indexPath.row == 1) {
                textFiled?.placeholder = "新密码"
            }else {
                textFiled?.placeholder = "确认新密码"
            }
        }
        
        if (textFiled?.tag == 1) {
            originalTextFiled = textFiled
        }else if (textFiled?.tag == 2) {
            newTextFiled = textFiled
        }else {
            confirmTextFiled = textFiled
        }
    
        return myTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == 1) {
            originalPwd = textField.text ?? ""
        }else if (textField.tag == 2) {
            newPwd = textField.text ?? ""
        }else {
            confirmNewPwd = textField.text ?? ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == originalTextFiled) {
            newTextFiled?.becomeFirstResponder()
        }else if (textField == newTextFiled) {
            confirmTextFiled?.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc func modify() {
        //修改密码
        
        if (NSString(string: confirmNewPwd ?? "").length < 6) {
            
            LocalToastView.toast(text: "密码长度最低六位！")
            return
        }
        
        if (newPwd?.compare(confirmNewPwd!) != .orderedSame) {
            
            LocalToastView.toast(text: "两次输入的密码不相同！")
            return
        }
        
        LoadView.storeLabelText = "正在修改密码"
        
        let modiPasswordAPICmd = ModiPasswordAPICmd()
        modiPasswordAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","oldPassWord":originalPwd ?? "","newPassWord":confirmNewPwd ?? "","version":"8.1.1"]
        modiPasswordAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        modiPasswordAPICmd.loadView = LoadView()
        modiPasswordAPICmd.loadParentView = self.view
        modiPasswordAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                LocalToastView.toast(text: "密码修改成功")
                //logoutClearData()
                
            }else {
                LocalToastView.toast(text: dict["msg"].string ?? "密码修改失败")
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    func logoutClearData() {
        LocalStoreData.clearLocalData()
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.logoutSuccess()
        delegate.notificationAction(loginState: 2)
    }

}
