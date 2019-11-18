//
//  kModiPassword.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class ModiPasswordAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kModiPassword
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
