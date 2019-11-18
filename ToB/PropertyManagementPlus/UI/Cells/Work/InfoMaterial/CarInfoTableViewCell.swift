//
//  CarInfoTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class CarInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var materialCodeNameLabel: UILabel!
    @IBOutlet weak var materialCodeLabel: UILabel!
    
    @IBOutlet weak var materialXHNameLabel: UILabel!
    @IBOutlet weak var materialXHLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var topTrailConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
