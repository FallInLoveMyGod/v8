//
//  TaskNumberTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/10.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class TaskNumberTableViewCell: UITableViewCell {

    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var traingConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberLabelTrailConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberLabelWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
