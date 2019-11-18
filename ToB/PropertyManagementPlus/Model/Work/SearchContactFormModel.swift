//
//  SearchContactFormModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "state" : "0",
 "style" : "来电",
 "contactDate" : "2016-12-20 17:46:00",
 "Id" : "48",
 "contactPhone" : "911",
 "contactName" : "张大",
 "UserName" : "上海鑫汇餐饮有限公司1",
 "type" : "报修",
 "source" : "",
 "code" : "KHLX00000046",
 "address" : "永新国际广场\/A座\/第02层\/201-10",
 "PsCode" : "01010201",
 "UserCode" : "01010201_01",
 "PProjectCode" : "",
 "filePath" : "AppBillFile\\LinkBill\\000220167\\1468240511_39857420160718160833.png",
 "content" : "马桶坏了"
 
 */

class SearchContactFormModel: CommonModel {
    @objc var state: String? = ""
    @objc var style: String? = ""
    @objc var contactDate: String? = ""
    @objc var Id: String? = ""
    @objc var contactPhone: String? = ""
    @objc var contactName: String? = ""
    @objc var UserName: String? = ""
    @objc var type: String? = ""
    @objc var source: String? = ""
    @objc var code: String? = ""
    @objc var address: String? = ""
    @objc var PsCode: String? = ""
    @objc var UserCode: String? = ""
    @objc var PProjectCode: String? = ""
    @objc var filePath: String? = ""
    @objc var content: String? = ""
    @objc var MSGNum: String? = ""
}
