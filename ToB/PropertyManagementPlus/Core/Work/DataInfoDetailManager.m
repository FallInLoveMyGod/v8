//
//  DataInfoDetailManager.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/1.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "DataInfoDetailManager.h"

@implementation DataInfoDetailManager

+ (instancetype)shareInstance {
    static id _manager;
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        _manager = [[DataInfoDetailManager alloc] init];
    });
    return _manager;
}

- (NSArray *)dealCarInfoWithDatas:(id)datas {
    NSDictionary *info = datas[@"infos"];
    NSArray *noHouseArray = [NSArray arrayWithObjects:info[@"Name"],info[@"TelNum"],info[@"CompanyName"],info[@"CompanyCode"], nil];
    if ([info[@"OwerType"] isEqualToString:@"房间业户"]) {
        noHouseArray = [NSArray arrayWithObjects:info[@"Name"],info[@"TelNum"],info[@"CompanyName"],info[@"CompanyCode"],info[@"RelatedHouse"], nil];
    }
    NSArray *result = [NSArray arrayWithObjects:
                       [NSArray arrayWithObjects:info[@"Type"],info[@"CardCode"],info[@"Brand"],info[@"Height"],info[@"Color"],info[@"Memo"], nil],
                       noHouseArray,
                       [NSArray arrayWithObjects:info[@"Parkinglot"],info[@"StateDate"],info[@"EndDate"],info[@"PaidDate"], nil],nil];
    return result;
}

- (NSArray *)dealRentControlInfoWithDatas:(id)datas {
    
    NSDictionary *info = datas[@"info"];
    
    NSString *strucArea = [NSString stringWithFormat:@"%@=%@",info[@"strucArea"],info[@"feeArea"]];
    NSString *pRoomType = [NSString stringWithFormat:@"%@=%@",info[@"pRoomType"],info[@"pRoomState"]];
    NSString *empData = [NSString stringWithFormat:@"%@=%@",info[@"empType"],info[@"empLawPerson"]];
    
    NSString *billCode = [NSString stringWithFormat:@"%@",info[@"billCode"]];
    
    NSArray *result = [NSArray arrayWithObjects:
                       [NSArray arrayWithObjects:billCode,strucArea,pRoomType, nil],
                       [NSArray arrayWithObjects:
                        info[@"tenantName"],
                        empData,
                        info[@"linkMan"],
                        info[@"linkPhone"],
                        info[@"noPayAmount"], nil],
                       [NSArray arrayWithObjects:
                        info[@"billCode"],
                        info[@"billDate"],
                        info[@"rentStartDate"],
                        info[@"rentEndDate"],
                        info[@"payDate"],
                        info[@"rentUse"],
                        info[@"brandName"],
                        info[@"billMemo"],nil],
                       nil];
    return result;
    
}

//客户意向
- (NSMutableArray *)customerUpdateYXKHInfoValuesWithData:(id)data {
    
    AddUpdateYXKHInfoModel *model = (AddUpdateYXKHInfoModel *)data;
    
    NSMutableArray *secondArray = [NSMutableArray arrayWithArray:@[
                                                                   model.ZSPerson,
                                                                   model.FirstDate,
                                                                   model.DateType,
                                                                   model.GJState]];
    if ([model.GJState isEqualToString:@"已跟进"]) {
        [secondArray addObject:model.YXState];
    }else {
        [secondArray addObject:@""];
    }
    
    return [NSMutableArray arrayWithObjects:@[model.CName,
                                       model.CNamejc,
                                       model.PhoneNum,
                                       model.TelNum,
                                       model.Email,
                                       model.LinkName,
                                       model.LinkPosition,
                                       model.Source],secondArray, nil];
}

- (NSMutableArray *)energyMeterReadingValuesWithData:(id)data {
    
    
    return [NSMutableArray array];
}

