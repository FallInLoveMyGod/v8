//
//  AddFollowRecordAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/4.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddFollowRecordAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddFollowRecord
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
