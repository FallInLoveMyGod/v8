//
//  CreateRepareBillModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/30.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

@objc class CreateRepareBillModel: DBCommonModel {
    @objc var Range: String? = ""
    @objc var PUnitIndex: String? = ""
    @objc var PFloorName: String? = ""
    @objc var PRoomCode: String? = ""
    @objc var Location: String? = ""
    @objc var Proposer: String? = ""
    @objc var TelNum: String? = ""
    
    @objc var Content: String? = ""
    @objc var CreateTime: String? = ""
    @objc var Way: String? = ""
    @objc var `Type`: String? = ""
    
    @objc var SubscribeTime: String? = ""
    @objc var PProjectCode: String? = ""
    @objc var PBuildingCode: String? = ""
}
