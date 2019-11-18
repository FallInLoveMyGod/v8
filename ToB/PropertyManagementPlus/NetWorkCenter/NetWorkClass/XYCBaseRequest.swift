//
//  WWTCBaseRequest.swift
//  CNYNetworking
//
//  Created by caonongyun on 16/7/14.
//  Copyright © 2016年 CNY. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public enum XYCRequestMethod:Int{ 
    case get = 0
    case post
}

public typealias XYCRequestCompletionBlock = (_ response:AnyObject) ->Void

public class XYCBaseRequest: NSObject {
    
    @objc var baseUrl = ""

    @objc var successCompletionBlock:XYCRequestCompletionBlock?
    @objc var failureCompletionBlock:XYCRequestCompletionBlock?
    
    @objc var loadView: LoadView?
    @objc var loadParentView: UIView?
    
    @objc var parameters: NSMutableDictionary = NSMutableDictionary(capacity: 20)
    
    @objc func requestUrl() ->String {
        return ""
    }
    
    @objc func requestArgument() ->AnyObject?{
        return nil
    }
    
    func requestMethod() ->XYCRequestMethod?{
        return XYCRequestMethod.get;
    }
    
    @objc func startWithCompletionBlockWithSuccess(_ successCompletionBlock:@escaping XYCRequestCompletionBlock,failureCompletionBlock:@escaping XYCRequestCompletionBlock){
        self.successCompletionBlock = successCompletionBlock
        self.failureCompletionBlock = failureCompletionBlock
        start()
    }
    
    @objc func startWithCompletionBlockWithHUD(_ successCompletionBlock:@escaping XYCRequestCompletionBlock,failureCompletionBlock:@escaping XYCRequestCompletionBlock){
        startWithCompletionBlockWithSuccess(successCompletionBlock, failureCompletionBlock: failureCompletionBlock)
    }
    
    @objc func start(){
        XYCNetworkAgent.sharedInstance.addRequest(self)
    }
}

let RequestValidRespondKey = UnsafeRawPointer(bitPattern: 12131)
let resultMap = "resultMap"

extension XYCBaseRequest
{

    @objc func transactionWithSuccess(_ success: XYCRequestCompletionBlock? = nil,failure:XYCRequestCompletionBlock? = nil){
        
        if (BaseTool.isExistenceNetwork() == false) {
            LocalToastView.toast(text: NoNetWork)
            return
        }
        
        if (loadParentView != nil && loadView != nil) {
            MBProgressHUD.hide(for: loadParentView!, animated: true)
            loadView!.loading(currentView: loadParentView, labelText:LoadView.storeLabelText , mode: .indeterminate)
        }
        
        startWithCompletionBlockWithHUD({ (response) in
            
            let dict = response as? NSDictionary
            dict?.addAssociatedObject((response.object(forKey: "resultMap") as AnyObject))
            if success != nil && dict != nil {
                self.hideLoadingView()
                success!(dict!)
            }
            }) { (response) in
                if failure != nil{
                    self.hideLoadingView()
                    failure!(response)
                }
        }
    }
    
    @objc func hideLoadingView () {
        if (self.loadParentView != nil && self.loadView != nil) {
            self.loadView!.hide(currentView: self.loadParentView)
        }
    }
    
}

public extension NSDictionary
{
    func addAssociatedObject(_ object:AnyObject){
        objc_setAssociatedObject(self, RequestValidRespondKey!, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    //获取关联对象
    func resultMap() ->AnyObject{
        return objc_getAssociatedObject(self, RequestValidRespondKey!) as AnyObject
    }
}

