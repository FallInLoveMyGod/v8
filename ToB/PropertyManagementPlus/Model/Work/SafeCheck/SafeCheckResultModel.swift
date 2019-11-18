//
//  SafeCheckResultModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/15.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafeCheckResultModel: DBCommonModel {
    
    @objc var Name: String? = ""
    @objc var out_trade_no: String? = GUIDGenarate.stringWithUUID()
    @objc var pRoomCode: String? = ""
    @objc var ProjectPK: String? = ""
    @objc var CheckTime: String? = ""
    @objc var CheckMan: String? = ""
    @objc var CheckResult: String? = ""
    @objc var FileMemo: String? = ""
    @objc var FileNames: String? = ""
    @objc var isCommit: String = "0"
    //文件存储路径-逗号分隔
    @objc var FilePaths: String? = ""
    
    @objc var jsonContent: String? = ""
    @objc var Contents: [Any] = [Any]()
}
