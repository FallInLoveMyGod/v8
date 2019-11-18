//
//  UserInfoModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class UserInfoModel: CommonModel {
    
    @objc var name: String? = "" //真实姓名
    @objc var companyname: String? = ""
    @objc var upk: String? = ""
    @objc var state: String? = "" //0-正常，1-非移动用户，2-已停用
    @objc var remarks: String? = ""
    @objc var type: NSString? = "" //0-管理员，1-普通用户
}
