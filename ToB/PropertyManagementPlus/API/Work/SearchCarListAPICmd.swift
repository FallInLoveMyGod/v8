//
//  SearchCarListAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SearchCarListAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSearchCarList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
