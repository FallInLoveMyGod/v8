//
//  SendComplaintTaskAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SendComplaintTaskAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSendComplaintTask
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
