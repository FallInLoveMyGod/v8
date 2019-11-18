//
//  ComplaintHandleModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "IsCreateProj" : null,
 "Code" : "01-0000000003",
 "Title" : "房屋质量意见表",
 "Way" : "上海统一星巴克咖啡有限公司",
 "filePath" : null,
 "Complainant" : "王先生",
 "uname" : "啊啊啊",
 "Nature" : null,
 "ComplainantType" : "房屋质量意见表",
 "HandlePer" : null,
 "Type" : "1",
 "Content" : "隔壁装修太嘈杂",
 "ComplainantPsAddress" : null,
 "ComplainantHouseName" : null,
 "HandleTime" : null,
 "HandleProcess" : null,
 "HandleResult" : null,
 "ReturnTime" : null,
 "ReturnVisit" : null,
 "CustomerMemo" : null
 
 */

@objc class ComplaintHandleModel: DBCommonModel {
    @objc var IsCreateProj: String? = ""
    @objc var Code: String? = ""
    @objc var Title: String? = ""
    @objc var Way: String? = ""
    @objc var filePath: String? = ""
    @objc var Complainant: String? = ""
    @objc var uname: String? = ""
    @objc var Nature: String? = ""
    @objc var ComplainantType: String? = ""
    @objc var HandlePer: String? = ""
    @objc var `Type`: String? = ""
    @objc var Content: String? = ""
    @objc var ComplainantDate: String? = ""
    
    @objc var ComplainantPsAddress: String? = ""
    @objc var ComplainantHouseName: String? = ""
    @objc var HandleTime: String? = ""
    @objc var HandleProcess: String? = ""
    @objc var HandleResult: String? = ""
    @objc var ReturnTime: String? = ""
    @objc var ReturnVisit: String? = ""
    @objc var CustomerMemo: String? = ""
}
