//
//  SafeCheckListTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafeCheckListTableViewCell: BaseTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
