//
//  DataSynchronizationManager.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

//TODO:
@objc public protocol DataSynchronizationManagerDelegate {
    //开始同步
    @objc optional func startSynchronization(synchronizationType: NSInteger)
    //同步结束
    @objc optional func endSynchronization(synchronizationType: NSInteger, itemNumber: NSString)
    //同步失败
    @objc optional func failSynchronization(synchronizationType: NSInteger)
    //选择数据项数据全部同步完成
    @objc optional func synchronizationOver()
}


//数据同步管理
class DataSynchronizationManager: NSObject {

    static open var delegate: DataSynchronizationManagerDelegate?
    
    static var loginInfo = LocalStoreData.getLoginInfo()
    static var userInfo = LocalStoreData.getUserInfo()
    static var chooseTypeName = ["客服_投诉_投诉类型",
                                      "客服_投诉_投诉方式",
                                      "客服_维修_回访客户评价",
                                      "客户事件类别",
                                      "重大事件_级别",
                                      "重大事件_类别",
                                      "招商管理_跟进方式",
                                      "招商管理_客户意向状态",
                                      "信息来源",
                                      "招商管理_联系人职务",
                                      "入仓类别",
                                      "出仓类别",
                                      "仓库信息"]
    //同步数据类型
    static open var synchronizationType = -1
    
    static open func synchronizationAllData() {
        
        loginInfo = LocalStoreData.getLoginInfo()
        userInfo = LocalStoreData.getUserInfo()
        
        dataSynchronization()
        houseStructureDataSynchronization()
        organizeDataSynchronization()
        outsourcingDataSynchronization()
        linksDataSynchronization()
        getContactsDataSynchronization()
        
    }
    
    static open func startSynItem(item: NSInteger, index: NSInteger) {
        
        if (item == -1) {
            //同步结束
            delegate?.synchronizationOver!()
            return
        }
        
        if (item == 0) {
            
            if (index == 1) {
                organizeDataSynchronization()
            }else if (index == 2) {
                houseStructureDataSynchronization()
            }else if (index == 3) {
                dataSynchronization()
            }else if (index == 4) {
                linksDataSynchronization()
            }else if (index == 5) {
                getContactsDataSynchronization()
            }else if (index == 6) {
                outsourcingDataSynchronization()
            }else {
                
            }
            
        }
        
    }
    
    //数据同步（数据字典）
    static open func dataSynchronization() {
        
        synchronizationType = 3
        
        startSyn()
        
        let typeArray: NSMutableArray = NSMutableArray(capacity: 20)
        
        for content in chooseTypeName {
            let contentDict = ["type":content]
            typeArray.add(contentDict)
        }
        
        let json = typeArray.yy_modelToJSONString()
        
        let getDictionaryInfosAPICmd = GetDictionaryInfosAPICmd()
        getDictionaryInfosAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":json ?? ""]
        getDictionaryInfosAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getDictionaryInfosAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                delegate?.endSynchronization!(synchronizationType: synchronizationType, itemNumber: String(dict["infos"].count) as NSString)
                
                GetDictionaryInfosModel.clearTable()
                
                for (_,tempDict) in dict["infos"] {
                    
                    if let getDictionaryInfosModel:GetDictionaryInfosModel = GetDictionaryInfosModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        getDictionaryInfosModel.save()
                    }
                    
                }
                
