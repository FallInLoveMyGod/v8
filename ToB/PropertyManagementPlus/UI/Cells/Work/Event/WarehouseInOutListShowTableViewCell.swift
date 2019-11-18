//
//  WarehouseInOutListShowTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/7.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class WarehouseInOutListShowTableViewCell: UITableViewCell {

    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var wareHouseName: UILabel!
    
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var number: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
