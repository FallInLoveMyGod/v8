//
//  GetContactsDataAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/26.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class GetContactsDataAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetContactsData
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
