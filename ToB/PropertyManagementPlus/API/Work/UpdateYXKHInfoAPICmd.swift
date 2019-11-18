//
//  UpdateYXKHInfoAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/3.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class UpdateYXKHInfoAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kUpdateYXKHInfo
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
