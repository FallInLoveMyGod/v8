//
//  GetMyRepareTaskNumModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

/*
 
 "NoReCall" : 1,
 "NoSend" : 1,
 "NoCheck" : 0,
 "result" : "success",
 "NoComplete" : 1
 
 */

class GetMyRepareTaskNumModel: CommonModel {
    @objc var NoReCall: String? = ""
    @objc var NoSend: String? = ""
    @objc var NoCheck: String? = ""
    @objc var NoComplete: String? = ""
    @objc var ReCall: String? = ""
    @objc var NoSendToReCall: String? = ""
    @objc var NoAccept: String? = ""
    @objc var NoHandel: String? = ""
    @objc var Check: String? = ""
    @objc var Complete: String? = ""
    @objc var Send: String? = ""
}
