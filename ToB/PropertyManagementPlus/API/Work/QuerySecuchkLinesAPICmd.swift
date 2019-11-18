//
//  QuerySecuchkLinesAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/7.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class QuerySecuchkLinesAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kQuerySecuchkLines
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
