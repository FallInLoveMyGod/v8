//
//  QueryInspectionItemsAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/11.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class QueryInspectionItemsAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kQueryInspectionItems
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
