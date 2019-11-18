//
//  SearchContactFormAPICmd.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/23.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class SearchContactFormAPICmd: XYCBaseRequest {
    override func requestUrl() -> String {
        return kSearchContactForm
    }
    
    override func requestMethod() -> XYCRequestMethod? {
        return XYCRequestMethod.post
    }
}
