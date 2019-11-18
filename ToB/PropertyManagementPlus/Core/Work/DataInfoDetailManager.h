//
//  DataInfoDetailManager.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/1.
//  Copyright © 2017年 Lesoft. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface DataInfoDetailManager : NSObject
+ (instancetype)shareInstance;
- (NSArray *)dealCarInfoWithDatas:(id)datas;
- (NSArray *)dealRentControlInfoWithDatas:(id)datas;
//客户意向
- (NSMutableArray *)customerUpdateYXKHInfoValuesWithData:(id)data;
- (NSMutableArray *)energyMeterReadingValuesWithData:(id)data;
- (NSArray *)dealEquipmentWithEquipmentMaterialModel:(id)model datas:(id)datas;
- (NSArray *)dealEnergyMeterReadingWithModel:(id)model;
- (NSMutableDictionary *)dealWareHouseGoodDictionary:(NSMutableDictionary *)wareHouseGoodDictionary;
//选择巡检项目
- (NSString *)safePatrolWithData:(id)data;

//安全巡更
- (void)dealSafePatrolDataWithSecuchkProjectPK:(NSString *)secuchkProjectPK linePK:(NSString *)linePK linePointPK:(NSString *)linePointPK insert:(NSDictionary *)insertDict;
//安全巡更保存
- (void)storeSafePatrolData:(id)data;
- (NSArray *)fetchSafePatrolData;
- (BOOL)isExistEnergyMeterDataWithData:(id)data model:(id)model;
- (NSArray *)fetchEnergyMeterDataWithData:(id)data type:(NSInteger)type;
- (NSDictionary *)fetchEquipmentPatrolWithData:(id)data type:(NSInteger)type key:(NSString *)key;
+ (CGFloat)caculateWidthWithContent:(NSString *)content font:(UIFont *)font height:(CGFloat)height;
+ (CGFloat)caculateHeightWithContent:(NSString *)content font:(UIFont *)font width:(CGFloat)width;
@end
