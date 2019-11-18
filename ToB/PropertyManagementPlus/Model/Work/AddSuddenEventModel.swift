//
//  AddSuddenEventModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/3.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddSuddenEventModel: DBCommonModel {
    @objc var code: String? = ""
    @objc var out_trade_no: String? = ""
    @objc var EventLevelName: String? = ""
    @objc var EventTypeName: String? = ""
    @objc var EventDate: String? = ""
    @objc var SpecificTime: String? = ""
    
    @objc var organizepk: String? = ""
    @objc var RelatedPersonnel: String? = ""
    @objc var Address: String? = ""
    @objc var EvetSummary: String? = ""
    @objc var Casualties: String? = ""
    @objc var PropertyLoss: String? = ""
    
    //临时存储，不参与服务器字段
    @objc var eventOrganizename: String? = ""
    //提交状态 0:未提交 1:未上报
    @objc var commitStatus: String? = "0"
}
