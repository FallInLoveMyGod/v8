//
//  DBCommonModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/28.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import HandyJSON

open class DBCommonModel: JKDBModel {
    required public override init() {}
    
    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
