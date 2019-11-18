//
//  SafeCheckGetHouseStructure.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/13.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafeCheckGetHouseStructure: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSafeCheckGetHouseStructure
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
