//
//  InfoSelectManagement.m
//  PropertyManagementPlus
//
//  Created by jana on 17/5/31.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "InfoSelectManagement.h"
#import "BaseTool.h"

@implementation InfoSelectManagement

+ (instancetype)shareInstance {
    static id _manager;
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        _manager = [[InfoSelectManagement alloc] init];
    });
    return _manager;
}

- (NSArray *)dealWithInfoSelectArray {
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:20];
    
    NSArray *datas = [[NSUserDefaults standardUserDefaults] objectForKey:@"GetEquipmentMenuKey"];
    
    for (NSDictionary *dictionary in datas) {
        if ([dictionary[@"superiorpk"] isEqualToString:@""]) {
            [dataSource addObject:dictionary];
        }
    }
    
    return dataSource;
    
}

- (NSArray *)dealWithInfoSelectID:(NSString *)infoSelectID {
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:20];
    
    NSArray *datas = [[NSUserDefaults standardUserDefaults] objectForKey:@"GetEquipmentMenuKey"];
    
    for (NSDictionary *dictionary in datas) {
        if ([dictionary[@"superiorpk"] isEqualToString:infoSelectID]) {
            [dataSource addObject:dictionary];
        }
    }
    
    return dataSource;
}

- (void)incrementalUpdateCategoryWithData:(id)data {
    
    NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithDictionary:[BaseTool dictionaryWithJsonString:[[NSUserDefaults standardUserDefaults] objectForKey:@"GetKnowleageMenuKey"]]];
    NSMutableArray *minfos = [NSMutableArray arrayWithArray:datas[@"minfos"]];
    NSMutableArray *pinfos = [NSMutableArray arrayWithArray:datas[@"pinfos"]];
    
    NSDictionary *tempData = (NSDictionary *)data;
    [minfos addObjectsFromArray:tempData[@"minfos"]];
    [pinfos addObjectsFromArray:tempData[@"pinfos"]];
    
    datas[@"minfos"] = minfos;
    datas[@"pinfos"] = pinfos;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[BaseTool toJson:datas] forKey:@"GetKnowleageMenuKey"];
    [defaults synchronize];
    
}

- (NSArray *)dealWithKnowleageInfoSelectArray {

    NSDictionary *datas = [BaseTool dictionaryWithJsonString:[[NSUserDefaults standardUserDefaults] objectForKey:@"GetKnowleageMenuKey"]];
    
    return datas[@"minfos"];
}
- (NSArray *)dealWithKnowleageInfoSelectID:(NSString *)infoSelectID {
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:20];
    
    NSDictionary *datas = [BaseTool dictionaryWithJsonString:[[NSUserDefaults standardUserDefaults] objectForKey:@"GetKnowleageMenuKey"]];
    
    for (NSDictionary *dictionary in datas[@"pinfos"]) {
        if ([[NSString stringWithFormat:@"%@",dictionary[@"mpk"]] isEqualToString:infoSelectID]) {
            [dataSource addObject:dictionary];
        }
    }
    
    return dataSource;
}

@end
