//
//  SafePatrolModel.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/8/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafePatrolModel: DBCommonModel {
    @objc var out_trade_no: String? = GUIDGenarate.stringWithUUID()
    @objc var SecuchkProjectName: String? = ""
    @objc var SecuchkProjectPK: String? = ""
    @objc var SecuchkProjectCode: String? = ""
    @objc var StartTime: String? = ""
    @objc var EndTime: String? = ""
    @objc var CurrentState: String? = ""
    @objc var isScan: String? = "0"
    
    @objc var LineName: String? = ""
    @objc var LinePK: String? = ""
    @objc var LineCode: String? = ""
    @objc var ItemId: String? = ""
    @objc var LineCheckState: String? = ""
    @objc var Description: String? = ""
    @objc var LinePoints: String? = ""
    
    @objc func set(_ projectDict: NSDictionary, _ itemDict: NSDictionary , _ linePoints: NSArray) -> SafePatrolModel {
        self.SecuchkProjectPK = projectDict["SecuchkProjectPK"] as? String
        self.SecuchkProjectName = projectDict["SecuchkProjectName"] as? String
        self.SecuchkProjectCode = projectDict["SecuchkProjectCode"] as? String
        self.LineCheckState = projectDict["LineCheckState"] as? String
        self.Description = projectDict["Description"] as? String
        self.StartTime = projectDict["StartTime"] as? String
        self.EndTime = projectDict["EndTime"] as? String
        self.isScan = projectDict["isScan"] as? String
        self.CurrentState = projectDict["CurrentState"] as? String
        self.LineName = itemDict["LineName"] as? String
        self.LinePK = itemDict["LinePK"] as? String
        self.LineCode = itemDict["LineCode"] as? String
        
        var tempLinePoints = NSMutableArray()
        if self.LinePoints != "" {
            tempLinePoints = NSMutableArray(array: BaseTool.dictionary(withJsonString: self.LinePoints) as! NSArray)
        }
        
        
        for dict in linePoints {
            let tempDict = dict as! NSDictionary
            
            var isExist = false
            var index = 0
            for sub in tempLinePoints {
                let subDict = sub as! NSDictionary
                
                //同一笔数据
                let subPk = subDict["LinePointPK"] as! String
                let tempPK = tempDict["LinePointPK"] as! String
                if subPk == tempPK {
                    isExist = true
                    tempLinePoints.replaceObject(at: index, with: dict)
                    break
                }
                index = index + 1
            }
            
            if !isExist {
                tempLinePoints.add(dict)
            }
        }
        self.LinePoints = BaseTool.toJson(tempLinePoints)
        return self
    }
}
