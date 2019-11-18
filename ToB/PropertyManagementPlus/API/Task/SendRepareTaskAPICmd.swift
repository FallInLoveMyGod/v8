//
//  SendRepareTaskAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/1.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SendRepareTaskAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSendRepareTask
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
