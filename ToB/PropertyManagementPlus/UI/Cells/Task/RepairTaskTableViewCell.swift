//
//  RepairTaskTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/22.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class RepairTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleNameLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    @IBOutlet weak var statesLabelWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
