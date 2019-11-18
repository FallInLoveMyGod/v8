//
//  GetStateNumJsonAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/23.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class GetStateNumJsonAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetStateNumJson
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
