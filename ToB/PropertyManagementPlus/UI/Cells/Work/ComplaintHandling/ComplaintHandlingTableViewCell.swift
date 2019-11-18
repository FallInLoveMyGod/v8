//
//  ComplaintHandlingTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class ComplaintHandlingTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleContentLabel: UILabel!

    @IBOutlet weak var statesLabel: UILabel!
    
    @IBOutlet weak var complaintPerson: UILabel!
    @IBOutlet weak var complaintPhone: UILabel!
    @IBOutlet weak var complaintStyle: UILabel!
    
    @IBOutlet weak var complaintContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
