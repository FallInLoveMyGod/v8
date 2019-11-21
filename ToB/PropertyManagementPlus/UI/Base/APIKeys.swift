//
//  APIKeys.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/14.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import Foundation

public let KHost = "http://112.124.110.11:8089"
public let KClientInfoEventHost = "http://reg.mfzhaopu.com"

public let HouseStructureDataSynchronization = "HouseStructureDataSynchronization"
public let GetEquipmentMenuKey = "GetEquipmentMenuKey"
public let GetKnowleageMenuKey = "GetKnowleageMenuKey"
public let EnergyMeterReadingKey = "EnergyMeterReadingKey"
public let QuerySecuchkLinesKey = "QuerySecuchkLinesKey"
public let QueryInspectionItemsKey = "QueryInspectionItemsKey"

//接入认证
public let KClientInfoEvent = "/ClientInfoEvent.ashx"
//用户登录验证
public let KCheckUser = "/CheckUser.ashx"

//用户上线下线
public let KOnOrOutLine = "/OnOrOutLine.ashx"
//用户注销（登出）
public let KSignOut = "/SignOut.ashx"
//用户功能模块
public let KLoadAppRoles = "/LoadAppRoles.ashx"
//首页统计数-任务信息
public let KGetTaskInfos = "/RMService/getTaskInfos.ashx"

//获取任务列表
public let kGetTaskList = "/RMService/GetTaskList.ashx"
//首页获取tag任务列表
public let kHomeGetTaskList = "/GetTaskList.ashx"

//修改密码
public let kModiPassword = "/ModiPassword.ashx"

//组织机构
public let kGetOrganizeData = "/GetOrganizeData.ashx"
//同事信息
public let kGetWorkerData = "/GetWorkerData.ashx"
//查询外协单位
public let kGetOutsourcingData = "/GetOutsourcingData.ashx"
//房产结构
public let kGetHouseStructure = "/GetHouseStructureAP.ashx"
//public let kGetHouseStructure = "/GetHouseStructureHK.ashx"
//联系人（客户）信息
public let kGetContactsData = "/GetContactsData.ashx"
//消息
public let KGetMyMSGList = "/OAService/GetMyMSGList.ashx"
//设置下标状态
public let KSetMSGDownload = "/OAService/SetMSGDownload.ashx"
//设置预警SetAlarmDownload
public let KSetAlarmDownload = "/OAService/SetAlarmDownload.ashx"
//查询预警
public let kGetMyAlarmList = "/OAService/GetMyAlarmList.ashx"

//获取数据字典GetDictionaryInfos
public let kGetDictionaryInfos = "/SYSService/GetDictionaryInfos.ashx"

//查询维修任务
//public let kGetBillInfo = "/CSService/GetBillInfo.ashx"
public let kGetBillInfo = "/CSService/GetBillInfoByPage.ashx"
public let kGetBillInfoDetail = "/CSService/GetBillInfo.ashx"
//接受任务
public let kAcceptRepareTask = "/CSService/AcceptRepareTask.ashx"

// 获取首页指标 报表 接口
public let kHomeGetIndicatorsList = "/BusinessIndicators/GetIndicators.ashx"

// 设备保养
public let kDeviceRepairList = "/CSService/GetDevicesCareList.ashx"
public let kDeviceRepairDetail = "/CSService/GetDevicesCareDetail.ashx"
public let kDeviceRepairFinish = "/CSService/FinishDevicesCare.ashx"

//查询我的维修任务数量
public let kGetMyRepareTaskNum = "/CSService/GetMyRepareTaskNum.ashx"
//查询维修单数量
public let kGetStateNumJson = "/CSService/GetStateNumJson.ashx"
//查询维修单列表
public let kGetRepaireList = "/CSService/GetRepaireList.ashx"
//创建新的维修工单
public let kCreateRepareBill = "/CSService/CreateRepareBill.ashx"
//附件上传接口
public let kUploadFile = "/CSService/UploadFile.ashx"
//安全检查附件上传接口
public let kSafeCheckUploadFile = "/UploadFile.ashx"
//查询权限用户列表
public let kGetRightUserList = "/CSService/GetRightUserList.ashx"
//查询权限用户（查询可以抢单的人）
public let kGetRightUsers = "/CSService/GetRightUsers.ashx"
//创建任务
public let kSendRepareTask = "/CSService/SendRepareTask.ashx"
//下载维修类别
public let kGetRepaireType = "/CSService/GetRepaireType.ashx"
//完成维修任务
public let kUpdateRepareTask = "/CSService/UpdateRepareTask.ashx"


//查询已处理的统计
public let kGetContactFormInfo = "/CSService/GetContactFormInfo.ashx"
//查询客户联系单
public let kSearchContactForm = "/CSService/SearchContactForm.ashx"
//处理客户联系单
public let kHandelContactForm = "/CSService/HandelContactForm.ashx"

