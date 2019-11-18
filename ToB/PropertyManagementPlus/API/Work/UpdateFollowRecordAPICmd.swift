//
//  UpdateFollowRecordAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/4.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class UpdateFollowRecordAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kUpdateFollowRecord
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
