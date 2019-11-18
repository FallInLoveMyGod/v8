//
//  GetTaskListModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "Type": 0,
 "Categories": 1,
 "Kind": 1,
 "Description": "报修单号：CJ0000000022\r\n报修地址：乐软大厦/第01栋/第01层/101\r\n报修人：小叶\r\n报修日期：2016/9/1 9:19:09\r\n报修电话：18312345678\r\n报修内容：单据中，联系电话右侧的图标，直接换成电话图标吧（绿的），别加文字了\r\n",
 "Sender": "System",
 "SendTime": "2016-09-28 03:31:39",
 "BillCode": "CJ0000000022"
 
 */

class GetTaskListModel: CommonModel {
    
    @objc var type: String? = ""
    @objc var Categories: String? = ""
    @objc var Kind: String? = ""
    @objc var Description: String? = ""
    @objc var Sender: String? = ""
    @objc var SendTime: String? = ""
    @objc var BillCode: String? = ""

}
