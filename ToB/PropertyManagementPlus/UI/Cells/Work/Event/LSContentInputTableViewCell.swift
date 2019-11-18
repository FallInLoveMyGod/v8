//
//  LSContentInputTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

public protocol LSContentInputTextViewDelegate: class {
    func lStextViewDidChange(_ textView: UITextView)
    func lSTextViewDidBeginEditing(_ textView: UITextView)
    func lSTextViewDidEndEditing(_ textView: UITextView)
}

class LSContentInputTableViewCell: UITableViewCell,UITextViewDelegate {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var nameTipLabel: UILabel!
    var placeHolder = ""
    
    open weak var contentInputTextViewDelegate: LSContentInputTextViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    open func loadData() {
        placeHolder = self.placeHolderLabel.text!
        self.nameTipLabel.text = self.placeHolderLabel.text!
        self.contentTextView.delegate = self
    }
    
    //UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let delegate = contentInputTextViewDelegate {
            delegate.lSTextViewDidEndEditing(textView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let delegate = contentInputTextViewDelegate {
            delegate.lSTextViewDidBeginEditing(textView)
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.compare("") != .orderedSame {
            self.placeHolderLabel.isHidden = true
            self.nameTipLabel.isHidden = false
            let number = 200 - textView.text.characters.count
            self.numberLabel.text = "最大字数200，还可输入".appending(String(number));
            
        }else {
            self.nameTipLabel.isHidden = true
            self.placeHolderLabel.isHidden = false
            self.numberLabel.text = "最大字数200，还可输入200";
        }
        if let delegate = contentInputTextViewDelegate {
            delegate.lStextViewDidChange(textView)
        }
    }
}
