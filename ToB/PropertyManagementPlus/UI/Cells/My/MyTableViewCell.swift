//
//  MyTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var companyNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
