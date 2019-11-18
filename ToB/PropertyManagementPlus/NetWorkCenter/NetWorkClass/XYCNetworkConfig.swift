//
//  XYCNetworkConfig.swift
//  CNYNetworking
//
//  Created by caonongyun on 16/7/14.
//  Copyright © 2016年 CNY. All rights reserved.
//

import UIKit

@objc public protocol XYCUrlFilterProtocol {
    @objc func filterUrl(_ originUrl:String,withRequest request: XYCBaseRequest,arguments: NSMutableDictionary) ->String
}

class XYCNetworkConfig: NSObject {
    
    @objc var baseUrl:String? = KHost
    @objc var cdnUrl:String?
    @objc var urlFilters:NSMutableArray?
    //open var useParametersOnly: Bool = false
    
    fileprivate var cacheDirPathFilters = NSMutableArray()
    
    @objc func clearFilters() {
        urlFilters = NSMutableArray()
    }
    
    func addfilter(_ filter:XYCUrlFilterProtocol){
        clearFilters()
        urlFilters!.add(filter as AnyObject)
    }
    
    @objc static let sharedInstance = XYCNetworkConfig()
    fileprivate override init() {
        urlFilters = NSMutableArray()
    }

}
