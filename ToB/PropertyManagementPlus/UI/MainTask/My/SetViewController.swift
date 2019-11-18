//
//  SetViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class SetViewController: BaseTableViewController {

    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var itemImages = ["iconofflineSet","iconAudio","icon_clear","icon_modify_pwd","icon_exit"]
    var itemTitles = ["维修业务包含离线人员","语音提示","清除缓存","修改密码","退出"]
//    var switchView = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createContentUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createContentUI () {
        
        self.setTitleView(titles: ["设置"])
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), hasHeader: false, hasFooter: false)
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemImages.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
        
        let cellIdentifier = "CellID"
        var myNormalTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if myNormalTableViewCell == nil {
            
            myNormalTableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            //myNormalTableViewCell?.accessoryType = .disclosureIndicator
            
        }
        
        if (indexPath.section == 0 || indexPath.section == 1) {
            
            let switchView = UISwitch(frame: CGRect(x: kScreenWidth - 60, y: 8, width: 40, height: 44.0))
            switchView.isOn = false
            if (indexPath.section == 0 && LocalStoreData.getIsRepairOn()?.compare("YES") == .orderedSame) {
                switchView.isOn = true
            }
            if (indexPath.section == 1 && LocalStoreData.getIsAudioReqireOn()?.compare("YES") == .orderedSame) {
                switchView.isOn = true
            }
            switchView.tag = indexPath.section
            switchView.addTarget(self,action:#selector(switchAction(mySwitch:)), for: .valueChanged)
            
            myNormalTableViewCell?.contentView.addSubview(switchView)
            
        }
//        else if (indexPath.section == 2) {
//            
//            let label = UILabel(frame: CGRect(x: kScreenWidth - 100, y: 0, width: 80, height: 44.0))
//            label.textAlignment = .right
//            
//            let dict = Bundle.main.infoDictionary
//            label.text = "V ".appending(dict!["CFBundleShortVersionString"] as! String)
//            myNormalTableViewCell?.contentView.addSubview(label)
//        }
        
        myNormalTableViewCell?.imageView?.image = UIImage(named: itemImages[indexPath.section])
        myNormalTableViewCell?.textLabel?.text = itemTitles[indexPath.section]
        
        return myNormalTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            
        } else if (indexPath.section == 2) {
            //清除缓存
            LocalToastView.toast(text: "清除成功！")
        }
//        else if (indexPath.section == 2) {
//            //检测更新
//        }
        else if (indexPath.section == 3) {
            //修改密码
    
            let modify: ModifyPwdViewController = ModifyPwdViewController()
            self.push(viewController: modify)
            
        }else if (indexPath.section == 4) {
            //退出
            logoutButtonClick()
        }
    }
    
    func logoutButtonClick() {
        //登出
        
        let loginInfo = LocalStoreData.getLoginInfo()
        
        LoadView.storeLabelText = "正在验证"
        
        let signOutAPICmd = SignOutAPICmd()
        signOutAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        signOutAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":loginInfo?.userCode ?? ""]
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
                
                var buttonActions = [#selector(SetViewController.cancel),#selector(SetViewController.confirmAction)]
                
                for (index, name) in ["取消","确认"].enumerated() {
                    
                    let alertAction = CKAlertAction(title: name, handler: { (action) in
                        self.perform(buttonActions[index])
                    })
                    alertVC.addAction(alertAction)
                }
                
                self.present(alertVC, animated: false, completion: {() in })
                
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    func logoutClearData() {
        LocalStoreData.clearLocalData()
        delegate.logoutSuccess()
        delegate.notificationAction(loginState: 2)
    }
    
    @objc func switchAction(mySwitch:UISwitch) {

        if mySwitch.tag == 1 && (mySwitch.isOn) {
            //LocalToastView.toast(text: "欢迎使用语音提示!")
            delegate.speech.speakWords = "欢迎使用语音提示"
            delegate.speech.startSpeaking()
        }
        
        LocalStoreData.setUserDefaultsData((mySwitch.isOn) ? "YES" : "NO", forKey: (mySwitch.tag == 0 ? LocalStoreData.IsRepairOn : LocalStoreData.IsAudioReqireOn))
        
        print(LocalStoreData.getIsRepairOn() ?? "");
    }
    
    @objc func cancel() {
        
    }
    
    
    
    @objc func confirmAction() {
        logoutClearData();
    }


}
