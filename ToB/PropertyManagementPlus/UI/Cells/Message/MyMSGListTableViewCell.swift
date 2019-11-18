//
//  MyMSGListTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/22.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class MyMSGListTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sendPersonLabel: UILabel!
    @IBOutlet weak var sendTimeLabel: UILabel!
    
    @IBOutlet weak var checkStateImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
