//
//  SafeCheckHouseRoomModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import ObjectMapper
/*
 "TenantName" : "上海新路达商业（集团）有限公司",
 "Name" : "107号",
 "PUnitIndex" : 1,
 "OwnerCode" : "",
 "Code" : "120202",
 "TenantCode" : "120202_01"
 */
class SafeCheckHouseRoomModel: Mappable {
    var TenantName = ""
    var Name = ""
    var PUnitIndex = ""
    var OwnerCode = ""
    var Code = ""
    var TenantCode = ""
    var LNG = ""
    var LAT = ""
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        TenantName  <- map["TenantName"]
        Name        <- map["Name"]
        PUnitIndex  <- map["PUnitIndex"]
        OwnerCode   <- map["OwnerCode"]
        Code        <- map["Code"]
        TenantCode  <- map["TenantCode"]
        LAT         <- map["LAT"]
        LNG         <- map["LNG"]
    }
    
}
