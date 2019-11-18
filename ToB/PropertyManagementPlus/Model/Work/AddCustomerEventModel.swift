//
//  AddCustomerEventModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/3.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class AddCustomerEventModel: DBCommonModel {
    @objc var PRoomCode: String? = ""
    @objc var TenantCode: String? = ""
    @objc var EvetnDate: String? = ""
    @objc var EvetnTypeId: String? = ""
    @objc var Content: String? = ""
    
    @objc var Address: String? = ""
    @objc var TenantName: String? = ""
}
