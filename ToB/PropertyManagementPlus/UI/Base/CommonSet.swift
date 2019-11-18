//
//  CommonSet.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import Foundation

public let kScreenWidth:CGFloat    = UIScreen.main.bounds.size.width
public let kScreenHeight:CGFloat   = UIScreen.main.bounds.size.height
public let kThemeColor             = UIColor(red: 0.0/255.0, green: 160.0/255.0, blue: 234.0/255.0, alpha: 1.0)
public let kMarkColor             = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
public let kNavbarHeight:CGFloat   = 64
public let TheUserDefaults         = UserDefaults.standard
public let kDeviceVersion          = Float(UIDevice.current.systemVersion)
public let kTabBarHeight:CGFloat   = 49

public let kWorkBarHeight:CGFloat   = 50

public let  KLoadingViewWidth: CGFloat = 70
public let  KShapeLayerWidth: CGFloat = 40
public let  KShapeLayerRadius: CGFloat = KShapeLayerWidth / 2
public let  KShapelayerLineWidth: CGFloat = 2.5
public let  KAnimationDurationTime: TimeInterval = 1.5
public let  KShapeLayerMargin: CGFloat = (KLoadingViewWidth - KShapeLayerWidth) / 2

public let  kLabelHeight: CGFloat =  25
public let  kImageViewHeight: CGFloat =  100
public let  x_OffSet: CGFloat =  20

public let kVertifyTextFieldTag = 7777
public let kSegmentViewTag = 7531
public let kNetDisConnectViewTag = 7731

public let kNotificationCenterChangeState:NSString   = "kNotificationCenterChangeState"
public let kPresentMyViewController:NSString   = "kPresentMyViewController"
public let kNotificationCenterHomeChangeState = "kNotificationCenterHomeChangeState"
public let kNotificationCenterFreshComplaintList: NSString = "kNotificationCenterFreshComplaintList"
public let kNotificationCenterFreshTurnComplaintList: NSString = "kNotificationCenterFreshTurnComplaintList"
public let kNotificationCenterFreshRepairTaskDetailList: NSString = "kNotificationCenterFreshRepairTaskDetailList"
public let kNotificationCenterFreshLinkItemList: NSString = "kNotificationCenterFreshLinkItemList"
public let kNotificationCenterFreshMyPage: NSString = "kNotificationCenterFreshMyPage"
public let kNotificationCenterFreshMessageNumber: NSString = "kNotificationCenterFreshMessageNumber"

public let kEmptyTimeKey = "0001-01-01T00:00:00"

public let DisNetWork = "服务器异常，请联系管理员!"
public let NoNetWork = "网络连接失败，请稍后重试！"

//public let DisNetWork = ""
//public let NoNetWork = ""


public let bigSize: Int = 16
public let middleSize: Int = 14
public let smallSize: Int = 12
