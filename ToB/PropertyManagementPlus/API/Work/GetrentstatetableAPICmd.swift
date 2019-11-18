//
//  GetrentstatetableAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/8.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetrentstatetableAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetrentstatetable
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
