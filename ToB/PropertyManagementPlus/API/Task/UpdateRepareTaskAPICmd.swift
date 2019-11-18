//
//  UpdateRepareTaskAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/7.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class UpdateRepareTaskAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kUpdateRepareTask
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
