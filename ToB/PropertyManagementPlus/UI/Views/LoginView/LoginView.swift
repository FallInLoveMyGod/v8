//
//  LoginView.swift
//  Logindemo
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
    /**
     *  账号
     */
    var codeTextView: TextFieldImageView?
    /**
     *  账号
     */
    var userNameTextView: TextFieldImageView?
    /**
     *  密码
     */
    var passwordTextView: TextFieldImageView?
    /**
     *  顶部文字
     */
    var topTitleLable: UILabel?
    /**
     *  顶部文字
     */
    var topImageView: UIImageView?
    var codeBtn: UIButton?
    /**
     *  确定登录
     */
    var makesureRegistBtn: UIButton?
    
    var localColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLoginUI()
    }
    func setLoginUI() {
        
        localColor = UIColor(red: 0, green: 0.71, blue: 0.54, alpha: 1)
        localColor = kThemeColor
        
        self.topImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kImageViewHeight))
        self.topImageView!.center = CGPoint(x: kScreenWidth / 2, y: kScreenHeight / 5)
        self.topImageView!.contentMode = .scaleAspectFit
        self.topImageView!.image = UIImage(named: "ic_launcher-web")
        self.addSubview(topImageView!)
        
        self.topTitleLable = UILabel(frame: CGRect(x: 0, y: (topImageView?.frame.origin.y)! + (topImageView?.frame.size.height)!, width: kScreenWidth, height: kLabelHeight))
        self.topTitleLable!.text = "物管 +"
        self.topTitleLable!.font = UIFont(name: "Helvetica-BoldOblique", size: 20)
        self.topTitleLable!.textAlignment = .center
        self.topTitleLable!.textColor = UIColor.black
        self.addSubview(topTitleLable!)
        
        
        let btnWidth: CGFloat = 100
        self.codeBtn = UIButton(frame: CGRect(x: x_OffSet, y: kScreenHeight - 70, width: btnWidth, height: 35))
        self.codeBtn!.setTitle("输入用户编号", for:UIControlState())
        codeBtn!.setTitleColor(kThemeColor, for:UIControlState())
        codeBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        codeBtn!.backgroundColor = UIColor.clear
        codeBtn?.isHidden = true
        self.addSubview(codeBtn!)
        
        let space: CGFloat = 8
        let height: CGFloat = 45
        
        self.codeTextView = TextFieldImageView(frame: CGRect(x: x_OffSet, y: kScreenWidth * 2 / 3, width: kScreenWidth - x_OffSet * 2, height: height))
        codeTextView?.setUpUI(needLeftImage: false, needRightImage: false)
        self.codeTextView?.inputTextField?.placeholder = "请输入用户编号"
        self.codeTextView?.leftImage?.image = UIImage(named: "icon_phone_select@2x")
        self.addSubview(codeTextView!)
        
        self.userNameTextView = TextFieldImageView(frame: CGRect(x: x_OffSet, y: codeTextView!.frame.maxY + space, width: kScreenWidth - x_OffSet * 2, height: height))
        userNameTextView?.setUpUI(needLeftImage: false, needRightImage: false)
        self.userNameTextView?.inputTextField?.placeholder = "请输入用户名"
        self.userNameTextView?.inputTextField?.keyboardType = UIKeyboardType.namePhonePad
        self.userNameTextView?.leftImage?.image = UIImage(named: "icon_phone_select@2x")
        self.addSubview(userNameTextView!)

        self.passwordTextView = TextFieldImageView(frame: CGRect(x: x_OffSet, y: userNameTextView!.frame.maxY + space, width: kScreenWidth - x_OffSet * 2, height: height))
        passwordTextView?.setUpUI(needLeftImage: false, needRightImage: true)
        self.passwordTextView?.inputTextField?.placeholder = "请输入用户密码"
        self.passwordTextView!.inputTextField?.isSecureTextEntry = true
        self.passwordTextView!.leftImage?.image = UIImage(named: "icon_code_select@2x")
        self.addSubview(passwordTextView!)
        
        passwordTextView?.rightImage?.isUserInteractionEnabled = true
        passwordTextView?.rightImage?.image = UIImage(named: "novisible")
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(openPassWord))
        passwordTextView?.addGestureRecognizer(tapGes)
        
        self.makesureRegistBtn = UIButton(frame: CGRect(x: x_OffSet, y: passwordTextView!.frame.maxY + x_OffSet, width: kScreenWidth - x_OffSet * 2, height: height))
        makesureRegistBtn!.setTitleColor(UIColor.white, for:UIControlState())
        makesureRegistBtn!.backgroundColor = localColor
        self.makesureRegistBtn!.layer.cornerRadius = 5.0
        self.makesureRegistBtn!.layer.borderWidth = 1.0
        self.makesureRegistBtn!.layer.borderColor = UIColor.clear.cgColor
        self.addSubview(makesureRegistBtn!)


    }
    
    @objc func openPassWord() {
        if (passwordTextView?.inputTextField?.isSecureTextEntry == true) {
            passwordTextView?.rightImage?.image = UIImage(named: "visible@2x")
        }else {
            passwordTextView?.rightImage?.image = UIImage(named: "novisible@2x")
        }
        passwordTextView?.inputTextField?.isSecureTextEntry = !(passwordTextView?.inputTextField?.isSecureTextEntry)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
