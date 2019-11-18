//
//  SafeCheckMemoTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

public protocol SafeCheckMemoTextFieldDelegate: class {
    func safeCheckMemoTextFieldDidChange(_ textField : UITextField)
    func safeCheckMemoTextFieldDidEndEditing(_ textField: UITextField)
    func safeCheckMemoTextFieldDidBeginEditing(_ textField: UITextField)
}

class SafeCheckMemoTableViewCell: BaseTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var memoTextField: UITextField!
    
    open weak var textFiledDelegate: SafeCheckMemoTextFieldDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func loadData() {
        self.memoTextField.addTarget(self, action: #selector(SafeCheckMemoTableViewCell.textFieldDidChange(_:)), for: .editingChanged)
        self.memoTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc open func textFieldDidChange(_ textField : UITextField) {
        if let delegate = textFiledDelegate {
            delegate.safeCheckMemoTextFieldDidChange(textField)
        }
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let delegate = textFiledDelegate {
            delegate.safeCheckMemoTextFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = textFiledDelegate {
            delegate.safeCheckMemoTextFieldDidEndEditing(textField)
        }
    }
    
}
