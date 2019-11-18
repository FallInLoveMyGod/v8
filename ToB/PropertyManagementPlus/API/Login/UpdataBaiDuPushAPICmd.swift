//
//  UpdataBaiDuPushAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/8.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class UpdataJGPushAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kUpdataJGPush
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
