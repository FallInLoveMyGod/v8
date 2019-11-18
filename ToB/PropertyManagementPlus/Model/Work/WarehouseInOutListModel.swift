//
//  WarehouseInOutListModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class WarehouseInOutListModel: DBCommonModel {
    @objc var WarehouseID: String? = ""
    @objc var WarehouseWarrantType: String? = ""
    @objc var InDate: String? = ""
    @objc var IsWarehouseRecepit: String? = "1"
    
    //json
    @objc var ListItems: String? = ""
}
