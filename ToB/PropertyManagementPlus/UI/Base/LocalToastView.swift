//
//  LocalToastView.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/17.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import Toaster

open class LocalToastView: NSObject {
    @objc static func toast(text: String) {
        if text.compare("Object reference not set to an instance of an object") == .orderedSame {
            return
        }
        let toast = Toast(text: text)
        toast.duration = 1.5
        toast.show()
    }
    
    @objc static func hide() {
        ToastCenter.default.cancelAll()
    }
    
    @objc func toastOC(text: String) {
        if text.compare("Object reference not set to an instance of an object") == .orderedSame {
            return
        }
        let toast = Toast(text: text)
        toast.duration = 1.5
        toast.show()
    }
}