- (NSArray *)dealEquipmentWithEquipmentMaterialModel:(id)model datas:(id)datas {
    InfoEquipmentMaterialModel *equipModel = (InfoEquipmentMaterialModel *)model;
    
    if (!datas) {
        return [NSArray arrayWithObjects:@[equipModel.equipmentname,@"",@"",@"",@"1",@"",@"",@"",@"",@""],@[@"",@"",@"",@"",@"",@"",@""],@[@"",@"",@"",@"",@"",@"",@"",@"",@""], nil];
    }else {
        
        NSDictionary *result = (NSDictionary *)datas[@"info"];
        return [NSArray arrayWithObjects:@[
                                           [BaseTool toStr:result[@"equipmentname"]],
                                           [BaseTool toStr:result[@"equipmenttypepk"]],
                                           [BaseTool toStr:result[@"level"]],
                                           [BaseTool toStr:result[@"brand"]],
                                           [BaseTool toStr:result[@"num"]],
                                           [BaseTool toStr:result[@"useDate"]],
                                           [BaseTool toStr:result[@"serviceYear"]],
                                           [BaseTool toStr:result[@"usedYear"]],
                                           [BaseTool toStr:result[@"equipmentlocation"]],
                                           [BaseTool toStr:result[@"equipmentmemo"]]
                                           ],@[
                                               [BaseTool toStr:result[@"maintenComp"]],
                                               [BaseTool toStr:result[@"outNo"]],
                                               [BaseTool toStr:result[@"outDate"]],
                                               [BaseTool toStr:result[@"handoverDate"]],
                                               [BaseTool toStr:result[@"supplier"]],
                                               [BaseTool toStr:result[@"maintenanceStartDate"]],
                                               [BaseTool toStr:result[@"maintenanceEndDate"]]
                                               ],@[
                                                   [BaseTool toStr:result[@"assetType"]],
                                                   [BaseTool toStr:result[@"assetNo"]],
                                                   [BaseTool toStr:result[@"buyDate"]],
                                                   [BaseTool toStr:result[@"originalValue"]],
                                                   [BaseTool toStr:result[@"depreciationRate"]],
                                                   [BaseTool toStr:result[@"depreciationMonth"]],
                                                   [BaseTool toStr:result[@"depreciationYear"]],
                                                   [BaseTool toStr:result[@"totalDepreciation"]],
                                                   [BaseTool toStr:result[@"residualvalue"]]], nil];
    }
    
}

- (NSArray *)dealEnergyMeterReadingWithModel:(id)model {
    EnergyMeterReadingModel *energyMeterModel = (EnergyMeterReadingModel *)model;
    
    NSString *quantity = [NSString stringWithFormat:@"%@",energyMeterModel.Quantity];
    if ([quantity intValue] == -1) {
        quantity = @"999998";
    }
    return [NSArray arrayWithObjects:@[energyMeterModel.MeterName,
                                       energyMeterModel.IDCode,
                                       [NSString stringWithFormat:@"%@/%@/%@/%@",energyMeterModel.PProjectName,energyMeterModel.PBuildingName,energyMeterModel.PFloorName,energyMeterModel.PRoomName],
                                       energyMeterModel.MeterKind,
                                       energyMeterModel.MultiPower,
                                       energyMeterModel.Range,
                                       energyMeterModel.PreDegree,
                                       energyMeterModel.InputTime,
                                       ],@[energyMeterModel.CurDegree,
                                           energyMeterModel.QuantityAdjust,
                                           quantity,
                                           energyMeterModel.Memo],nil];
}

- (NSMutableDictionary *)dealWareHouseGoodDictionary:(NSMutableDictionary *)wareHouseGoodDictionary {
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:wareHouseGoodDictionary];
    if (tempDict[@"Price"] && tempDict[@"Num"]) {
        CGFloat total = [tempDict[@"Price"] floatValue] * [tempDict[@"Num"] floatValue];
        tempDict[@"Amount"] = [NSString stringWithFormat:@"%.2f",total];
    }
    
    return tempDict;
}

//选择巡检项目
- (NSString *)safePatrolWithData:(id)data {
    //SecuchkProjectName(SecuchkProjectFrequency)[Starttime-Endtime]
    NSDictionary *info = (NSDictionary *)data;
    NSString *safePatrol = [NSString stringWithFormat:@"%@(%@)[%@-%@]",
                            info[@"SecuchkProjectName"],
                            info[@"SecuchkProjectFrequency"],
                            info[@"Starttime"],
                            info[@"Endtime"]];
    return safePatrol;
}

