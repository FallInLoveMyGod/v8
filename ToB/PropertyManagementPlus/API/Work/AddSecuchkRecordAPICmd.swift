//
//  AddSecuchkRecordAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddSecuchkRecordAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddSecuchkRecord
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
