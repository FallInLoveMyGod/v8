//
//  TaskSettingAction.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

open class TaskSettingAction: NSObject {
    static open func getKind(kind: String) -> String {
        switch kind {
        case "1":
            return "维修给派单人"
        case "2":
            return "维修派单"
        case "3":
            return "维修抢单"
        case "4":
            return "维修回访"
        case "5":
            return "维修检验"
        default:
            return " "
        }
    }
    
    static open func getComplaintKind(kind: String) -> String {
        switch kind {
        case "1":
            return "投诉处理任务"
        case "2":
            return "投诉回访任务"
        default:
            return " "
        }
    }
}