//安全巡更
- (void)dealSafePatrolDataWithSecuchkProjectPK:(NSString *)secuchkProjectPK linePK:(NSString *)linePK linePointPK:(NSString *)linePointPK insert:(NSDictionary *)insertDict {
    
    NSMutableArray *dealSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"QuerySecuchkLinesKey"]];
    
    for (int i = 0; i < dealSource.count; i ++) {
        
        NSMutableDictionary *lineSource = [NSMutableDictionary dictionaryWithDictionary:dealSource[i]];
        if ([lineSource[@"SecuchkProjectPK"] isEqualToString:secuchkProjectPK]) {
            
            NSMutableArray *lineArray = [NSMutableArray arrayWithArray:lineSource[@"Lines"]];
            
            for (int j = 0; j < lineArray.count; j ++) {
                
                NSMutableDictionary *pointSource = [NSMutableDictionary dictionaryWithDictionary:lineArray[j]];
                
                if ([pointSource[@"LinePK"] isEqualToString:linePK]) {
                    
                    NSMutableArray *pointArray = [NSMutableArray arrayWithArray:pointSource[@"LinePoints"]];
                    
                    for (int k = 0; k < pointArray.count; k ++) {
                        
                        NSMutableDictionary *replaceSource = [NSMutableDictionary dictionaryWithDictionary:pointArray[k]];
                        
                        if ([replaceSource[@"LinePointPK"] isEqualToString:linePointPK]) {
                            
                            //插入数据
                            for (NSString *key in insertDict.allKeys) {
                                [replaceSource setValue:insertDict[key] forKey:key];
                            }
                            
                        }
                        
                        pointArray[k] = replaceSource;
                    }
                    
                    pointSource[@"LinePoints"] = pointArray;
                }
                
                lineArray[j] = pointSource;
                
            }
            
            lineSource[@"Lines"] = lineArray;
            
        }
        
        dealSource[i] = lineSource;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:dealSource forKey:@"QuerySecuchkLinesKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//安全巡更保存
- (void)storeSafePatrolData:(id)data {
    NSMutableArray *dealSource = [NSMutableArray arrayWithArray:data];
    for (int i = 0; i < dealSource.count; i ++) {
        
        NSMutableDictionary *dealDict = [NSMutableDictionary dictionaryWithDictionary:dealSource[i]];
        
        if ([dealDict[@"Startdate"] isEqualToString:@""]) {
            dealDict[@"Startdate"] = @"01-01";
        }
        
        if ([dealDict[@"Enddate"] isEqualToString:@""]) {
            dealDict[@"Enddate"] = @"12-31";
        }
        
        if ([dealDict[@"Starttime"] isEqualToString:@""]) {
            dealDict[@"Starttime"] = @"00:00";
        }
        
        if ([dealDict[@"Endtime"] isEqualToString:@""]) {
            dealDict[@"Endtime"] = @"23:59";
        }
        
        [dealSource replaceObjectAtIndex:i withObject:dealDict];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:dealSource forKey:@"QuerySecuchkLinesKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)fetchSafePatrolData {
    
    NSMutableArray *dealSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"QuerySecuchkLinesKey"]];
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:20];
    
    for (int i = 0; i < dealSource.count; i ++) {
        
        NSMutableDictionary *lineSource = [NSMutableDictionary dictionaryWithDictionary:dealSource[i]];
        
        NSMutableArray *lineArray = [NSMutableArray arrayWithArray:lineSource[@"Lines"]];
        
        for (int j = 0; j < lineArray.count; j ++) {
            
            NSMutableDictionary *pointSource = [NSMutableDictionary dictionaryWithDictionary:lineArray[j]];
            
            NSMutableArray *pointArray = [NSMutableArray arrayWithArray:pointSource[@"LinePoints"]];
            
            for (int k = 0; k < pointArray.count; k ++) {
                
                NSMutableDictionary *replaceSource = [NSMutableDictionary dictionaryWithDictionary:pointArray[k]];
                if (replaceSource[@"CheckState"] && ![replaceSource[@"CheckState"] isEqualToString:@"1"]) {
                    
                    replaceSource[@"SecuchkProjectName"] = lineSource[@"SecuchkProjectName"];
                    replaceSource[@"SecuchkProjectPK"] = lineSource[@"SecuchkProjectPK"];
                    replaceSource[@"SecuchkProjectCode"] = lineSource[@"SecuchkProjectCode"];
                    replaceSource[@"SecuchkProjectFrequency"] = lineSource[@"SecuchkProjectFrequency"];
                    
                    replaceSource[@"ItemId"] = pointSource[@"ItemId"];
                    replaceSource[@"LineCode"] = pointSource[@"LineCode"];
                    replaceSource[@"LineName"] = pointSource[@"LineName"];
                    replaceSource[@"LinePK"] = pointSource[@"LinePK"];
                    
                    [dataSource addObject:replaceSource];
                }
                
            }
        }
        
    }
    
    return dataSource;
}

- (BOOL)isExistEnergyMeterDataWithData:(id)data model:(id)model {
    NSDictionary *dict = (NSDictionary *)data;
    EnergyMeterReadingModel *tempModel = (EnergyMeterReadingModel *)model;
    if ([dict[@"MeterKind"] isEqualToString:tempModel.MeterKind]
        && [dict[@"PBuildingName"] isEqualToString:tempModel.PBuildingName]
        && [dict[@"PFloorName"] isEqualToString:tempModel.PFloorName]
        && [dict[@"PProjectName"] isEqualToString:tempModel.PProjectName]
        && [dict[@"PRoomName"] isEqualToString:tempModel.PRoomName]) {
        return YES;
    }
    return NO;
}

