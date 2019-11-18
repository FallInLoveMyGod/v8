//
//  DeviceItemModel.m
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/30.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import "DeviceItemModel.h"

@implementation DeviceItemModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.myId = value;
    }
}


@end
