//
//  GetRepaireListAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class GetRepaireListAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetRepaireList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
