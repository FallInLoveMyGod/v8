//
//  MaterialDataInfoDetailTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/22.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class MaterialDataInfoDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var iconTailConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
