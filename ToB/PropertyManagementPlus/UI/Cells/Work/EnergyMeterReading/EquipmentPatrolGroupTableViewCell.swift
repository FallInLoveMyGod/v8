//
//  EquipmentPatrolGroupTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

protocol GroupSelectDelegte {
    func check(index: Int)
}

class EquipmentPatrolGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var leftArrowImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var selectImageView: UIImageView!
    
    @IBOutlet weak var leadConstraint: NSLayoutConstraint!
    
    var delegate: GroupSelectDelegte?
    
    var selectImageName: String? {
        didSet {
            if let selectImageName = selectImageName {
                self.selectImageView.image = UIImage(named: selectImageName)
            }
        }
    }
    
    var arrowImageName: String? {
        didSet {
            if let imageName = arrowImageName {
                self.leftArrowImageView.image = UIImage(named: imageName)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(check))
        selectImageView.isUserInteractionEnabled = true
        selectImageView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Mark: 
    @objc func check() {
        self.delegate?.check(index: self.tag)
    }
    
}
