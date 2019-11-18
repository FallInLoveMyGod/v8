//
//  SafeCheckTopLineView.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/8.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SnapKit

class SafeCheckTopLineView: UIView {
    
    fileprivate var topLineView: UIView!
    fileprivate var titleLabel: UILabel!
    var numberLabel: UILabel!
    fileprivate var arrowImageView: UIImageView!
    fileprivate var bottomLineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        titleLabel = UILabel()
        titleLabel.text = "未提交"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.red
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        arrowImageView = UIImageView()
        arrowImageView.image = UIImage(named: "icon_next")
        arrowImageView.contentMode = .scaleAspectFit
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.width.equalTo(15)
        }
        
        numberLabel = UILabel()
        numberLabel.text = ""
        numberLabel.font = UIFont.systemFont(ofSize: 15)
        numberLabel.textColor = UIColor.red
        numberLabel.textAlignment = .right
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImageView.snp.left).offset(-10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
