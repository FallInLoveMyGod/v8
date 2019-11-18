//
//  GetEquipmentListDetailAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/7/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetEquipmentListDetailAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetEquipmentListDetail
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
