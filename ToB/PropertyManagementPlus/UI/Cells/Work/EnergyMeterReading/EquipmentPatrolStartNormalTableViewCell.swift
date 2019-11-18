//
//  EquipmentPatrolStartNormalTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

protocol EquipmentPatrolStartNormalDelegate {
    func valueChange(tag: Int, index: Int, content: String)
}

class EquipmentPatrolStartNormalTableViewCell: UITableViewCell {

    @IBOutlet weak var methodHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var requireHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    
    @IBOutlet weak var requireLabel: UILabel!
    
    @IBOutlet weak var checkTextField: UITextField!
    
    @IBOutlet weak var instructionTextField: UITextField!
    
    @IBOutlet weak var isMustImageView: UIImageView!
    
    @IBOutlet weak var valueLineView: UIView!
    
    
    fileprivate var descriptions: [String] = []
    
    var delegate: EquipmentPatrolStartNormalDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func refreshUI(model: EquipmentPatrolGroupConentModel) {
        
        let itemModel = EquipmentPatrolGroupItemModel.find(byCriteria: " WHERE TaskPK = '".appending(model.TaskPK!).appending("'"))[0] as! EquipmentPatrolGroupItemModel
        
        self.methodLabel.text = itemModel.CheckMeans
        self.requireLabel.text = itemModel.Need
        self.nameLabel.text = "  ".appending(itemModel.Content!)
        
        let methodHeight = BaseTool.calculateHeight(withText: self.methodLabel.text, font: self.methodLabel.font, isCaculateWidth: false, data: kScreenWidth - 95)
        self.methodHeightConstraint.constant = methodHeight < 35.0 ? 35.0 : methodHeight
        
        let requireHeight = BaseTool.calculateHeight(withText: self.requireLabel.text, font: self.requireLabel.font, isCaculateWidth: false, data: kScreenWidth - 95)
        self.requireHeightConstraint.constant = requireHeight < 35.0 ? 35.0 : requireHeight
      
        if let typeDescription = itemModel.TypeDescription {
            descriptions = (typeDescription).components(separatedBy: "|")
        }
        
        self.checkTextField.addTarget(self, action: #selector(textFieldValueChange(textField:)), for: .editingChanged)
        self.instructionTextField.addTarget(self, action: #selector(textFieldValueChange(textField:)), for: .editingChanged)
        
        if descriptions[descriptions.count - 1] == "1" {
            //文本
        } else {
            //数值
            self.checkTextField.text = (descriptions[0] == "0" ? "" : descriptions[0])
            self.checkTextField.keyboardType = .decimalPad
        }
    }
    
    @objc func textFieldValueChange(textField: UITextField) {
        if textField == self.checkTextField && descriptions[descriptions.count - 1] != "1" {
            //数值型
            if let text = textField.text, text != "" {
                let min = Int(descriptions[1])!
                let max = Int(descriptions[2])!
                let inner = Int(descriptions[3])
                let middle = Int(text)!
                //0-范围内异常，1-范围外异常
                if (inner == 0 && middle >= min && middle <= max)
                   || (inner == 1 && !(middle >= min && middle <= max)) {
                    self.checkTextField.textColor = UIColor.red
                    self.valueLineView.backgroundColor = UIColor.red
                } else {
                    self.checkTextField.textColor = UIColor.darkText
                    self.valueLineView.backgroundColor = UIColor.groupTableViewBackground
                }
            } else {
                self.checkTextField.textColor = UIColor.red
                self.valueLineView.backgroundColor = UIColor.red
            }
            
        }
        self.delegate?.valueChange(tag: self.tag, index: (textField == self.checkTextField ? 0 : 1), content: textField.text ?? "")
    }
    
}
