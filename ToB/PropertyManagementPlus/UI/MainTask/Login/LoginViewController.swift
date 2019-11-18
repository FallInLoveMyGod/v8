//
//  LoginViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/8.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    /**
     *  登录 view
     */
    var loginView: LoginView?
    var isVertify: Bool = false
    let loginInfo = LocalStoreData.getLoginInfo()
    var currentTextFiled: UITextField?
    var companyName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        /*
        //毛玻璃
        var blurEffect: UIVisualEffect
        blurEffect = UIBlurEffect.init(style:.dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1.5)
        visualEffectView.alpha = 0.4
        UIView.commitAnimations()
        visualEffectView.frame = self.view.bounds
        
        self.view!.addSubview(visualEffectView)
 
        */
        
        self.loginView = LoginView(frame: self.view.bounds)
        self.loginView!.alpha = 0.0
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(2.5)
        self.loginView!.alpha = 1.0
        UIView.commitAnimations()
        self.view!.addSubview(loginView!)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(resign))
        self.loginView?.addGestureRecognizer(tapGes)
        
        self.loginView!.codeTextView?.inputTextField?.delegate = self
        self.loginView!.userNameTextView?.inputTextField?.delegate = self
        self.loginView!.passwordTextView?.inputTextField?.delegate = self
        
        self.loginView!.makesureRegistBtn!.addTarget(self, action: #selector(LoginViewController.loginSuccess), for: .touchUpInside)
        self.loginView?.codeBtn!.addTarget(self, action: #selector(LoginViewController.inputCode), for: .touchUpInside)
        
        setTextFieldTransform()
        loginUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if loginInfo != nil {
            self.loginView!.codeTextView?.inputTextField?.text =  loginInfo?.accountCode ?? "";
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case (self.loginView!.codeTextView?.inputTextField)!:
            (self.loginView!.userNameTextView?.inputTextField)!.becomeFirstResponder()
            break
        case (self.loginView!.userNameTextView?.inputTextField)!:
            (self.loginView!.passwordTextView?.inputTextField)!.becomeFirstResponder()
            break
        case (self.loginView!.passwordTextView?.inputTextField)!:
            textField.resignFirstResponder()
            resign()
            break
        default:
            resign()
            break
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextFiled = textField
        var height: CGFloat = 20;
        
        switch textField {
        case (self.loginView!.codeTextView?.inputTextField)!:
            
            break
        case (self.loginView!.userNameTextView?.inputTextField)!:
            height *= 2
            break
        case (self.loginView!.passwordTextView?.inputTextField)!:
            height *= 3
            break
        default:
            break
        }
        
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            
            self.loginView!.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y - height, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            
        }){(finished) -> Void in
            
        }
        
    }
    
    /**
     *  设置登陆框 transform
     */
    
    func setTextFieldTransform() {
        self.loginView!.codeTextView!.transform = CGAffineTransform(translationX: 300, y: 0)
        self.loginView!.userNameTextView!.transform = CGAffineTransform(translationX: 300, y: 0)
        self.loginView!.passwordTextView!.transform = CGAffineTransform(translationX: 300, y: 0)
        self.loginView!.makesureRegistBtn!.transform = CGAffineTransform(translationX: 300, y: 0)
    }
    
    /**
     *  登录按钮方法
     */
    
    func loginUser() {
        
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.loginView!.codeTextView!.transform = CGAffineTransform.identity
            self.loginView!.userNameTextView!.transform = CGAffineTransform.identity
            self.loginView!.passwordTextView!.transform = CGAffineTransform.identity
            self.loginView!.makesureRegistBtn!.transform = CGAffineTransform.identity
            self.loginView!.makesureRegistBtn!.setTitle("登录", for:UIControlState())
        })
    }
    
    func disappearView () {
        
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 1.5, animations: {() -> Void in
            self.setTextFieldTransform()
        })
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1.0)
        self.loginView!.makesureRegistBtn!.alpha = 1
        UIView.commitAnimations()
        
    }
    
    @objc func loginSuccess() {
        
        let code :String = (self.loginView!.codeTextView!.inputTextField?.text!)!
        let userName :String = (self.loginView!.userNameTextView!.inputTextField?.text!)!
        
        if code.caseInsensitiveCompare("") == .orderedSame {
            LocalToastView.toast(text: "账套编号不可为空！")
            return
        }
        
        if userName.caseInsensitiveCompare("") == .orderedSame {
            LocalToastView.toast(text: "用户名不可为空！")
            return
        }
        
        vertify(custCode: code)
    }
    
    func loginNextAction() {
        
        let code :String = (self.loginView!.codeTextView!.inputTextField?.text!)!
        let userName :String = (self.loginView!.userNameTextView!.inputTextField?.text!)!
        let password :String = (self.loginView!.passwordTextView!.inputTextField?.text!)!
        
        let loginInfo = ["accountCode":code,"userCode":userName,"password":password,"encryptType":"","secretKey":""];
        
        UserDefaults.standard.removeObject(forKey: LocalStoreData.LoginInfoKey)
        LocalStoreData.setUserDefaultsData(JSON(loginInfo).rawString(), forKey: LocalStoreData.LoginInfoKey)
        
        LoadView.storeLabelText = "正在同步基础数据"
        
        let checkUser = CheckUserAPI()
        checkUser.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        checkUser.parameters = NSMutableDictionary(dictionary: loginInfo as NSDictionary)
        checkUser.loadView = LoadView()
        checkUser.loadParentView = self.view
        checkUser.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                LocalToastView.toast(text: "登录成功")
                LocalStoreData.setUserDefaultsData(JSON(dict["UserInfo"].object).rawString(), forKey: LocalStoreData.UserInfoKey)
                
//                //变更数据库地址
//                JKDBHelper.shareInstance().changeDB(withDirectoryName: LocalStoreData.getUserInfo()?.upk)
//                
//                DataSynchronizationManager.dataSynchronization()
                
                let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                delegate.loginSuccess()
                
                delegate.notificationAction(loginState: 1)
                
            }else {
                LocalToastView.toast(text: "登录失败")
            }
            
        }) { (response) in
//            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    @objc func inputCode() {
        
        let alertVC: LSAlertViewController = LSAlertViewController.alert(withTitle: "用户编号", message: "    ",placeHolder: "此编号由服务商提供", type: CKAlertViewType(rawValue: UInt(0))!)
        
        var buttonActions = [#selector(LoginViewController.cancel),#selector(LoginViewController.vertifyAction)]
        
        for (index, name) in ["取消","验证"].enumerated() {
            
            let alertAction = CKAlertAction(title: name, handler: { (action) in
                self.perform(buttonActions[index])
            })
            alertVC.addAction(alertAction)
        }
        
        self.present(alertVC, animated: false, completion: {() in
            
            self.currentTextFiled = (alertVC.contentView.viewWithTag(kVertifyTextFieldTag) as! UITextField)
            self.currentTextFiled?.delegate = self
            
            if LocalStoreData.getCustCode() != nil {
                self.currentTextFiled?.text = LocalStoreData.getCustCode() as String?
            }
            
        })
        
    }
    
    @objc func resign() {
        
        currentTextFiled?.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            
            self.loginView!.frame = self.view.bounds
            
        }){(finished) -> Void in
            
        }
    }
    
    @objc func cancel() {
        
    }
    
    @objc func vertifyAction() {
        isVertify = true
        vertifyNextAction(self.currentTextFiled!)
    }
    
    func vertify(custCode: String) {
        
        LoadView.storeLabelText = "正在验证"
        
        let vertifyCode = VertifyCodeAPI()
        vertifyCode.baseUrl = KClientInfoEventHost
        vertifyCode.parameters = ["custCode":custCode,"version":"8.1.1"]
        vertifyCode.loadView = LoadView()
        vertifyCode.loadParentView = self.view
        vertifyCode.transactionWithSuccess({ (response) in
            
            //https://github.com/SwiftyJSON/SwiftyJSON
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                LocalToastView.toast(text: "验证成功")
                LocalStoreData.setUserDefaultsData(JSON(dict["clientInfo"][0].object).rawString(), forKey: LocalStoreData.ClientInfoKey)
                LocalStoreData.setUserDefaultsData(custCode, forKey: LocalStoreData.CustCode)
                LocalStoreData.setUserDefaultsData("0", forKey: LocalStoreData.IsUse)
                LocalStoreData.setUserDefaultsData("NO", forKey: LocalStoreData.Applicense)
                
                let applicense = String(describing: dict["clientInfo"][0]["Applicense"])
                let companyName = String(describing: dict["clientInfo"][0]["CompanyName"])
                LocalStoreData.setUserDefaultsData(companyName, forKey: LocalStoreData.CompanyName)
                
                var formate = false
                
                if (applicense.compare("") == .orderedSame) {
                    formate = true
                    LocalStoreData.setUserDefaultsData("YES", forKey: LocalStoreData.Applicense)
                }else {
                    
                    let index = applicense.index(applicense.startIndex, offsetBy: 1)
                    
                    if (applicense.substring(to: index).compare("1") == .orderedSame) {
                        //正式用户
                        formate = true
                        LocalStoreData.setUserDefaultsData("YES", forKey: LocalStoreData.Applicense)
                    }
                    
                }
                
                if (formate == false && (dict["clientInfo"][0]["UseDays"]).intValue == 0) {
                    //试用天数为0
                    
                    let alertView = UIAlertView(title: "", message: "试用期已过，请联系我们！", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "知道了")
                    alertView.show()
                    
                }else {
                    
                    LocalStoreData.setUserDefaultsData(String(dict["clientInfo"][0]["UseDays"].intValue), forKey: LocalStoreData.IsUse)
                    
                    self.loginNextAction()
                }
                
            }else {
                //LocalToastView.toast(text: "验证失败")
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    func vertifyNextAction(_ textField: UITextField) {
        if isVertify {
            if textField.text != nil {
                vertify(custCode: textField.text!)
            }
            isVertify = false
        }
    }
    
    //MARK: UITextFieldDelegate
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        vertifyNextAction(textField)
    }
    

}
