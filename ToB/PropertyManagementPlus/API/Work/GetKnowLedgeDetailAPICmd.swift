//
//  GetKnowLedgeDetailAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/7/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetKnowLedgeDetailAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetKnowLedgeDetail
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
