//
//  GetIndicatorsAPICmd.swift
//  PropertyManagementPlus
//
//  Created by 上海乐软信息科技有限公司 on 2018/4/12.
//  Copyright © 2018年 Lesoft. All rights reserved.
//

import UIKit

class GetIndicatorsAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kHomeGetIndicatorsList
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
