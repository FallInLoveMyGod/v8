//
//  AddUpdateYXKHInfoModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/5.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
/*
 CID	客户pk
 CName	客户名称
 CNamejc	客户简称
 TelNum	联系电话
 PhoneNum	手机号码
 LinkName	联系人姓名
 LinkPosition	联系人职务	来源4 下载数据词典 (招商管理_联系人职务)
 Email	电子邮件
 ZSPerson	招商人员	来源1.2 同事信息 中Role=“招商”的人员
 Source	信息来源	来源4 下载数据词典 (信息来源)
 FirstDate	初次到访日期
 DateType	初次到访方式	【来访、来电】
 GJState	跟进状态	【未跟进、已跟进、已认租、已签约、已退租】
 YXState	意向状态
 */

class AddUpdateYXKHInfoModel: DBCommonModel {
    @objc var CID: String? = ""
    @objc var CName: String? = ""
    @objc var CNamejc: String? = ""
    @objc var TelNum: String? = ""
    @objc var PhoneNum: String? = ""
    @objc var LinkName: String? = ""
    @objc var LinkPosition: String? = ""
    @objc var Email: String? = ""
    @objc var ZSPerson: String? = ""
    @objc var Source: String? = ""
    @objc var FirstDate: String? = ""
    @objc var DateType: String? = ""
    @objc var GJState: String? = ""
    @objc var YXState: String? = ""
}
