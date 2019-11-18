//
//  TextFieldImageView.swift
//  Logindemo
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

class TextFieldImageView: UIView {

    /**
     *  输入框
     */
    var inputTextField: UITextField? {
        didSet{
            inputTextField!.placeholder = "user"//这里要写个不写没有效果，不知为啥
            let color = UIColor.lightGray
            inputTextField!.setValue(color, forKeyPath: "_placeholderLabel.textColor")
        }
    }
    
    /**
     *  左边图片
     */
    var leftImage: UIImageView?
    
    /**
     *  右边图片
     */
    var rightImage: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.layer.cornerRadius = 5.0
        //UIColor(red: 0, green: 0.71, blue: 0.54, alpha: 1).cgColor
        //self.layer.borderColor = kThemeColor.cgColor
        //self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        
        let lineView = UIView(frame: CGRect(x: 0, y: frame.size.height - 1.0, width: frame.size.width, height: 1.0))
        lineView.backgroundColor = UIColor.groupTableViewBackground
        self.addSubview(lineView)
        
        //setUpUI()
    }

    func setUpUI(needLeftImage: Bool, needRightImage: Bool) {
        
        
        let bgImage: UIImageView = UIImageView(frame: self.bounds)
        bgImage.image = UIImage(named: "")
        bgImage.isUserInteractionEnabled = true
        bgImage.layer.cornerRadius = 5.0
        bgImage.layer.borderWidth = 1.0
        bgImage.layer.borderColor = UIColor.clear.cgColor
        bgImage.layer.masksToBounds = true
        self.addSubview(bgImage)
        
        
        leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.height, height: self.bounds.size.height))
        leftImage!.contentMode = .center
        
        /*
        bgImage.addSubview(leftImage!)
        */
        
        rightImage = UIImageView(frame: CGRect(x: self.bounds.size.width - 20, y: 0, width: 15, height: self.bounds.size.height))
        rightImage!.contentMode = .center
        
        if (needLeftImage) {
            
        }
        
        if (needRightImage) {
            
            bgImage.addSubview(rightImage!)
            
            self.inputTextField = UITextField(frame: CGRect(x: 8, y: 0, width: self.bounds.size.width - 10 - (rightImage?.frame.size.width)!, height: leftImage!.frame.size.height))
        }else {
            
            self.inputTextField = UITextField(frame: CGRect(x: 8, y: 0, width: self.bounds.size.width - 10, height: leftImage!.frame.size.height))
            
        }

        //CGRect(x: leftImage!.frame.origin.x + leftImage!.frame.size.width + 5, y: 0, width: self.bounds.size.width - leftImage!.frame.size.width, height: leftImage!.frame.size.height)
        
        self.inputTextField!.textColor = UIColor.black
        self.inputTextField!.clearButtonMode = .whileEditing
        self.inputTextField!.returnKeyType = .next
        self.inputTextField?.font = UIFont.systemFont(ofSize: 15)
        bgImage.addSubview(inputTextField!)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
