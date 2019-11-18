//
//  SafeCheckBuildHouseModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import ObjectMapper

class SafeCheckBuildHouseModel: Mappable {
    var Code = ""
    var Name = ""
    var PFloors: [SafeCheckFloorHouseModel] = []
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        PFloors  <- map["PFloors"]
        Code        <- map["Name"]
        Name        <- map["Name"]
    }
}
