//
//  OnOrOutLineAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/16.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class OnOrOutLineAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return KOnOrOutLine
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
