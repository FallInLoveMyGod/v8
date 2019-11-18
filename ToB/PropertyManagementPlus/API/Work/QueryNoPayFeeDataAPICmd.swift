//
//  QueryNoPayFeeDataAPICmd.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/8/26.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class QueryNoPayFeeDataAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kQueryNoPayFeeData
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
