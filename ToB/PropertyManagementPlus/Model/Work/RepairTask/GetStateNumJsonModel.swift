//
//  GetStateNumJsonModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "NoComplete" : 97,
 "WaitRepare" : 4,
 "Repareing" : 35,
 "NoSend" : 43,
 "Send" : 15,
 "Recall" : 1082,
 "NoRecall" : 1571,
 "result" : "success",
 "Complete" : 2653,
 "Back" : 0
 
 */

class GetStateNumJsonModel: CommonModel {
    @objc var NoComplete: String? = ""
    @objc var WaitRepare: String? = ""
    @objc var Repareing: String? = ""
    @objc var NoSend: String? = ""
    
    @objc var Send: String? = ""
    @objc var Recall: String? = ""
    
    @objc var NoRecall: String? = ""
    @objc var Complete: String? = ""
    @objc var Back: String? = ""
}
