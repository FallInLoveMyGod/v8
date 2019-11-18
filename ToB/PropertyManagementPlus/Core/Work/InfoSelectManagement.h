//
//  InfoSelectManagement.h
//  PropertyManagementPlus
//
//  Created by jana on 17/5/31.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoSelectManagement : NSObject
+ (instancetype)shareInstance;

- (NSArray *)dealWithInfoSelectArray;
- (NSArray *)dealWithInfoSelectID:(NSString *)infoSelectID;

//增量更新
- (void)incrementalUpdateCategoryWithData:(id)data;
- (NSArray *)dealWithKnowleageInfoSelectArray;
- (NSArray *)dealWithKnowleageInfoSelectID:(NSString *)infoSelectID;
@end
