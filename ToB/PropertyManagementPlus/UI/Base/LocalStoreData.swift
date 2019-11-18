//
//  LocalStoreData.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/15.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import HandyJSON

class LocalStoreData: NSObject {
    
    @objc static var userDefault: UserDefaults = UserDefaults.standard
    
    @objc static let ClientInfoKey = "ClientInfoKey"
    @objc static let UserInfoKey   = "UserInfoKey"
    @objc static let LoginInfoKey  = "LoginInfoKey"
    static let CustCode      = "CustCode"
    static let OnLine        = "OnLine"
    static let IsUse         = "IsUse"
    static let Applicense    = "Applicense"
    static let CompanyName   = "CompanyName"
    static let IsRepairOn    = "IsRepairOn"
    static let IsAudioReqireOn = "IsAudioReqireOn"
    
    static open func getPMSAddress() -> ClientInfoModel {
        
        if let clientInfoModel:ClientInfoModel = JSONDeserializer<ClientInfoModel>.deserializeFrom(json: userDefault.value(forKey: ClientInfoKey) as! String?) {
            clientInfoModel.PMSAddress = clientInfoModel.PMSAddress!
            return clientInfoModel
        }
        
        return ClientInfoModel();
    }
    
    static open func getUserInfo() -> UserInfoModel? {
        
        if let userInfoModel:UserInfoModel = JSONDeserializer<UserInfoModel>.deserializeFrom(json: userDefault.value(forKey: UserInfoKey) as! String?) {
            return userInfoModel
        }
        
        return nil
    }
    
    static open func getLoginInfo() -> LoginInfoModel? {
        
        if let loginInfoModel:LoginInfoModel = JSONDeserializer<LoginInfoModel>.deserializeFrom(json: userDefault.value(forKey: LoginInfoKey) as! String?) {
            return loginInfoModel
        }
        
        return nil
    }
    
    static open func getCustCode() -> NSString? {
        
        return userDefault.value(forKey: CustCode) as? NSString
    }
    
    static open func getIsUse() -> NSString? {
        
        return userDefault.value(forKey: IsUse) as? NSString
    }
    
    static open func getIsRepairOn() -> NSString? {
        
        return userDefault.value(forKey: IsRepairOn) as? NSString
    }
    
    static open func getIsAudioReqireOn() -> NSString? {
        
        return userDefault.value(forKey: IsAudioReqireOn) as? NSString
    }
    
    static open func getApplicense() -> NSString? {
        
        return userDefault.value(forKey: Applicense) as? NSString
    }
    
    static open func getCompanyName() -> NSString? {
        
        return userDefault.value(forKey: CompanyName) as? NSString
    }
    
    @objc static func getOnLine() -> Bool {
        
        if userDefault.value(forKey: OnLine) != nil {
            return "TRUE".localizedCaseInsensitiveContains(userDefault.value(forKey: OnLine) as! String)
        }
        
        return false
    }
    
    static open func clearLocalData() {
        userDefault.removeObject(forKey: LocalStoreData.UserInfoKey)
        userDefault.removeObject(forKey: LocalStoreData.OnLine)
    }
    
    static open func setUserDefaultsData(_ value: Any?, forKey key: String) {
        userDefault.removeObject(forKey: key)
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
    }
}
