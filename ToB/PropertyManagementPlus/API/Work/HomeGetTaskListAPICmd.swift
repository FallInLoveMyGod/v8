//
//  HomeGetTaskListAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class HomeGetTaskListAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kHomeGetTaskList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
