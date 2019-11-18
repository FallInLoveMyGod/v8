//
//  GetComplaintByCodeModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/25.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import HandyJSON
import SwiftyJSON

class GetComplaintByCodeModel:CommonModel{
    @objc var ReturnTime: String? = ""
    @objc var ComplainantHouseName: String? = ""
    @objc var `Type`: String? = ""
    @objc var HandleProcess: String? = ""
    @objc var HandleTime: String? = ""
    @objc var ComplainantPsCode: String? = ""
    @objc var ComplainantTel: String? = ""
    @objc var RespondentTel: String? = ""
    @objc var Way: String? = ""
    @objc var HandleResult: String? = ""
    @objc var YhItems: String? = ""
    @objc var Title: String? = ""
    
    @objc var HandlePer: String? = ""
    @objc var Content: String? = ""
    @objc var ReturnVisit: String? = ""
    @objc var CreateDate: String? = ""
    @objc var out_trade_no: String? = ""
    @objc var IsCreateProj: String? = ""
    @objc var RespondentType: String? = ""
    @objc var WayId: String? = ""
    
    @objc var ComplainantHouseNo: String? = ""
    @objc var ComplainantTypeId: String? = ""
    @objc var filePath: String? = ""
    @objc var Complainant: String? = ""
    @objc var RespondentTypeId: String? = ""
    @objc var ComplainantPsAddress: String? = ""
    @objc var uname: String? = ""
    @objc var CustomerMemo: String? = ""
    
    @objc var DateLimit: String? = ""
    @objc var Code: String? = ""
    @objc var Nature: String? = ""
    @objc var uid: String? = ""
    @objc var ComplainantType: String? = ""
    
    @objc var ComplaintNature: String? = ""
    
    func initWithJson(json:JSON) {
        let tempJson:NSDictionary = json.object as! NSDictionary
        let mDict:NSMutableDictionary = tempJson.mutableCopy() as! NSMutableDictionary;
        for key in mDict.allKeys {
            if (mDict[key] == nil ) {
                mDict[key] = "";
            }
        }
        if !json["ReturnTime"].stringValue.isEmpty {
            ReturnTime = json["ReturnTime"].stringValue
        }
        if !json["ComplainantHouseName"].stringValue.isEmpty {
            ComplainantHouseName = json["ComplainantHouseName"].stringValue
        }
        if !json["`Type`"].stringValue.isEmpty {
            `Type` = json["`Type`"].stringValue
        }
        if !json["HandleProcess"].stringValue.isEmpty {
            HandleProcess = json["HandleProcess"].stringValue
        }
        if !json["HandleTime"].stringValue.isEmpty {
            HandleTime = json["HandleTime"].stringValue
        }
        if !json["ComplainantPsCode"].stringValue.isEmpty {
            ComplainantPsCode = json["ComplainantPsCode"].stringValue
        }
        if !json["ComplainantTel"].stringValue.isEmpty {
            ComplainantTel = json["ComplainantTel"].stringValue
        }
        
        if !json["RespondentTel"].stringValue.isEmpty {
            ComplainantTel = json["RespondentTel"].stringValue
        }
        
        if !json["Way"].stringValue.isEmpty {
            ComplainantTel = json["Way"].stringValue
        }
        
        if !json["HandleResult"].stringValue.isEmpty {
            ComplainantTel = json["HandleResult"].stringValue
        }
        
        if !json["YhItems"].stringValue.isEmpty {
            ComplainantTel = json["YhItems"].stringValue
        }
        
        if !json["Title"].stringValue.isEmpty {
            ComplainantTel = json["Title"].stringValue
        }
        
        if !json["HandlePer"].stringValue.isEmpty {
            ComplainantTel = json["HandlePer"].stringValue
        }
        
        if !json["Content"].stringValue.isEmpty {
            ComplainantTel = json["Content"].stringValue
        }
        
        if !json["ReturnVisit"].stringValue.isEmpty {
            ComplainantTel = json["ReturnVisit"].stringValue
        }
        
        // 45
        if !json["ComplainantTel"].stringValue.isEmpty {
            ComplainantTel = json["ComplainantTel"].stringValue
        }
        
        if !json["ComplainantTel"].stringValue.isEmpty {
            ComplainantTel = json["ComplainantTel"].stringValue
        }
    
        CreateDate = mDict["CreateDate"] as? String;
        out_trade_no = mDict["out_trade_no"] as? String;
        IsCreateProj = mDict["IsCreateProj"] as? String;
        RespondentType = mDict["RespondentType"] as? String;
        WayId = mDict["WayId"] as? String;
        ComplainantHouseNo = mDict["ComplainantHouseNo"] as? String;
        ComplainantTypeId = mDict["ComplainantTypeId"] as? String;
        filePath = mDict["filePath"] as? String;
        Complainant = mDict["Complainant"] as? String;
        RespondentTypeId = mDict["RespondentTypeId"] as? String;
        ComplainantPsAddress = mDict["ComplainantPsAddress"] as? String;
        uname = mDict["uname"] as? String;
        CustomerMemo = mDict["CustomerMemo"] as? String;
        DateLimit = mDict["DateLimit"] as? String;
        Code = mDict["Code"] as? String;
        Nature = mDict["Nature"] as? String;
        uid = mDict["uid"] as? String;
        ComplainantType = mDict["ComplainantType"] as? String;
        ComplaintNature = mDict["ComplaintNature"] as? String;
        
       
    }
    
}
