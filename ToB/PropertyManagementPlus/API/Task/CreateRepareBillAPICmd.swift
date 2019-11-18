//
//  CreateRepareBillAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/30.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class CreateRepareBillAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kCreateRepareBill
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