- (NSArray *)fetchEnergyMeterDataWithData:(id)data type:(NSInteger)type{
    
    NSDictionary *dict = (NSDictionary *)data;
    NSMutableString *resultSQL = [NSMutableString stringWithFormat:@"SELECT * FROM EnergyMeterReadingModel WHERE TYPE = '%@'",@(type)];
    if (![dict[@"MeterKind"] isEqualToString:@""]) {
        [resultSQL appendFormat:@" AND MeterKind = '%@'",dict[@"MeterKind"]];
    }
    
    if (![dict[@"PProjectName"] isEqualToString:@""]) {
        [resultSQL appendFormat:@" AND PProjectName = '%@'",dict[@"PProjectName"]];
    }
    
    if (![dict[@"PBuildingName"] isEqualToString:@""]) {
        [resultSQL appendFormat:@" AND PBuildingName = '%@'",dict[@"PBuildingName"]];
    }
    
    if (![dict[@"PFloorName"] isEqualToString:@""]) {
        [resultSQL appendFormat:@" AND PFloorName = '%@'",dict[@"PFloorName"]];
    }
    
    if (![dict[@"PRoomName"] isEqualToString:@""]) {
        [resultSQL appendFormat:@" AND PRoomName = '%@'",dict[@"PRoomName"]];
    }
    
    NSArray *array = [EnergyMeterReadingModel findByCriteriaSQL:resultSQL];
    return array;
}

- (NSDictionary *)fetchEquipmentPatrolWithData:(id)data type:(NSInteger)type key:(NSString *)key{
    
    NSDictionary *info = (NSDictionary *)[BaseTool dictionaryWithJsonString:data];
    NSArray *dinfos = (NSArray *)info[@"dinfos"];
    NSArray *pinfos = (NSArray *)info[@"pinfos"];
    NSArray *items = (NSArray *)info[@"items"];
    
    NSMutableArray *projects = [NSMutableArray arrayWithCapacity:20];
    NSMutableArray *itemObjects = [NSMutableArray arrayWithCapacity:20];
    
    NSMutableDictionary *projectDictionaries = [NSMutableDictionary dictionaryWithCapacity:20];
    NSMutableArray *projectArray = [NSMutableArray arrayWithCapacity:20];
    NSString *typePK = nil;
    NSMutableArray *projectPKs = [NSMutableArray arrayWithCapacity:20];
    
    for (NSDictionary *subDinfo in dinfos) {
        if ([subDinfo[@"FlagNo"] isEqualToString:key]) {
            typePK = subDinfo[@"TypePK"];
            
            if (type == 1) {
                
                [projects addObject:subDinfo];
                
                //每一个设备下对应多少项目
                NSMutableArray *subs = [NSMutableArray arrayWithCapacity:20];
                for (NSDictionary *subPinfo in pinfos) {
                    if ([subPinfo[@"TypePK"] isEqualToString:typePK]) {
                        [subs addObject:subPinfo];
                    }
                }
                [itemObjects addObject:subs];
                
            }
            
        }
    }
    
    for (NSDictionary *subPinfo in pinfos) {
        if ([subPinfo[@"TypePK"] isEqualToString:typePK]) {
            [projectPKs addObject:subPinfo[@"ProjectPK"]];
            
            if (type == 0) {
                [projects addObject:subPinfo];
                
                NSMutableArray *subs = [NSMutableArray arrayWithCapacity:20];
                for (NSDictionary *subDinfo in dinfos) {
                    if ([subDinfo[@"FlagNo"] isEqualToString:key]) {
                        [subs addObject:subDinfo];
                    }
                }
                [itemObjects addObject:subs];
            }
        }
    }
    
    for (NSDictionary *subItem in items) {
        for (NSString *projectPK in projectPKs) {
            if ([subItem[@"ProjectPK"] isEqualToString:projectPK]) {
                [projectArray addObject:subItem];
            }
        }
    }
    
    projectDictionaries[@"Pinfo"] = projectArray;
    projectDictionaries[@"Item"] = itemObjects;
    projectDictionaries[@"Projects"] = projects;
    
    
    return projectDictionaries;
}

+ (CGFloat)caculateWidthWithContent:(NSString *)content font:(UIFont *)font height:(CGFloat)height{
    
    NSDictionary *attrbute = @{NSFontAttributeName:font};
    CGRect rect = [content boundingRectWithSize:(CGSize){CGFLOAT_MAX, height} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrbute context:nil];
    return ceilf(rect.size.width + 40);
}
    
+ (CGFloat)caculateHeightWithContent:(NSString *)content font:(UIFont *)font width:(CGFloat)width {
    NSDictionary *attrbute = @{NSFontAttributeName:font};
    CGRect rect = [content boundingRectWithSize:(CGSize){width,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrbute context:nil];
    return ceilf(rect.size.height + 5);
}
@end