                //LocalToastView.toast(text: "同步成功")
                
            }else {
                self.failSyn()
                //LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
            self.failSyn()
        }
    }
    
    //房产结构
    static open func houseStructureDataSynchronization() {
        
        synchronizationType = 2
        
        startSyn()
        
        let getHouseStructureAPICmd = GetHouseStructureAPICmd()
        getHouseStructureAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getHouseStructureAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        getHouseStructureAPICmd.transactionWithSuccess({ (response) in
            let dict = JSON(response)

            let resultStatus = dict["result"].string

            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
//                let firstArr = NSMutableArray();
//                let secendArr = NSMutableArray();
//                let forthArr = NSMutableArray();
//                let fifthArr = NSMutableArray();
//                let thirdArr = NSMutableArray();
                
                var firstArr = [JSON]();
                var secendArr = [JSON]();
                var forthArr = [JSON]();
                var fifthArr = [JSON]();
                var thirdArr = [JSON]();
                var modelArr = [HouseModel]();
                for (_,tempDic) in dict["infos"] {
//                    let data = tempDic.rawData() throw
//                    let temp = try? JSONSerialization.jsonObject(with: tempDic, options: .mutableContainers)
                    if tempDic["Level"] == "1" {
//                        firstArr.add(tempDic);
                        firstArr.append(tempDic)
                    }

                    else if tempDic["Level"] == "2" {
//                        secendArr.add(tempDic);
                        secendArr.append(tempDic)
                    }
                    else if tempDic["Level"] == "4" {
//                        forthArr.add(tempDic);
                        forthArr.append(tempDic)
                    }
                    else if tempDic["Level"] == "3" {
//                        thirdArr.add(tempDic);
                        thirdArr.append(tempDic)
                    }
                    else {
//                        fifthArr.add(tempDic);
                        fifthArr.append(tempDic)
                    }
                }
                
                
                let totalArr = NSMutableArray();
                var start:CFAbsoluteTime?
                var end:CFAbsoluteTime?
                for tempFis in firstArr {
                    //start = CFAbsoluteTimeGetCurrent();
                    let fff = NSMutableDictionary();
                    fff.setValue(tempFis["HouseName"].rawString(), forKey: "Name")
                    fff.setValue(tempFis["HouseCode"].rawString(), forKey: "Code");
                    fff.setValue(tempFis["CompanyName"].rawString(), forKey: "CompanyName");
                    let PBuildings = NSMutableArray();
                    
                    fff.setValue(PBuildings, forKey: "PBuildings");
                    totalArr.add(fff);
                    var index2 = -1;
                    for tempSec in secendArr {
                        index2 += 1;
                        if tempSec["HouseSuperId"] != tempFis["HouseId"]
                        {continue;}
                        let sss = NSMutableDictionary();
                        sss.setValue(tempSec["HouseName"].rawString(), forKey: "Name");
                        sss.setValue(tempSec["HouseCode"].rawString(), forKey: "Code");
                        sss.setValue(tempSec["buildType"].rawString(), forKey: "buildType");
                        let PFloors = NSMutableArray();
                        let PRooms = NSMutableArray();
                        sss.setValue(PRooms, forKey: "PRooms")
                        sss.setValue(PFloors, forKey: "PFloors")
                        PBuildings.add(sss);
                        secendArr.remove(at: index2);
                        index2 -= 1;
                        
                        var index3 = -1;
                        for tempThird in thirdArr {
                            index3 += 1;
                            if (tempThird["HouseSuperId"]) != (tempSec["HouseId"])
                            {continue;}
                            thirdArr.remove(at: index3)
                            index3 -= 1;
                            
                            var index4 = -1
                            
                            for tempForth in forthArr {
                                index4 += 1;
                                if (tempForth["HouseSuperId"]) != (tempThird["HouseId"] )
                                {continue;}
                                let forfor = NSMutableDictionary();
                                forfor.setValue(tempForth["HouseName"].rawString(), forKey: "Name");
                                forfor.setValue(tempForth["HouseCode"].rawString(), forKey: "Code");
                                forfor.setValue(tempForth["LAT"].rawString(), forKey: "LAT");
                                forfor.setValue(tempForth["LNG"].rawString(), forKey: "LNG");
                                let string = tempForth["roomJson"];
                                print(string);
                                let pRooms = NSMutableArray();
                                forfor.setValue(pRooms, forKey: "PRooms")
                                PFloors.add(forfor);
                                forthArr.remove(at: index4)
                                index4 -= 1;
                                
                                if let obj = try? JSONSerialization.jsonObject(with: (tempForth["roomJson"].rawString()?.data(using: String.Encoding.utf8)!)! , options: JSONSerialization.ReadingOptions.allowFragments) {
                                    forfor.setValue(obj, forKey: "PRooms")
                                }
                                
                            }
                        }
                        var index4 = -1;
                        for tempForth in forthArr {
                            index4 += 1;
                            if (tempForth["HouseSuperId"]) != (tempSec["HouseId"] ) {
                            continue;
                            }
                            let forfor = NSMutableDictionary();
                            forfor.setValue(tempForth["HouseName"].rawString(), forKey: "Name");
                            forfor.setValue(tempForth["HouseCode"].rawString(), forKey: "Code");
                            forfor.setValue(tempForth["LAT"].rawString(), forKey: "LAT");
                            forfor.setValue(tempForth["LNG"].rawString(), forKey: "LNG");

                            PFloors.add(forfor);
                            forthArr.remove(at: index4);
                            index4 -= 1;
                            print(tempForth["roomJson"].rawString());
                            if let obj = try? JSONSerialization.jsonObject(with: (tempForth["roomJson"].rawString()?.data(using: String.Encoding.utf8)!)! , options: JSONSerialization.ReadingOptions.allowFragments) {
                                forfor.setValue(obj, forKey: "PRooms")
                            }
                            
                        }
                    }
                }

                let res = ["result":"success","PProjects":totalArr] as NSDictionary
                var resData:Data?
                do {
                    let data = res.yy_modelToJSONData();
                    let mm = res.yy_modelToJSONObject();
                    let resData0 = try JSONSerialization.data(withJSONObject: res, options: JSONSerialization.WritingOptions.prettyPrinted)
                    if let JSONString = String(data: data!, encoding: String.Encoding.utf8) {
                        resData = data;
                    }
                
                } catch {
                    
                }

                if !JSONSerialization.isValidJSONObject(res) {
                    print("cuowu")
                }
                delegate?.endSynchronization!(synchronizationType: synchronizationType, itemNumber: String(dict["infos"].count) as NSString)
                UserDefaults.standard.removeObject(forKey: HouseStructureDataSynchronization)
                UserDefaults.standard.set(resData, forKey: HouseStructureDataSynchronization)
                UserDefaults.standard.synchronize();
                
                HouseStructureModel.clearTable()
                for tempDic in totalArr {
                    let ttt = tempDic as! NSDictionary;
//                    let jsonData = try JSONSerialization.data(withJSONObject: ttt, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                    let tempDatas = ttt.yy_modelToJSONData();
                    if let houseModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON:tempDatas ?? {}) {
                        houseModel.save()
                    }
                }
            }else {
                self.failSyn()
                LocalToastView.toast(text: "获取房产架构信息失败！")
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
            self.failSyn()
        }
        
    }
    
    //组织结构
    
    static open func organizeDataSynchronization() {
        
        synchronizationType = 1

        startSyn()
        
        let getOrganizeDataAPICmd = GetOrganizeDataAPICmd()
        getOrganizeDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getOrganizeDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        getOrganizeDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                delegate?.endSynchronization!(synchronizationType: synchronizationType, itemNumber: String(dict["organizeInfo"].count) as NSString)
                
                OrganizeDataModel.clearTable()
                
                for (_,tempDict) in dict["organizeInfo"] {
                    
                    if let organizeDataModel:OrganizeDataModel = OrganizeDataModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        
                        organizeDataModel.save()
                    }
                    
                }
                
            }else {
                self.failSyn()
                //LocalToastView.toast(text: "获取组织架构信息失败！")
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
            self.failSyn()
        }
        
    }
    
    //外协单位
    static open func outsourcingDataSynchronization() {
        
        synchronizationType = 6
        
        startSyn()
        
        let getOutsourcingDataAPICmd = GetOutsourcingDataAPICmd()
        getOutsourcingDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Type":""]
        getOutsourcingDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getOutsourcingDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                delegate?.endSynchronization!(synchronizationType: synchronizationType, itemNumber: String(dict["outsourcingInfo"].count) as NSString)
                
                OutsourcingDataModel.clearTable()
                
                for (_,tempDict) in dict["outsourcingInfo"] {
                    
                    if let outsourcingDataModel:OutsourcingDataModel = OutsourcingDataModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        outsourcingDataModel.save()
                    }
                    
                }
                
            }else {
                self.failSyn()
                //LocalToastView.toast(text: "获取外协信息失败！")
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
            self.failSyn()
        }
        
    }
    
    //组织结构同事信息
    static open func linksDataSynchronization() {
        
        synchronizationType = 4
        
        startSyn()

        let getWorkerDataAPICmd = GetWorkerDataAPICmd()
        getWorkerDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getWorkerDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
        getWorkerDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                delegate?.endSynchronization!(synchronizationType: synchronizationType, itemNumber: String(dict["workerinfo"].count) as NSString)
                
                WorkerDataModel.clearTable()
                for (_,tempDict) in dict["workerinfo"] {
                    
                    if let workerDataModel:WorkerDataModel = WorkerDataModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                        workerDataModel.save()
                    }
                    
                }
                
            }else {
                self.failSyn()
                //LocalToastView.toast(text: "获取联系人信息失败！")
            }
            
        }) { (response) in
            //LocalToastView.toast(text: DisNetWork)
            self.failSyn()
        }
        
    }
    
    static open func getContactsDataSynchronization() {
        
        synchronizationType = 5
        
        startSyn()
        
        let getContactsDataAPICmd = GetContactsDataAPICmd()
        getContactsDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getContactsDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","pcode":"","bcode":"","fname":"","rcode":""]
        getContactsDataAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                delegate?.endSynchronization!(synchronizationType: synchronizationType, itemNumber: String(dict["contactsInfo"].count) as NSString)
                
//                GetContactsDataModel.clearTable()
//                for (_,tempDict) in dict["contactsInfo"] {
//                    
//                    if let getContactsDataModel:GetContactsDataModel = JSONDeserializer<GetContactsDataModel>.deserializeFrom(json: JSON(tempDict.object).rawString()) {
//                        self.colleagueLinkPersonsDataSource.add(getContactsDataModel)
//                    }
//                    
//                }
                
            }else {
                self.failSyn()
            }
            
        }) { (response) in
            self.failSyn()
        }
    }
    
    static open func startSyn() {
        delegate?.startSynchronization!(synchronizationType: synchronizationType)
    }
    
    static open func failSyn() {
        delegate?.failSynchronization!(synchronizationType: synchronizationType)
    }
    
}
