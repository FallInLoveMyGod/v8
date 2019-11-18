
//
//  LocationManager.m
//  ToCZhuXY
//
//  Created by Mac on 2017/10/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()
@property (nonatomic, strong) BMKLocationService* locService;
@property (nonatomic,strong) BMKGeoCodeSearch *geocodesearch;
@end

@implementation LocationManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static LocationManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
        manager.latitude = 0;
        manager.longitude = 0;
    });
    return manager;
}

- (void)location {
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    
    //启动LocationService
    [_locService startUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    self.latitude = userLocation.location.coordinate.latitude;
    self.longitude = userLocation.location.coordinate.longitude;
    if (self.locationResult != nil) {
        self.locationResult(self.latitude, self.longitude);
    }

    [_locService stopUserLocationService];
}

- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"error = %@",error);
    if (self.locationResult != nil) {
        self.locationResult(self.latitude, self.longitude);
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
}

#pragma mark - getters & setters

@end
