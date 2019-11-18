//
//  LinkListTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/10.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class LinkListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var linkPersonLabel: UILabel!
    @IBOutlet weak var linkPhoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