//查询投诉列表
public let kGetComplaintList = "/CSService/GetComplaintList.ashx"
//查询投诉详情
public let kGetComplaintByCode = "/CSService/GetComplaintByCode.ashx"
//投诉单回访
public let kReturnVisitComplaint = "/CSService/ReturnVisitComplaint.ashx"
//处理投诉单
public let kHandelComplaintForm = "/CSService/HandelComplaintForm.ashx"
//新增投诉单
public let kAddComplaintForm = "/CSService/AddComplaintForm.ashx"
//发送投诉任务
public let kSendComplaintTask = "/CSService/SendComplaintTask.ashx"

//百度云推送状态更新
public let kUpdataJGPush = "http://www.lesoftapp.cc:8089/webapi/UpdataJGPushUserInfo.ashx"

//查询联系单评价列表
public let kGetLinkBillMSGList = "/csservice/GetLinkBillMSGList.ashx"
//发表评论
public let kSendLinkBillMSG = "/csservice/SendLinkBillMSG.ashx"

//业户资料
public let kGetPRoomOwnerInfo = "/RMService/GetPRoomOwnerInfo.ashx"

//查询车辆列表
public let kSearchCarList = "/RMService/SearchCarList.ashx"

//查询车辆详细信息
public let kSearchCarInfo = "/RMService/SearchCarInfo.ashx"

//查询设备菜单
public let kGetEquipmentMenu = "/EMService/GetEquipmentMenu.ashx"

//查询设备列表
public let kGetEquipmentList = "/EMService/GetEquipmentList.ashx"

//同步知识库菜单
public let kSynchroniseKnowLedge = "/OAService/SynchroniseKnowLedge.ashx"

//显示经营指标
public let kKPIRecord = "/KPIRecord.ashx"

/*客户事件*/
//新增客户事件
public let kAddCustomerEvent = "/CSService/AddCustomerEvent.ashx"

/*突发事件*/
//查询重大事件接收人
public let kGetContactFormInfoGetReceiver = "/CSService/GetReceiver.ashx"
//新增重大事件
public let kAddMajorEvent = "/CSService/AddMajorEvent.ashx"
//查询重大事件
public let kSearchMajorEvent = "/CSService/SearchMajorEvent.ashx"
//上报重大事件
public let kReportedEvent = "/CSService/ReportedEvent.ashx"

/*意向客户*/
//查询统计数据
public let kQueryYXKHStatistics = "/OAService/QueryYXKHStatistics.ashx"
//查询意向客户
public let kQueryYXKHInfos = "/OAService/QueryYXKHInfos.ashx"
//查询客户详细资料
public let kQueryYXKHInfo = "/OAService/QueryYXKHInfo.ashx"
//新增或更新意向客户
public let kUpdateYXKHInfo = "/OAService/UpdateYXKHInfo.ashx"

/*出仓入仓*/
//获取物品清单
public let kGetWarehouseGoodsList = "/MATService/GetWarehouseGoodsList.ashx"
//新增入仓单
public let kAddWarehouseRecepit = "/MATService/AddWarehouseRecepit.ashx"
//新增出仓单
public let kAddWarehouseWarrant = "/MATService/AddWarehouseWarrant.ashx"

/*跟进记录*/
//查询跟进记录
public let kSearchFollowRecord = "/OAService/SearchFollowRecord.ashx"
//新增跟进记录
public let kAddFollowRecord = "/OAService/AddFollowRecord.ashx"
//更新跟进记录
public let kUpdateFollowRecord = "/OAService/UpdateFollowRecord.ashx"
//查询客户需求资料
public let kQueryVoiceInfo = "/OAService/QueryVoiceInfo.ashx"
//更新客户需求资料
public let kUpdateVoiceInfo = "/OAService/UpdateVoiceInfo.ashx"



/*能耗抄表*/
//下载抄表记录
public let kGetMeterInfo = "/EMService/GetMeterInfo.ashx"
//更新抄表
public let kUpdateMeterInfo = "/EMService/UpdateMeterInfo.ashx"

/*设备巡检*/
//下载巡检标准
public let kQueryInspectionItems = "/EMService/QueryInspectionItems.ashx"
//上传巡检结果
public let kAddInspectionPlan = "/EMService/AddInspectionPlan.ashx"

/*安全巡更*/
//下载安全巡更项目路线
public let kQuerySecuchkLines = "/CSService/QuerySecuchkLines.ashx"
//上传安全巡更结果
public let kAddSecuchkRecord = "/CSService/AddSecuchkRecord.ashx"

public let kGetrentstatesummary = "/OPService/getrentstatesummary.ashx"
public let kGetrentstatetable = "/OPService/getrentstatetable.ashx"
public let kGetunitinfo = "/OPService/getunitinfo.ashx"

public let kGetEquipmentListDetail = "/EMService/GetEquipmentInfo.ashx"
public let kGetKnowLedgeDetail = "/OAService/GetKnowLedgeDetail.ashx"

//查询未缴费列表
public let kQueryNoPayFeeData = "/FMService/QueryNoPayFeeData.ashx"

//安全检查
//接口-下载安全巡检内容
public let kGetSafeCheckItem = "/EMService/GetSafeCheckItem.ashx"
//接口-上传安全巡检结果
public let kAddSafeCheckResult = "/EMService/AddSafeCheckResult.ashx"
//房产同步
public let kSafeCheckGetHouseStructure = "/GetHouseStructure.ashx"
