//  CustomCells.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import MapKit
import Eureka

//MARK: ComplaintHandlingAddLabelImageTableViewCell

public class ComplaintHandlingAddLabelImageTableViewCell : Cell<String>, CellType {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    open override func setup() {
        height = { 44.0 }
        super.setup()
    }
}

public final class ComplaintHandlingAddLabelImageTableViewRow: Row<ComplaintHandlingAddLabelImageTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ComplaintHandlingAddLabelImageTableViewCell>(nibName: "ComplaintHandlingAddLabelImageTableViewCell")
    }
}

//MARK: ComplaintHandlingAddTextFiledImageTableViewCell

public class ComplaintHandlingAddTextFiledImageTableViewCell : Cell<Set<String>>, CellType {
    
    @IBOutlet weak var textFiledImageNameLabel: UILabel!
    
    @IBOutlet weak var textFiledImageTextFiled: UITextField!
    
    
    open override func setup() {
        height = { 44.0 }
        super.setup()
    }
    
    open override func update() {
        super.update()
    }
}

public final class ComplaintHandlingAddTextFiledImageTableViewRow: Row<ComplaintHandlingAddTextFiledImageTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ComplaintHandlingAddTextFiledImageTableViewCell>(nibName: "ComplaintHandlingAddTextFiledImageTableViewCell")
    }
}




//MARK: ComplaintHandlingAddTextFiledCell

public class ComplaintHandleAddTextFiledTableViewCell : Cell<Set<String>>, CellType {
    
    @IBOutlet weak var singleTextFiledNameLabel: UILabel!
    
    @IBOutlet weak var singleTextFiled: UITextField!
    
    
    open override func setup() {
        height = { 44.0 }
        super.setup()
    }
    
    open override func update() {
        super.update()
    }
    
}

public final class ComplaintHandleAddTextFiledTableViewRow: Row<ComplaintHandleAddTextFiledTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ComplaintHandleAddTextFiledTableViewCell>(nibName: "ComplaintHandleAddTextFiledTableViewCell")
    }
}



//MARK: ComplaintHandlingAddLabelTableViewCell

public class ComplaintHandlingAddLabelTableViewCell : Cell<Set<String>>, CellType {
    
    
    @IBOutlet weak var singleShowLabel: UILabel!
    @IBOutlet weak var singleShowContentLabel: UILabel!
    
    open override func setup() {
        height = { 44.0 }
        super.setup()
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        singleShowContentLabel.text = labelvalue
        update()
    }
}

public final class ComplaintHandlingAddLabelTableViewRow: Row<ComplaintHandlingAddLabelTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ComplaintHandlingAddLabelTableViewCell>(nibName: "ComplaintHandlingAddLabelTableViewCell")
    }
}


//MARK: ComplaintHandleContentInputTableViewCell

public class ComplaintHandleContentInputTableViewCell : Cell<Set<String>>, CellType {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    open override func setup() {
        height = { 35.0 }
        super.setup()
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        update()
    }
}

public final class ComplaintHandleContentInputTableViewRow: Row<ComplaintHandleContentInputTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ComplaintHandleContentInputTableViewCell>(nibName: "ComplaintHandleContentInputTableViewCell")
    }
}

//MARK: 自定义拍照

public class TakePhotoTableViewCell : Cell<Set<String>>, CellType {
    
    open override func setup() {
        height = { 95.0 }
        super.setup()
        self.selectionStyle = .none
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        update()
    }
}

public final class TakePhotoTableViewRow: Row<TakePhotoTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<TakePhotoTableViewCell>(nibName: "TakePhotoTableViewCell")
    }
}

//MARK: 自定义签名

public class SignatureTableViewCell : Cell<Set<String>>, CellType {
    
    let signView = ZQSignatureView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 110.0))
    
    open override func setup() {
        height = { 90.0 }
        super.setup()
        self.selectionStyle = .none
        self.contentView.addSubview(signView)
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        update()
    }
    
}

public final class SignatureViewRow: Row<SignatureTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<SignatureTableViewCell>(nibName: "SignatureTableViewCell")
    }
}

//MARK: 自定义录音

public class AudioTableViewCell : Cell<Set<String>>, CellType {
    //LVRecordView
    open override func setup() {
        height = { 200.0 }
        super.setup()
        self.selectionStyle = .none
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        update()
    }
    
}

public final class AudioTableViewRow: Row<AudioTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<AudioTableViewCell>(nibName: "AudioTableViewCell")
    }
}

//MARK: 自定义录音显示

public class TaskRecordImageContentTableViewCell : Cell<Set<String>>, CellType {
    
    @IBOutlet weak var recordImageView: UIImageView!
    open override func setup() {
        height = { 40.0 }
        super.setup()
        self.selectionStyle = .none
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        update()
    }
}

public final class TaskRecordImageContentTableViewRow: Row<TaskRecordImageContentTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<TaskRecordImageContentTableViewCell>(nibName: "TaskRecordImageContentTableViewCell")
    }
}


//MARK: 自定义图片浏览


public class TaskDetailImageContentShowTableViewCell : Cell<Set<String>>, CellType {
    
    @IBOutlet weak var contentImageViewOne: UIImageView!
    
    @IBOutlet weak var contentImageViewTwo: UIImageView!
    
    @IBOutlet weak var contentImageViewThree: UIImageView!
    
    @IBOutlet weak var contentImageViewFour: UIImageView!
    
    open override func setup() {
        height = { 110.0 }
        super.setup()
        self.selectionStyle = .none
    }
    
    open override func update() {
        super.update()
    }
    
    open func update(labelvalue: String, textFiledValue: String) {
        update()
    }
    
}

public final class TaskDetailImageContentTableViewRow: Row<TaskDetailImageContentShowTableViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<TaskDetailImageContentShowTableViewCell>(nibName: "TaskDetailImageContentShowTableViewCell")
    }
}
