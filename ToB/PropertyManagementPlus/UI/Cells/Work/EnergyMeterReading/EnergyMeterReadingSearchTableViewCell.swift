//
//  EnergyMeterReadingSearchTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class EnergyMeterReadingSearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var readStatusImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
