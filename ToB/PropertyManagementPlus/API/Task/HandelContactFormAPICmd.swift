//
//  HandelContactFormAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/25.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class HandelContactFormAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kHandelContactForm
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}