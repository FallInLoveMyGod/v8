//
//  GetRepaireListModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "files" : [
 {
 "Url" : "E:\\workSource\\BSCODE\\LeSoft.WebService\\AppBillFile\\LinkBill\\000220167\\1468240511_39857420160718160833.png",
 "BussinessType" : "0"
 }
 ],
 
 "ReturnCallCustNoSatisCause" : null,
 "BillDate" : "2016-12-20T18:37:26.18",
 "ReparePerson" : "smsf,System",
 "CustomerCode" : "1010101_02",
 "StateCause" : null,
 "EndTime" : "0001-01-01T00:00:00",
 "PProjectCode" : "1",
 "SendWay" : "APP",
 "BillCodeIndex" : 96,
 "CreateTime" : "2016-12-20T18:37:26.133",
 "Source" : "联系单",
 "Range" : "客户区域",
 "RepareFee" : 0,
 "AcceptPerson" : "smsf,System",
 "OtherCost" : 0,
 "ReturnCallMemo" : null,
 "NoRepareCause" : null,
 "SourceID" : 52,
 "State" : 3,
 "IsOutsource" : false,
 "PUnitIndex" : 1,
 "IsAccept" : true,
 "RepareTime" : 0,
 "ReturnCallCheckPass" : false,
 "Type" : "无偿维修",
 "Proposer" : "辉哥火锅有限公司",
 "SubscribeWarmHours" : 0,
 "ReturnCallWay" : null,
 "BillID" : 0,
 "BillCode" : "WX20161200096",
 "BeginTime" : "0001-01-01T00:00:00",
 "SendPerson" : "System",
 "TransBillCause" : null,
 "WaitCause" : null,
 "Location" : "东方蓝海\/第01栋\/第01层\/101",
 "SubscribeTime" : "0001-01-01T00:00:00",
 "PrintTimes" : 0,
 "MaterialCost" : 0,
 "ReparePesonType" : false,
 "CustSign" : null,
 "AcceptTime" : "0001-01-01T00:00:00",
 "CustComments" : null,
 "TelNum" : "13512341234",
 "BillCodePre" : "WX201612",
 "ReturnCallCustEvel" : null,
 "RepareProfession" : null,
 "SubscribeHours" : 0,
 "RepareWay" : null,
 "LaborCost" : 0,
 "SendType" : 0,
 "CustomerName" : null,
 "RepareCompanyID" : 0,
 "CustSatisfaction" : null,
 "ReturnCallTime" : "0001-01-01T00:00:00",
 "ReviewTime" : "0001-01-01T00:00:00"
 */

class GetRepaireListModel: DBCommonModel {
    @objc var ID: String? = ""
    @objc var FeeID: String? = ""
    @objc var ReturnCallPerson: String? = ""
    
    @objc var NoCompleteCause: String? = ""
    @objc var CreatePerson: String? = ""
    @objc var ModifyTime: String? = ""
    
    @objc var IsReturnCall: String? = ""
    @objc var PlanTime: String? = ""
    @objc var RequestCompleteTime: String? = ""
    
    @objc var PRoomCode: String? = ""
    @objc var PBuildingCode: String? = ""
    @objc var PrintMemo: String? = ""
    @objc var ModifyPerson: String? = ""
    
    @objc var RepareWay: String? = ""
    @objc var RepareWayID: String? = ""
    @objc var SendTime: String? = ""
    @objc var IsReview: String? = ""
    
    @objc var PFloorName: String? = ""
    @objc var CompleteMemo: String? = ""
    @objc var RepareItemID: String? = ""
    
    @objc var ReviewPerson: String? = ""
    @objc var ReturnCallCustSuggest: String? = ""
    @objc var Content: String? = ""
    @objc var Memo: String? = ""
    @objc var Way: String? = ""
    
    @objc var Range: String? = ""
    @objc var Location: String? = ""
    @objc var CreateTime: String? = ""
    //预约维修时间
    @objc var SubscribeTime: String? = ""
    @objc var State: String? = ""
    @objc var `Type`: String? = ""
    @objc var TelNum: String? = ""
    @objc var BillCode: String? = ""
    @objc var Proposer: String? = ""
    @objc var BillDate: String? = ""
    
    @objc var SendPerson: String? = ""
    @objc var AcceptPerson: String? = ""
    
    
    @objc var AcceptTime: String? = ""
    @objc var ArriveTime: String? = ""
    @objc var EndTime: String? = ""
    @objc var BeginTime: String? = ""
    @objc var OtherCost: String? = ""
    @objc var MaterialCost: String? = ""
    @objc var LaborCost: String? = ""
    @objc var PProjectCode: String? = ""
    @objc var PUnitIndex: String? = ""
    
    @objc var RepareCategoryID: String? = ""
    @objc var sort: String? = ""
    
    @objc var ReturnCallTime: String? = ""
    @objc var ReturnCallMemo: String? = ""
    @objc var StateCause: String? = ""
    @objc var ReturnCallCustEvel: String? = ""
    @objc var ReturnCallCheckPass: String? = ""
    @objc var ReturnCallCustNoSatisCause: String? = ""
    
    //服务器图片:转换成Json String
    @objc var files: NSArray? = []
    
    @objc var IsAccept: String? = ""
    
    //本地区别类型
    @objc var Category: String? = ""
    @objc var SubCategory: String? = ""
    //是否已编辑
    @objc var IsEdit: String? = "0"
    //是否到达
    @objc var IsArrive: String? = ""
    //是否开始
    @objc var IsStart: String? = ""
    //是否暂停
    @objc var IsSuspend: String? = ""
    //是否完成
    @objc var IsOver: String? = ""
    //是否提交
    @objc var IsCommit: String? = ""
    
    //是否提交文本
    @objc var IsTextCommit: String? = "0"
    //是否提交材料
    @objc var IsMaterialCommit: String? = "0"
    
    //本地图片
    @objc var LocalImageO: String? = ""
    @objc var LocalImageT: String? = ""
    @objc var LocalImageS: String? = ""
    @objc var LocalImageF: String? = ""
    
    //签到图片
    @objc var LocalSignImage: String? = ""
    
    //录音文件
    @objc var RecordName: String? = ""
    
}
