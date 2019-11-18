//
//  GetrentstatesummaryAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/8.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetrentstatesummaryAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetrentstatesummary
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
