//
//  GetOutsourcingDataAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class GetOutsourcingDataAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetOutsourcingData
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
