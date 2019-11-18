//
//  DetailDeviceVC.h
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/29.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailDeviceVC : UIViewController

@property (nonatomic,strong)NSString *baseUrl;

@property (nonatomic,strong)NSString *upk;

@property (nonatomic,strong)NSString *accountCode;

@property (nonatomic,assign)BOOL isFinish;

@property (nonatomic,strong)NSString *code;

@property (nonatomic,strong)NSString *planMemo;

@property (nonatomic,strong)NSString *myId;

@end

NS_ASSUME_NONNULL_END
