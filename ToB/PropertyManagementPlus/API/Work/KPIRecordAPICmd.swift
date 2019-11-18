//
//  KPIRecordAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class KPIRecordAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kKPIRecord
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
