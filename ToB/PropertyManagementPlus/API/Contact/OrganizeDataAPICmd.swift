//
//  GetOrganizeDataAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class GetOrganizeDataAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetOrganizeData
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
