//
//  LSTextFiledTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

public protocol LSTextFiledDelegate: class {
    func lSTextFiledDidChange(_ textField : UITextField)
    func lSTextFieldDidEndEditing(_ textField: UITextField)
    func lSTextFieldDidBeginEditing(_ textField: UITextField)
}

class LSTextFiledTableViewCell: UITableViewCell,UITextFieldDelegate {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contentTextFiled: UITextField!
    
    open weak var textFiledDelegate: LSTextFiledDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func loadData() {
        self.contentTextFiled.addTarget(self, action: #selector(LSTextFiledTableViewCell.textFieldDidChange(_:)), for: .editingChanged)
        self.contentTextFiled.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc open func textFieldDidChange(_ textField : UITextField) {
        if let delegate = textFiledDelegate {
            delegate.lSTextFiledDidChange(textField)
        }
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let delegate = textFiledDelegate {
            delegate.lSTextFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = textFiledDelegate {
            delegate.lSTextFieldDidEndEditing(textField)
        }
    }
    
    

    
}
