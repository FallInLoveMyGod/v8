//
//  CustomerNeedInfoModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/4.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
/*"CID":"54","Suggest":"增加照明","Hinder":"担心夜间客流","Favorable":"装修免租期延长至半个月","Description":"","Remarks":"","Requirement":"需要沿街开店铺，60-70平米"}*/
class CustomerNeedInfoModel: DBCommonModel {
    @objc var CID: String? = ""
    @objc var Suggest: String? = ""
    @objc var Hinder: String? = ""
    @objc var Favorable: String? = ""
    @objc var Description: String? = ""
    @objc var Remarks: String? = ""
    @objc var Requirement: String? = ""
}
