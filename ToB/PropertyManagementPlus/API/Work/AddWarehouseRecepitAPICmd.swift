//
//  AddWarehouseRecepitAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/7.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddWarehouseRecepitAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddWarehouseRecepit
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
