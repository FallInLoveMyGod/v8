//
//  DeviceRepairListModel.h
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/29.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceRepairListModel : NSObject

@property (nonatomic,strong)NSString *beginDate;

@property (nonatomic,strong)NSString *code;

@property (nonatomic,strong)NSString *endDate;

@property (nonatomic,strong)NSString *expectedBeginDate;

@property (nonatomic,strong)NSString *expectedEndDate;

@property (nonatomic,strong)NSString *finishMan;

@property (nonatomic,strong)NSString *isFinish;

@property (nonatomic,strong)NSString *name;

@property (nonatomic,strong)NSString *planMemo;

@property (nonatomic,strong)NSString *taskLevel;

@property (nonatomic,strong)NSString *myId;





@end

NS_ASSUME_NONNULL_END
