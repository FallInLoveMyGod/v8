//
//  XYCUrlArgumentFilter.swift
//  CNYNetworking
//
//  Created by caonongyun on 16/7/14.
//  Copyright © 2016年 CNY. All rights reserved.
//

import UIKit

class XYCUrlArgumentFilter: NSObject {

    @objc var arguments:NSDictionary?
    public init(WithArguments _arguments:NSDictionary) {
        super.init()
        arguments = _arguments
    }
    
    @objc class func filterWithArguments(_ arguments:NSDictionary) ->XYCUrlArgumentFilter{
        let filter:XYCUrlArgumentFilter = XYCUrlArgumentFilter(WithArguments:arguments)
        return filter
    }
    
    @objc class func filterUrl(_ originUrl:String,withRequest request:XYCBaseRequest,arguments: NSMutableDictionary) ->String
    {
        return XYCNetworkPrivate.urlStringWithOriginUrlString(originUrl, appendParameters: arguments)
    }
}
