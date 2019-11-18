//
//  TaskTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/8.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var typeIconImageView: UIImageView!
    
    @IBOutlet weak var digestLabel: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
