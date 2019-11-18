//
//  GetEquipmentMenuAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetEquipmentMenuAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetEquipmentMenu
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
