//
//  AddWarehouseWarrantAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/7.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddWarehouseWarrantAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddWarehouseWarrant
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
