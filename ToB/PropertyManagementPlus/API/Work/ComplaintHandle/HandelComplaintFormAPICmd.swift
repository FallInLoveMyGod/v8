//
//  HandelComplaintFormAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/29.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class HandelComplaintFormAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kHandelComplaintForm
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
