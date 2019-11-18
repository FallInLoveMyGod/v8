//
//  GetPRoomOwnerInfo.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetPRoomOwnerInfo: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetPRoomOwnerInfo
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
