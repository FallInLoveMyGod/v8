//
//  WarehouseInInputTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

public protocol WarehouseInInputDelegate: class {
    func warehouseInInputTextFiledDidChange(_ textField : UITextField)
}

class WarehouseInInputTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    open weak var warehouseInInputDelegate: WarehouseInInputDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func loadData() {
        self.contentTextField.addTarget(self, action: #selector(WarehouseInInputTableViewCell.textFieldDidChange(_:)), for: .editingChanged)
        self.contentTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc open func textFieldDidChange(_ textField : UITextField) {
        if let delegate = warehouseInInputDelegate {
            delegate.warehouseInInputTextFiledDidChange(textField)
        }
    }
    
}
