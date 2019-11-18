//
//  QueryYXKHInfosAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/3.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class QueryYXKHInfosAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kQueryYXKHInfos
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
