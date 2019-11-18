//
//  LinkItemDetailImageContentTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/7.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class LinkItemDetailImageContentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var contentImageViewOne: UIImageView!
    
    @IBOutlet weak var contentImageViewTwo: UIImageView!

    @IBOutlet weak var contentImageViewThree: UIImageView!
    
    @IBOutlet weak var contentImageViewFour: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
