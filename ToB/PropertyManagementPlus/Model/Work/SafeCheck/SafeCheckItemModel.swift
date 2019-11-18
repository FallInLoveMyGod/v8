//
//  SafeCheckItemModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

/*
 "ProjectPK": "1",
 "TaskPK": "1",
 "Content": "保洁",
 "CheckMeans": "",
 "Need": "hhh",
 "Type": "1",
 "TypeDescription": "1|合格|1|1|0;2|不合格|0|0|0;",
 "OrgPK": null,
 "IsRequired": "1"
 */

class SafeCheckItemModel: DBCommonModel {
    @objc var ProjectPK = ""
    @objc var TaskPK = ""
    @objc var Content = ""
    @objc var CheckMeans = ""
    @objc var Need = ""
    @objc var `Type` = ""
    @objc var TypeDescription = ""
    @objc var OrgPK = ""
    @objc var IsRequired = ""
}
