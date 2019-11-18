//
//  CheckUserAPI.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/15.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class CheckUserAPI: XYCBaseRequest {
    override func requestUrl() -> String {
        return KCheckUser
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
