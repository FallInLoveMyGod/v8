//
//  SafeCheckUploadFileAPICmd.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/18.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafeCheckUploadFileAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSafeCheckUploadFile
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
