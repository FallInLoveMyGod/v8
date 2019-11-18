//
//  CityListAPI.swift
//  CNYNetworking
//
//  Created by caonongyun on 16/7/14.
//  Copyright © 2016年 CNY. All rights reserved.
//

import UIKit

class CityListAPI: XYCBaseRequest {

    override func requestUrl() -> String {
        return "CityListQry.do"
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
    
    override func requestArgument() -> AnyObject? {
        return ["ProvinceCode":"440000"] as AnyObject
    }
}
