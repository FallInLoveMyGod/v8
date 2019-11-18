//
//  WarehouseSelectGoodsTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

protocol WarehouseSelectGoodDelegate: class {
    func selectButtonWithContent(_ content: String)
}

class WarehouseSelectGoodsTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var contentTextField: UITextField!
    open weak var warehouseSelectGoodDelegate: WarehouseSelectGoodDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func loadData() {
        self.contentTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func selectButton(_ sender: UIButton) {
        if let delegate = warehouseSelectGoodDelegate {
            delegate.selectButtonWithContent(contentTextField.text!)
        }
    }
}
