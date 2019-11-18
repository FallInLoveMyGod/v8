//
//  AddComplaintFormAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/31.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class AddComplaintFormAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddComplaintForm
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
