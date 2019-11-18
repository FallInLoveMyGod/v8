//
//  UpdateMeterInfoAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class UpdateMeterInfoAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kUpdateMeterInfo
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
