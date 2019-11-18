//
//  GetMyAlarmListAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/22.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class GetMyAlarmListAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetMyAlarmList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
