//
//  SetMSGDownloadAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/3/15.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SetMSGDownloadAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return KSetMSGDownload
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
