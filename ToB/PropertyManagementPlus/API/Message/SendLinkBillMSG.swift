//
//  SendLinkBillMSG.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SendLinkBillMSG: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSendLinkBillMSG
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
