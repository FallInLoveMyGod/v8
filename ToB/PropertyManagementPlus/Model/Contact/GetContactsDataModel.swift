//
//  GetContactsDataModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/26.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "Type" : "业主",
 "Name" : "上海统一星巴克咖啡有限公司",
 "MobileNum" : "15121115586",
 "Code" : "01010101_03",
 "TelNum" : ""
 
 */

class GetContactsDataModel: CommonModel {
    @objc var `Type`: String? = ""
    @objc var Name: String? = ""
    @objc var MobileNum: String? = ""
    @objc var Code: String? = ""
    @objc var TelNum: String? = ""
    @objc var Id: String? = ""
}
