//
//  DeviceRepairListModel.m
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/29.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import "DeviceRepairListModel.h"

@implementation DeviceRepairListModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.myId = value;
    }
}

@end
