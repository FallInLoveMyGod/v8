//
//  BaseTableViewCell.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var obj: Any?
    var didSetupConstraints: Bool = false
    weak var filesOwner: AnyObject?
    
    class var reuseNib: UINib {
        return UINib(nibName: self.reuseIdentifier, bundle: nil)
    }
    
    class var reuseIdentifier: String {
        return self.nameOfClassWithoutModulename
    }
    
    class func estimatedCellHeight() -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func bindDataWithObj(_ obj: Any?) {
        self.obj = obj
    }
    
    override var reuseIdentifier: String {
        return self.nameOfClassWithoutModulename
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func nibWithIdentifier(_ identifier: String) -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    class func registerTable(_ table: UITableView, nibIdentifier identifier: String) {
        table.register(self.nibWithIdentifier(identifier), forCellReuseIdentifier: identifier)
    }
    
}

extension NSObject {
    public class var nameOfClass: String {
        return NSStringFromClass(self)
    }
    
    public var nameOfClass: String {
        return NSStringFromClass(type(of: self))
    }
    
    public class var nameOfClassWithoutModulename: String {
        return self.nameOfClass.components(separatedBy: ".").last!
    }
    
    public var nameOfClassWithoutModulename: String {
        return self.nameOfClass.components(separatedBy: ".").last!
    }
}
