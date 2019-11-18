//
//  VertifyCodeAPI.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/14.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class VertifyCodeAPI: XYCBaseRequest {
    
//    var custCode: String?
    
    override func requestUrl() -> String {
        return KClientInfoEvent
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
    
//    override func requestArgument() -> AnyObject? {
//        return ["custCode":self.custCode!] as AnyObject
//    }
}
