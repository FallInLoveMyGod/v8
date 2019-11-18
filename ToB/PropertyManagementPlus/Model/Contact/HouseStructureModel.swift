//
//  HouseStructureModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

@objc class HouseStructureModel: DBCommonModel {
    
    @objc var PProjects: NSArray? = []
    @objc var CompanyName: String? = ""
    @objc var Name: String? = ""
    @objc var Code: String? = ""
    @objc var PBuildings: NSArray? = []
//    @objc var buildType: String? = ""
    
    @objc var PFloors: NSArray? = []
    
    @objc var PFloorName: String? = ""
    @objc var PUnitCode: String? = ""
    @objc var PRooms: NSArray? = []
    
    @objc var TenantName: String? = ""
    @objc var PUnitIndex: String? = ""
    @objc var OwnerCode: String? = ""
    @objc var TenantCode: String? = ""
    
}
