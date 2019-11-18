//
//  TaskNumberImageTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/8.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class TaskNumberImageTableViewCell: UITableViewCell {

    @IBOutlet weak var traingConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
