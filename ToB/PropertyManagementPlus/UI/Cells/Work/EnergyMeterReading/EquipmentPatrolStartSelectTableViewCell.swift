//
//  EquipmentPatrolStartSelectTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

protocol EquipmentPatrolStartSelectDelegate {
    func valueChangeSelect(tag: Int, index: Int, content: String)
    func selectedValue(tag: Int, descriptions: [String])
}

class EquipmentPatrolStartSelectTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var methodNameLabel: UILabel!
    @IBOutlet weak var requireNameLabel: UILabel!
    @IBOutlet weak var checkNameLabel: UILabel!
    @IBOutlet weak var desNameLabel: UILabel!
    
    @IBOutlet weak var bottomTextFiledLineView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var methodLabel: UILabel!

    @IBOutlet weak var requireLabel: UILabel!
    
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var constructTextField: UITextField!
    
    @IBOutlet weak var requireHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var methodHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var isMustImageView: UIImageView!
    
    
    @IBOutlet weak var selectViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var descriptions: [String] = []
    
    var delegate: EquipmentPatrolStartSelectDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func safeCheckRefresh(model: SafeCheckItemModel, selectItemHeight: CGFloat, tempModel:EquipmentPatrolGroupConentModel) {
        if NSString.init(string: model.Type).boolValue == false {
            return;
        }
//        if NSString.init(string: model.Type).boolValue == false {
//            self.methodNameLabel.isHidden = true
//            self.requireNameLabel.isHidden = true
//            self.checkNameLabel.isHidden = true
//            self.desNameLabel.isHidden = false
//            self.constructTextField.isHidden = false
//            self.bottomTextFiledLineView.isHidden = false
//            let textV = UITextView.init(frame: CGRect(x: 0, y: 4, width: kScreenWidth, height: 170))
//            self.contentView.addSubview(textV)
//        }
//        else {
            self.methodNameLabel.isHidden = false
            self.requireNameLabel.isHidden = false
            self.checkNameLabel.isHidden = false
            self.methodNameLabel.text = "  检测说明"
            self.requireNameLabel.text = "  检测要求"
            self.checkNameLabel.text = "  选择检查值结果"
            self.desNameLabel.isHidden = true
            self.constructTextField.isHidden = true
            self.bottomTextFiledLineView.isHidden = true
            if let contentItem = EquipmentPatrolGroupItemModel.yy_model(withJSON: model.yy_modelToJSONObject() ?? {}) {
////                let group = EquipmentPatrolGroupConentModel()
////                            tempModel.Value = ""
//                refresh(itemModel: contentItem, model: tempModel, selectItemHeight: selectItemHeight)
                let group = EquipmentPatrolGroupConentModel()
                group.Value = ""
                refresh(itemModel: contentItem, model: tempModel, selectItemHeight: selectItemHeight)
            }
//        }
    }
    
    func refreshUI(model: EquipmentPatrolGroupConentModel, selectItemHeight: CGFloat) {
        
        let itemModel = EquipmentPatrolGroupItemModel.find(byCriteria: " WHERE TaskPK = '".appending(model.TaskPK!).appending("'"))[0] as! EquipmentPatrolGroupItemModel
        refresh(itemModel: itemModel, model: model, selectItemHeight: selectItemHeight)
    }
    
    func refresh(itemModel: EquipmentPatrolGroupItemModel, model: EquipmentPatrolGroupConentModel, selectItemHeight: CGFloat) {
        
        self.methodLabel.text = itemModel.CheckMeans
        self.requireLabel.text = itemModel.Need
        self.nameLabel.text = "  ".appending(itemModel.Content!)
        
        let methodHeight = BaseTool.calculateHeight(withText: self.methodLabel.text, font: self.methodLabel.font, isCaculateWidth: false, data: kScreenWidth - 95)
        self.methodHeightConstraint.constant = methodHeight < 35.0 ? 35.0 : methodHeight
        
        let requireHeight = BaseTool.calculateHeight(withText: self.requireLabel.text, font: self.requireLabel.font, isCaculateWidth: false, data: kScreenWidth - 95)
        self.requireHeightConstraint.constant = requireHeight < 35.0 ? 35.0 : requireHeight
        
        self.selectViewHeightConstraint.constant = selectItemHeight
        
        self.constructTextField.addTarget(self, action: #selector(textFieldValueChange(textField:)), for: .editingChanged)
        
        if let typeDescription = itemModel.TypeDescription {
            descriptions = (typeDescription).components(separatedBy: ";")
        }
        
        var startX = CGFloat(0)
        var startY = CGFloat(0)
        var index = 0
        for value in descriptions {
            
//                        if index % 4 == 0 {
//                            startX = 0
//                            startY = startY + 30
//                        }
            if value == "" {
                continue
            }
            let contents = value.components(separatedBy: "|")
            
            let title = "  ".appending(contents[1])
            let itemWidth = BaseTool.calculateHeight(withText: title, font: UIFont.systemFont(ofSize: 13), isCaculateWidth: true, data: 30) + 30
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: startX, y: startY, width: itemWidth, height: 30)
            button.setTitle("  ".appending(contents[1]), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            if contents[4] == "1" {
                button.setTitleColor(UIColor.red, for: .normal)
            } else {
                button.setTitleColor(UIColor.black, for: .normal)
            }
            button.setImage(UIImage(named: "unchecked"), for: .normal)
            button.setImage(UIImage(named: "checked"), for: .selected)
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            button.tag = index + 1
            
            if model.Value == "" {
                if contents[3] == "1" {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            } else {
                if model.Value == contents[2] {
                    button.isSelected = true
                }
            }
            self.chooseView.addSubview(button)
            
            if (startX + itemWidth) < kScreenWidth - itemWidth {
                startX += itemWidth
            } else {
                startX = CGFloat(0)
                startY += 30
            }
            
            index = index + 1
        }
    }
    
    @objc func buttonAction(sender: UIButton) {
        
        for view in self.chooseView.subviews {
            if view.isKind(of: UIButton.self) {
                let button = view as! UIButton
                button.isSelected = false
            }
        }
        
        sender.isSelected = true
        
        self.delegate?.selectedValue(tag: self.tag, descriptions: descriptions[sender.tag - 1].components(separatedBy: "|"))
//        self.delegate?.valueChangeSelect(tag: self.tag, index: sender.tag - 1, content: descriptions[sender.tag - 1]);
    }
    
    @objc func textFieldValueChange(textField: UITextField) {
        self.delegate?.valueChangeSelect(tag: self.tag, index: 1, content: textField.text ?? "")
    }
    
}
