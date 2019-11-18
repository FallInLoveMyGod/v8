//
//  AddInspectionPlanAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/11.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddInspectionPlanAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kAddInspectionPlan
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
