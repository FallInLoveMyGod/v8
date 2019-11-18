//
//  GetDeviceRepairCmd.swift
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/29.
//  Copyright © 2019 Lesoft. All rights reserved.
//

import UIKit
//XYCBaseRequest
class GetDeviceRepairCmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kDeviceRepairList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}

