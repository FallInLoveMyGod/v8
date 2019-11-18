//
//  LocationManager.h
//  ToCZhuXY
//
//  Created by Mac on 2017/10/14.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

typedef void (^LocationResult)(CLLocationDegrees latitude, CLLocationDegrees longitude);

@interface LocationManager : NSObject <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, copy) LocationResult locationResult;
+ (instancetype)shareManager;
- (void)location;
@end
