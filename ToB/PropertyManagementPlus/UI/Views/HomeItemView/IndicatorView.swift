//
//  IndicatorView.swift
//  PropertyManagementPlus
//
//  Created by 上海乐软信息科技有限公司 on 2018/4/12.
//  Copyright © 2018年 Lesoft. All rights reserved.
//

import UIKit
typealias Block = (Int) -> ()
class IndicatorView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var nameLab:UILabel?
    var contentLab:UILabel?
    var indicatorItemClick:Block?
    var index:NSInteger?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI();
    }
    
    func creatUI()  {
        self.backgroundColor = UIColor.white;
        let width = self.frame.size.width;
        
        self.nameLab = UILabel.init(frame: CGRect(x: 10, y: 45, width: width - 20, height: 20));
        nameLab?.textAlignment = .center;
        nameLab?.font = UIFont.systemFont(ofSize: 14);
        
        self.contentLab = UILabel.init(frame: CGRect(x: 10, y: 15, width: width - 20, height: 20));
        contentLab?.textAlignment = .center;
        contentLab?.font = UIFont.systemFont(ofSize: 14);
        contentLab?.textColor = kThemeColor;
        
        self.addSubview(self.nameLab!);
        self.addSubview(self.contentLab!);
        self.isUserInteractionEnabled = true;
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap);
    }
    
    @objc func click() {
        if (self.indicatorItemClick != nil) {
            self.indicatorItemClick!(index!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
