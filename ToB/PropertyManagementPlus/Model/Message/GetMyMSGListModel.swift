//
//  GetMyMSGListModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/22.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "IsCheck" : false,
 "SendTime" : "2016-12-21T16:11:42",
 "Tittle" : "永新国际广场\/A座\/第01层\/101",
 "Type" : "维修",
 "Content" : "维修单号：WX20161200032   报修地址：永新国际广场\/A座\/第01层\/101   维修内容：222222222222222",
 "ID" : 68,
 "SendPerson" : "System"
 
 */

class GetMyMSGListModel: CommonModel {
    @objc var IsCheck: String? = ""
    @objc var SendTime: String? = ""
    @objc var Tittle: String? = ""
    @objc var `Type`: String? = ""
    @objc var Content: String? = ""
    @objc var ID: String? = ""
    @objc var SendPerson: String? = ""
}
