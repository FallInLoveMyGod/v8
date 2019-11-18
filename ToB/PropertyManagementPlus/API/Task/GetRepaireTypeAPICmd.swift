//
//  GetRepaireTypeAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetRepaireTypeAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetRepaireType
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
