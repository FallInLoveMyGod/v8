//
//  MyAlarmListTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/22.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class MyAlarmListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var sendPersonLabel: UILabel!
    
    @IBOutlet weak var sendTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
