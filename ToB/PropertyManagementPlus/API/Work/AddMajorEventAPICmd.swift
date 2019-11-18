//
//  AddMajorEventAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/3.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddMajorEventAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddMajorEvent
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
