//
//  KSetAlarmDownloadAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/3/15.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SetAlarmDownloadAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return KSetAlarmDownload
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
