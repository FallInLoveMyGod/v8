//
//  BaseTool.h
//  PropertyManagementPlus
//
//  Created by jana on 17/1/11.
//  Copyright © 2017年 Lesoft. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppDelegate;
#define ThemeColor [UIColor colorWithRed:0.0 green:160.0/250.0 blue:234.0/255.0 alpha:1.0f]
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface BaseTool : NSObject
+ (BOOL)isExistenceNetwork;
+ (NSInteger)isKind:(id)object;
+ (UIColor *)setColorWithContent:(NSString *)content;

+ (void)registerUserNotificationWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions ;
+ (NSString *)deviceTokenWithData:(NSData *)data;
+ (NSString *)channelIdWithResult:(id)result;

+ (UIImage*)createImageWithColor:(UIColor*) color;
+ (NSMutableArray *)sortData:(NSMutableArray *)datas;
+ (NSString *)toJson:(id)data;
+ (NSInteger)toInt:(id)data;
+ (NSString *)toStr:(id)data;
+ (CGFloat)toFloat:(id)data;
//日期处理
+ (NSString *)dealDateWithDateString:(NSString *)dateString;
+ (NSString *)dealFormateDate:(NSString *)dateString seperate:(NSString *)seperate;
+ (CGFloat)calculateHeightWithText:(NSString *)text textLabelFont:(UIFont *)textLabelFont isCaculateWidth:(BOOL)isCaculateWidth widthOrHeightData:(CGFloat)widthOrHeightData;
+ (CGFloat)calculateHeightWithText:(NSString *)text font:(UIFont *)font isCaculateWidth:(BOOL)isCaculateWidth data:(CGFloat)data;
+ (BOOL)isZoreVuleWithObject:(NSString *)object;
+ (id)dictionaryWithJsonString:(NSString *)jsonString;
+ (void)setKeyBoradChangeInfo:(NSString *)keyBoradChangeInfo;
+ (NSDictionary *)getKeyBoradChangeInfo;
+ (NSArray *)lenghtValueWithContent:(NSString *)content;
+ (NSString *)version;
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;
+ (CIImage *)createQRForString:(NSString *)qrString;
+ (NSArray *)seperateByContent:(id)content seperate:(NSString *)seperate;
+ (void)changeColorWithKey:(NSString *)key content:(NSString *)content textLabel:(UILabel *)textLabel;

//添加完成toolBar
+ (UIToolbar *)addToolBarWithTarget:(UIViewController *)target action:(SEL)action;

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end
