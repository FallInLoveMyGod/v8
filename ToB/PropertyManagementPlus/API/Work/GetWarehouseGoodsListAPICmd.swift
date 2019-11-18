//
//  GetWarehouseGoodsListAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class GetWarehouseGoodsListAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kGetWarehouseGoodsList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
