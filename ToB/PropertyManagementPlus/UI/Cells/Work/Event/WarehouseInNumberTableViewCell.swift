//
//  WarehouseInNumberTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

public protocol WarehouseInNumberDelegate: class {
    func warehouseInNumberTextFiledDidChange(_ textField : UITextField, tag: Int)
}

class WarehouseInNumberTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var numberNameLabel: UILabel!
    
    @IBOutlet weak var numberTextField: UITextField!
    
    @IBOutlet weak var numberNameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var priceNameLabel: UILabel!
    
    @IBOutlet weak var priceNameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var priceTextFieldConstraint: NSLayoutConstraint!
    open weak var warehouseInNumberDelegate: WarehouseInNumberDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func loadData() {
        self.numberTextField.addTarget(self, action: #selector(WarehouseInNumberTableViewCell.textFieldDidChange(_:)), for: .editingChanged)
        self.priceTextField.addTarget(self, action: #selector(WarehouseInNumberTableViewCell.textFieldDidChange(_:)), for: .editingChanged)
        self.numberTextField.delegate = self
        self.priceTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc open func textFieldDidChange(_ textField : UITextField) {
        if let delegate = warehouseInNumberDelegate {
            if (textField == self.priceTextField) {
                delegate.warehouseInNumberTextFiledDidChange(textField, tag: 2)
            }else {
                delegate.warehouseInNumberTextFiledDidChange(textField, tag: 1)
            }
        }
    }
    
}
