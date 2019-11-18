//
//  GetMeterInfoAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetMeterInfoAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetMeterInfo
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
