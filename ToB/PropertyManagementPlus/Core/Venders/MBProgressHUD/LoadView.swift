//
//  LoadView.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/14.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

open class LoadView: NSObject {
    
    @objc static var storeLabelText: String?
    
    @objc func loading(currentView: UIView?, labelText: String?, mode: MBProgressHUDMode) {
        let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: currentView!, animated: true)
        hud?.mode = mode
        hud?.label.text = labelText
    }
    
    @objc func hide(currentView: UIView?) {
        MBProgressHUD.hide(for: currentView!, animated: true)
    }
}
