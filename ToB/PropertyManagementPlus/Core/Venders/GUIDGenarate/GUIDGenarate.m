//
//  GUIDGenarate.m
//  PropertyManagementPlus
//
//  Created by jana on 17/1/1.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "GUIDGenarate.h"

@implementation GUIDGenarate
+ (NSString*) stringWithUUID {
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString    *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}
@end
