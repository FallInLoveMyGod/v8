//
//  EnergyMeterReadingModel.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
/*
 Amount = 0;
 CurDegree = 700;
 CustomerBrandName = "";
 CustomerCode = "01010101_03";
 CustomerName = "\U4e0a\U6d77\U7edf\U4e00\U661f\U5df4\U514b\U5496\U5561\U6709\U9650\U516c\U53f8";
 CustomerShortName = "\U4e0a\U6d77\U7edf\U4e00\U661f\U5df4\U514b\U5496\U5561\U6709\U9650\U516c\U53f8";
 ID = 139711;
 IDCode = "";
 InputPerson = "\U80e1\U9f9a\U73fa";
 InputTime = "2016-06-23T19:20:42";
 IsOffLease = 0;
 Location = "";
 Memo = "";
 MeterCapacity = "";
 MeterCode = "";
 MeterKind = "\U6c34\U8868";
 MeterName = "\U6c34\U8868";
 MultiPower = 1;
 PBuildingCode = 0101;
 PBuildingName = "A\U5ea7";
 PFloorName = "\U7b2c01\U5c42";
 PProjectCode = 01;
 PProjectName = "\U6c38\U65b0\U56fd\U9645\U5e7f\U573a";
 PRoomCode = 01010101;
 PRoomName = 101;
 PUnitIndex = 1;
 PeriodYM = "";
 Periodname = "<\U5f53\U524d\U6284\U8868\U671f\U95f4>";
 PreDegree = 500;
 PreID = 164642;
 Price = 0;
 Quantity = 200;
 QuantityAdjust = 0;
 QuantityBase = 0;
 QuantityMax = 0;
 QuantityMin = 0;
 Range = 999999;
 Type = 0;
 isStop = 0;
 */
class EnergyMeterReadingModel: DBCommonModel {
    @objc var Amount: String? = ""
    @objc var CurDegree: String? = ""
    @objc var CustomerBrandName: String? = ""
    @objc var CustomerCode: String? = ""
    @objc var CustomerName: String? = ""
    @objc var CustomerShortName: String? = ""
    @objc var ID: String? = ""
    @objc var IDCode: String? = ""
    @objc var InputPerson: String? = ""
    @objc var InputTime: String? = ""
    @objc var IsOffLease: String? = ""
    @objc var Location: String? = ""
    @objc var Memo: String? = ""
    @objc var MeterCapacity: String? = ""
    @objc var MeterCode: String? = ""
    @objc var MeterKind: String? = ""
    @objc var MeterName: String? = ""
    @objc var MultiPower: String? = ""
    @objc var PProjectCode: String? = ""
    @objc var PBuildingCode: String? = ""
    @objc var PProjectName: String? = ""
    @objc var PBuildingName: String? = ""
    @objc var PFloorName: String? = ""
    @objc var PRoomCode: String? = ""
    @objc var PRoomName: String? = ""
    @objc var PUnitIndex: String? = ""
    @objc var PeriodYM: String? = ""
    @objc var Periodname: String? = ""
    @objc var PreDegree: String? = ""
    @objc var PreID: String? = ""
    @objc var Price: String? = ""
    @objc var Quantity: String? = ""
    @objc var QuantityAdjust: String? = ""
    @objc var QuantityBase: String? = ""
    @objc var QuantityMax: String? = ""
    @objc var QuantityMin: String? = ""
    @objc var Range: String? = ""
    @objc var `Type`: String? = ""
    @objc var isStop: String? = ""
    @objc var isTake: String? = "0"
    @objc var isModify: String? = "0"
}
