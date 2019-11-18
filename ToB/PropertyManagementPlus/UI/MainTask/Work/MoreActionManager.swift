//
//  MoreActionManager.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class MoreActionManager: NSObject {

}

extension BaseViewController {
    func clickItemExtentsion(_ title: String!) {
        switch title {
        case "khlx":
            self.pushChild(viewController: LinkListViewController())
        case "wxrw":
            self.pushChild(viewController: RepairTaskViewController())
        case "tscl":
            self.pushChild(viewController: ComplaintHandlingViewController())
        case "tfsj":
            let eventList = EventListViewController()
            eventList.eventType = .eventSudden
            self.pushChild(viewController: eventList)
        case "yhzl":
            let customerInfoVC = CustomerInfoViewController()
            customerInfoVC.isTopLevelShow = true
            customerInfoVC.customerInfoType = .customerMaterial
            self.pushChild(viewController: customerInfoVC)
        case "sbzl":
            let infoSelectVC = InfoSelectViewController()
            infoSelectVC.infoSelectType = .equipmentMaterial
            self.pushChild(viewController: infoSelectVC)
        case "zsk":
            let infoSelectVC = InfoSelectViewController()
            infoSelectVC.infoSelectType = .knowleage
            self.pushChild(viewController: infoSelectVC)
        case "zkb":
            let rentControlVC = RentControlTableViewController()
            self.pushChild(viewController: rentControlVC)
        case "khsj":
            let eventList = EventListViewController()
            eventList.eventType = .eventCustomer
            self.pushChild(viewController: eventList)
        case "yxkh":
            self.pushChild(viewController: CustomerIntentViewController())
        case "nhcb":
            self.pushChild(viewController: EnergyMeterReadingListViewController())
        case "jyzb":
            let vc = ManagementIndexEquipmentPatrolViewController()
            vc.managementIndexEquipmentPatrolType = .managementIndex
            self.pushChild(viewController: vc)
        case "sbxj":
            let vc = ManagementIndexEquipmentPatrolViewController()
            vc.managementIndexEquipmentPatrolType = .equipmentPatrol
            self.pushChild(viewController: vc)
        case "ckcc":
            let eventList = EventListViewController()
            eventList.eventType = .warehouseOut
            self.pushChild(viewController: eventList)
        case "ckrc":
            let eventList = EventListViewController()
            eventList.eventType = .warehouseIn
            self.pushChild(viewController: eventList)
        case "aqxg":
            let vc = ManagementIndexEquipmentPatrolViewController()
            vc.managementIndexEquipmentPatrolType = .safePatrol
            self.pushChild(viewController: vc)
        case "smsf":
            let charge = ChargeViewController()
            self.push(viewController: charge)
        case "aqjc":
            print("安全检查")
            let safeCheck = SafeCheckViewController()
            self.push(viewController: safeCheck)
        case "clzl":
            let info = InfoMaterialViewController()
            info.infoMaterialType = .car
            self.push(viewController: info)
        case "sbby":
            let sbvc = DeviceRepairVC()
            sbvc.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!;
            sbvc.accountCode = LocalStoreData.getLoginInfo()?.accountCode ?? ""
            sbvc.upk = LocalStoreData.getUserInfo()?.upk ?? ""
            sbvc.type = "5";
            self.pushNormalViewController(viewController: sbvc)
               break;
        default:
            LocalToastView.toast(text: "该业务尚未开放,尽情期待！")
            break
        }
    }
}
