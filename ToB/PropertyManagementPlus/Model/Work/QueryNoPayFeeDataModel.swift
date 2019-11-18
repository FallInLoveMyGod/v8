//
//  QueryNoPayFeeDataModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/8/26.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

/*
 "BeginTime" : "2017-08-26 00:00:00",
 "Feeid" : 81956,
 "Ramount" : 45,
 "FeeName" : "租金",
 "DateTimeYM" : 201708,
 "TenantName" : "上海统一星巴克咖啡有限公司",
 "EndTime" : "2017-09-26 00:00:00",
 "Code" : "01010101",
 "DataTime" : "2017年08月",
 "Price" : 45,
 "TenantCode" : "01010101_03",
 "Pamount" : 45
 */

class QueryNoPayFeeDataModel: DBCommonModel {
    
    @objc var BeginTime: String? = ""
    @objc var Feeid: String? = ""
    @objc var Ramount: String? = ""
    @objc var FeeName: String? = ""
    @objc var TenantName: String? = ""
    @objc var DateTimeYM: String? = ""
    @objc var EndTime: String? = ""
    @objc var Code: String? = "0"
    @objc var DataTime: String? = ""
    @objc var Price: String? = ""
    @objc var TenantCode: String? = ""
    @objc var Pamount: String? = ""
    
}
