//
//  HomeIndicatorCell.swift
//  PropertyManagementPlus
//
//  Created by 上海乐软信息科技有限公司 on 2018/4/12.
//  Copyright © 2018年 Lesoft. All rights reserved.
//

import UIKit

class HomeIndicatorCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var dataSource:NSArray?  {
        didSet {
            self.contentView.addSubview(self.leftView);
            self.contentView.addSubview(self.rightView);
            let model:IndicateModel? = dataSource![0] as? IndicateModel;
            leftView.nameLab?.text = model?.label;
            leftView.contentLab?.text = model?.date;
            leftView.index = Int((model?.tag)!)
            if dataSource?.count == 2 {
                let model1:IndicateModel? = dataSource![1] as? IndicateModel;
                rightView.nameLab?.text = model1?.label;
                rightView.contentLab?.text = model1?.date;
                rightView.index = Int((model1?.tag!)!)
            }
        }
    }
    var leftView:IndicatorView = IndicatorView.init(frame: CGRect(x: 1, y: 1, width: (kScreenWidth - 3) / 2.0, height: 81))
    var rightView:IndicatorView = IndicatorView.init(frame: CGRect(x: (kScreenWidth - 3) / 2.0 + 2, y: 1, width: (kScreenWidth - 3) / 2.0, height: 81))
    //    var placeView:UIView = UIView.init(frame: CGRect(x: (kScreenWidth - 3) / 2.0 + 2, y: 1, width: (kScreenWidth - 3) / 2.0, height: 81))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
