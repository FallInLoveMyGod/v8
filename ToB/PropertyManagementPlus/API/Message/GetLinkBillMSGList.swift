//
//  GetLinkBillMSGList.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetLinkBillMSGList: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetLinkBillMSGList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
