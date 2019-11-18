//
//  SearchFollowRecordAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/4.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SearchFollowRecordAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSearchFollowRecord
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
