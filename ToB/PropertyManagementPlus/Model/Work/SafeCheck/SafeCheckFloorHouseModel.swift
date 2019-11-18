//
//  SafeCheckFloorHouseModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import ObjectMapper

/*
 "PFloorName" : "龙华西路",
 "Name" : "龙华西路",
 "PUnitCode" : "1",
 "PRooms" : [
 {
 "TenantName" : "上海淮海商贸有限公司",
 "Name" : "105号",
 "PUnitIndex" : 1,
 "OwnerCode" : "",
 "Code" : "120201",
 "TenantCode" : "120201_01"
 },
 {
 "TenantName" : "上海新路达商业（集团）有限公司",
 "Name" : "107号",
 "PUnitIndex" : 1,
 "OwnerCode" : "",
 "Code" : "120202",
 "TenantCode" : "120202_01"
 }
 ],
 "LNG" : "121.45300000",
 "LAT" : "31.17997000"
 */
class SafeCheckFloorHouseModel: Mappable {
    
    var PFloorName = ""
    var PUnitCode = ""
    var Name = ""
    var LNG = ""
    var LAT = ""
    var PRooms: [SafeCheckHouseRoomModel] = []
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        PFloorName  <- map["PFloorName"]
        PUnitCode   <- map["PUnitCode"]
        Name        <- map["Name"]
        LAT         <- map["LAT"]
        LNG         <- map["LNG"]
        PRooms      <- map["PRooms"]
    }
}
