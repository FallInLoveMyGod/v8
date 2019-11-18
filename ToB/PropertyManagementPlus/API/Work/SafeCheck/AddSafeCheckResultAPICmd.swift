//
//  AddSafeCheckResultAPICmd.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddSafeCheckResultAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddSafeCheckResult
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
