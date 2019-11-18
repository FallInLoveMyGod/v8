//
//  RefreshViewTransTool.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class RefreshViewTransTool: NSObject {
    
    @objc public static let sharedInstance = RefreshViewTransTool()
    
    @objc public var actionTarget: ChatViewRoomController = ChatViewRoomController()
    
    @objc public var contentTableView: UITableView?
    
    @objc func addHeader (){
        
        let normalHeader = NormalAnimator.normalAnimator()
        normalHeader.lastRefreshTimeKey = "exampleHeader1"
        
        contentTableView?.zj_addRefreshHeader(normalHeader, refreshHandler: {[weak self] in
            self?.actionTarget.requestMassageList()
        })
    }
}
