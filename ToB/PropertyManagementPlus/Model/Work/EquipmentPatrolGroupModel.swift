//
//  EquipmentPatrolGroupModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/8/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

/*
 out_trade_no	第三方标识码
 OrgPK	组织主键
 待议
 PollingPK	巡检点PK
 TypePK	设备种类Pk
 待议
 ProjectPK	巡检项目PK
 EquipmentPK	设备pk
 FinishTime	巡检时间	格式"yyy-MM-dd HH:mm:ss"
 Batchno	批次	不可为空
 待议
 Finishman	巡检人
 CheckResult	巡检状态	0-未完成， 1-已完成， 2-跳过
 Memo	备注
 Contents
 */

class EquipmentPatrolGroupModel: DBCommonModel {
    
    @objc var out_trade_no: String? = ""
    @objc var OrgPK: String? = ""
    @objc var PollingPK: String? = ""
    @objc var TypePK: String? = ""
    @objc var ProjectPK: String? = ""
    @objc var EquipmentPK: String? = ""
    @objc var FinishTime: String? = ""
    @objc var Batchno: String? = ""
    @objc var Finishman: String? = ""
    @objc var CheckResult: String? = "1"
    @objc var Memo: String? = ""
    @objc var isCommit: String = "0"
    
    @objc var jsonContent: String? = ""
    @objc var Contents: [Any] = [Any]()
}
