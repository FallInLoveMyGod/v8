//
//  AddComplaintFormModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/31.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

@objc class AddComplaintFormModel: DBCommonModel {
    @objc var out_trade_no: String? = ""
    @objc var CreateDate: String? = ""
    @objc var Way: String? = ""
    @objc var ComplainantPsCode: String? = ""
    @objc var Complainant: String? = ""
    @objc var ComplainantTel: String? = ""
    @objc var ComplainantHouseNo: String? = ""
    @objc var ComplainantHouseName: String? = ""
    
    @objc var RespondentType: String? = ""
    @objc var Title: String? = ""
    @objc var Content: String? = ""
    @objc var DateLimit: String? = ""
    
    @objc var ComplainantType: String? = ""
    //@objc var YhItems: String? = ""
    @objc var YhItems: [String: String]? = [:]
    @objc var RespondentTel: String? = ""
    @objc var WayId: String? = ""
    @objc var ContactCode: String? = ""
    @objc var ComplainantTypeId: String? = ""
    
    @objc var uid: String? = ""
    @objc var uname: String? = ""
    @objc var IsCreateProj: String? = ""
    
    @objc var Location: String? = ""
    
    @objc var Category: String? = ""
    @objc var BillCode: String? = ""
}
