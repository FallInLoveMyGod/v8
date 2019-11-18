//
//  SelectContentModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/3.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SelectContentModel: NSObject {
    @objc var eventCustomerContent: String? = ""
    @objc var eventSuddenCategory: String? = ""
    @objc var eventSuddenLevel: String? = ""
    @objc var eventOrganizename: String? = ""
    
    //跟进记录
    @objc var customerComeInWay: String? = ""
    @objc var customerComeInWant: String? = ""
    
    //客户意向
    //到访方式
    @objc var customerIntentDateType: String? = ""
    //跟进状态
    @objc var customerIntentGJState: String? = ""
    //客户意向
    @objc var customerIntentYXState: String? = ""
    //联系人职务
    @objc var customerIntentLinkPosition: String? = ""
    //信息来源
    @objc var customerIntentSource: String? = ""
    
    //出仓入仓
    @objc var warehouseChooseInfo: String? = ""
    //入仓出仓类型
    @objc var warehouseType: String? = ""
}
