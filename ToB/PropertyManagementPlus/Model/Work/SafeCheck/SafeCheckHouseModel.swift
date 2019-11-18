//
//  SafeCheckHouseModel
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import ObjectMapper

class SafeCheckHouseModel: Mappable {
    var Code = ""
    var Name = ""
    var CompanyName = ""
    var PBuildings: [SafeCheckBuildHouseModel] = []
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        PBuildings  <- map["PBuildings"]
        CompanyName <- map["CompanyName"]
        Code        <- map["Name"]
        Name        <- map["Name"]
    }
}
