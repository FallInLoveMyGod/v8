//
//  SafeCheckUpdateStandardAPICmd.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafeCheckUpdateStandardAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetSafeCheckItem
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
