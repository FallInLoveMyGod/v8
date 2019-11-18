//
//  XYCNetworkAgent.swift
//  CNYNetworking
//
//  Created by caonongyun on 16/7/14.
//  Copyright © 2016年 CNY. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

open class XYCNetworkAgent: NSObject {

    fileprivate var config:XYCNetworkConfig?
    
    func addRequest(_ request:XYCBaseRequest){
        DispatchQueue(label: "com.XYC.XYCnetwork.request.processing", attributes: []).async { 
            self.XYC_addRequst(request)
        }
    }
    
    func buildRequestUrl(_ request:XYCBaseRequest) ->String{
        var detailUrl:String = request.requestUrl()
        if detailUrl.hasPrefix("http") == true {
            return detailUrl;
        }
        if request.requestMethod() == .post {
            detailUrl = XYCUrlArgumentFilter.filterUrl(detailUrl, withRequest: request, arguments: [:])
        } else {
            detailUrl = XYCUrlArgumentFilter.filterUrl(detailUrl, withRequest: request, arguments: request.parameters)
        }
        
        let baseUrl = request.baseUrl
        print("\(baseUrl)\(detailUrl)")
        return "\(baseUrl)\(detailUrl)"
    }
    
    func XYC_addRequst(_ request:XYCBaseRequest){
        let url = self.buildRequestUrl(request)
        var param = request.requestArgument()
        let method:XYCRequestMethod = request.requestMethod()!
        if method == .post {
            
            param = request.requestArgument() == nil ? request.parameters : nil
            Alamofire.request(url, method: .post, parameters: param as? [String: Any])
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Validation Successful")
                        if request.successCompletionBlock != nil{
                            request.successCompletionBlock!(response.result.value! as AnyObject)
                        }
                    case .failure(let error):
                        print(error)
                        if request.failureCompletionBlock != nil{
                            request.failureCompletionBlock!(error as AnyObject)
                        }
                    }
            }
            
        }else{
            
            Alamofire.request(url, method: .get, parameters: param as? [String: Any])
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Validation Successful")
                        if request.successCompletionBlock != nil{
                            request.successCompletionBlock!(response.result.value as AnyObject)
                        }
                    case .failure(let error):
                        print(error)
                        if request.failureCompletionBlock != nil{
                            request.failureCompletionBlock!(error as AnyObject)
                        }
                    }
            }
        }
    }
    static let sharedInstance = XYCNetworkAgent()
    fileprivate override init() {
        config = XYCNetworkConfig.sharedInstance
    }
}
