//
//  SynchroniseKnowLedgeAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/1.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SynchroniseKnowLedgeAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSynchroniseKnowLedge
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
