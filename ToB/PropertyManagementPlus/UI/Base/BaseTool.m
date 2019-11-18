//
//  BaseTool.m
//  PropertyManagementPlus
//
//  Created by jana on 17/1/11.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "BaseTool.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define IOS_IS_AT_LEAST_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

static NSString *appKey = @"ed7d7ce12ba96c153bc01035";
static NSString *channel = @"App Store";
static BOOL isProduction = FALSE;

@implementation BaseTool

+ (BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork = NO;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=NO;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=YES;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=YES;
            break;
    }
    return isExistenceNetwork;
}

+ (NSInteger)isKind:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return 1;
    }
    return 0;
}

+ (UIColor *)setColorWithContent:(NSString *)content {
    
    /*
     
     创建单据未提交,创建附件未提交,未分派任务,回访未提交,检验提交  #ff0000
     完成附件未提交,完成单据未提交  #a0ff4444
     未派单,派单中,已完成待回访,已完成待检验,已回访,已检验 #008000
     进行中  #a099cc00
     
     */
    
    if ([content isEqualToString:@"创建单据未提交"]
        || [content isEqualToString:@"创建附件未提交"]
        || [content isEqualToString:@"未分派任务"]
        || [content isEqualToString:@"回访未提交"]
        || [content isEqualToString:@"检验提交"]) {
        
        return [BaseTool colorWithHexString:@"#ff0000"];
        
    }else if ([content isEqualToString:@"完成附件未提交"]
              || [content isEqualToString:@"完成单据未提交"]) {
        
        return [BaseTool colorWithHexString:@"#ff4444"];
        
    }else if ([content isEqualToString:@"未派单"]
              || [content isEqualToString:@"派单中"]
              || [content isEqualToString:@"已完成待回访"]
              || [content isEqualToString:@"已完成待检验"]
              || [content isEqualToString:@"已回访"]
              || [content isEqualToString:@"已检验"]) {
        
        return [BaseTool colorWithHexString:@"#008000"];
        
    }else {
        //进行中
        return [BaseTool colorWithHexString:@"#99cc00"];
    }
    
    return [UIColor blackColor];
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (void)registerUserNotificationWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:delegate];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            delegate.registrationID = registrationID;
            if (delegate.isLoginSuccess) {
                [delegate notificationActionWithLoginState:1];
            } else {
                [delegate notificationActionWithLoginState:2];
            }
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

+ (NSString *)deviceTokenWithData:(NSData *)data {
    
    NSString *token = [[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return token;
}

+ (NSString *)channelIdWithResult:(id)result {
    
    if ([result[@"error_code"]intValue]!=0) {
        return @"";
    }
    // 获取channel_id
//    NSString *myChannel_id = [BPush getChannelId];
    
    return @"";
}

+ (UIImage*) createImageWithColor:(UIColor*) color {
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSMutableArray *)sortData:(NSMutableArray *)datas {
    
    NSMutableArray *valueArray = [NSMutableArray arrayWithArray:datas];
    [valueArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GetRepaireListModel *model1 = (GetRepaireListModel *)obj1;
        GetRepaireListModel *model2 = (GetRepaireListModel *)obj2;
        return [model2.ModifyTime compare:model1.ModifyTime];
    }];
    
    return valueArray;
}

+ (NSString *)toJson:(id)data {
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:kNilOptions
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSInteger)toInt:(id)data {
    return [data intValue];
}

+ (NSString *)toStr:(id)data {
    if (!data || [data isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",data];
}

+ (CGFloat)toFloat:(id)data {
    if (!data || [data isKindOfClass:[NSNull class]]) {
        return 0.0;
    }
    return [[NSString stringWithFormat:@"%@",data] floatValue];
}

+ (NSString *)dealDateWithDateString:(NSString *)dateString {
    
    if ([dateString isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    @try {
        //字符串分割
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSArray *datesArr = [dateString componentsSeparatedByCharactersInSet:characterSet];
        NSString *convertDateStr = [NSString stringWithFormat:@"%@ %@",datesArr[0],datesArr[1]];
        NSString *convertStartDateStr = [datesArr[0] componentsSeparatedByString:@"-"][0];
        
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        //当前日期
        NSDate *nowDate = [NSDate date];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *nowDateStr = [formatter stringFromDate:nowDate];
        nowDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",[nowDateStr componentsSeparatedByString:@" "][0]]];
        NSString *nowStartDateStr = [nowDateStr componentsSeparatedByString:@"-"][0];
        
        //经过转换后的日期
        NSDate *dataDate = [formatter dateFromString:convertDateStr];
        
        NSTimeInterval gapInterval = [dataDate timeIntervalSinceDate:nowDate];
        
        NSArray *subArr = [datesArr[1] componentsSeparatedByString:@":"];
        
        if (gapInterval < 0) {
            
            if (gapInterval > -secondsPerDay) {
                return [NSString stringWithFormat:@"昨天 %@:%@",subArr[0],subArr[1]];
            }else {
                if ([convertStartDateStr isEqualToString:nowStartDateStr]) {
                    NSMutableArray *timesArray = [NSMutableArray arrayWithArray:[datesArr[0] componentsSeparatedByString:@"-"]];
                    [timesArray removeObjectAtIndex:0];
                    NSString *timeFore = [timesArray componentsJoinedByString:@"-"];
                    
                    NSMutableArray *timesHours = [NSMutableArray arrayWithArray:[datesArr[1] componentsSeparatedByString:@":"]];
                    [timesHours removeLastObject];
                    NSString *timeBack = [timesHours componentsJoinedByString:@":"];
                    
                    return [NSString stringWithFormat:@"%@ %@",timeFore,timeBack];
                }else {
                    //不是今年
                    return [NSString stringWithFormat:@"%@",datesArr[0]];
                }
                return convertDateStr;
            }
            
        }else {
            
            NSTimeInterval secondsPerHour = 60 * 60;
            NSTimeInterval secondsPerMinutes = 60;
            
            if (gapInterval > 0 && gapInterval < secondsPerMinutes) {
                return [NSString stringWithFormat:@"%f 秒前",gapInterval];
            }else if (gapInterval >= secondsPerMinutes && gapInterval < secondsPerHour) {
                return [NSString stringWithFormat:@"%f 分钟前",gapInterval/60];
            }else {
                return [NSString stringWithFormat:@"今天 %@:%@",subArr[0],subArr[1]];
            }
            
        }
        
        return convertDateStr;
    } @catch (NSException *exception) {
        return dateString;
    } @finally {
        
    }
    
}

+ (NSString *)dealFormateDate:(NSString *)dateString seperate:(NSString *)seperate{
    if ([dateString isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSArray *datesArr = [dateString componentsSeparatedByString:@" "];
    NSString *convertStartDateStr = [NSString stringWithFormat:@"%@ %@",[[datesArr[0] componentsSeparatedByString:seperate] componentsJoinedByString:@"-"],datesArr[1]];
    NSDate *date = [formatter dateFromString:convertStartDateStr];
    
    return [formatter stringFromDate:date];
}

//根据要显示的text计算label高度
+ (CGFloat)calculateHeightWithText:(NSString *)text textLabelFont:(UIFont *)textLabelFont isCaculateWidth:(BOOL)isCaculateWidth widthOrHeightData:(CGFloat)widthOrHeightData{
    
    CGFloat height = [BaseTool calculateHeightWithText:text font:textLabelFont isCaculateWidth:isCaculateWidth data:widthOrHeightData];
    
    return height + 10 < 44.0 ? 44.0 : height + 10;
}

+ (CGFloat)calculateHeightWithText:(NSString *)text font:(UIFont *)font isCaculateWidth:(BOOL)isCaculateWidth data:(CGFloat)data {
    
    CGSize size ;
    if (isCaculateWidth) {
        size = CGSizeMake(CGFLOAT_MAX, data);
    }else {
        size = CGSizeMake(data, CGFLOAT_MAX);
    }
    //IOS 7.0 以上
    if (IOS_IS_AT_LEAST_7){
        
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }else{
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        //ios7以上已经摒弃的这个方法
    }
    
    if (isCaculateWidth) {
        return size.width;
    }
    return size.height;
}

+ (BOOL)isZoreVuleWithObject:(NSString *)object {
    if ([[NSString stringWithFormat:@"%@",object] intValue] == 0) {
        return YES;
    }
    return NO;
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (id)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (void)setKeyBoradChangeInfo:(NSString *)keyBoradChangeInfo {
    [[NSUserDefaults standardUserDefaults] setValue:keyBoradChangeInfo forKey:@"KeyBoradChangeInfo"];
}

+ (NSDictionary *)getKeyBoradChangeInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"KeyBoradChangeInfo"];
}

+ (NSArray *)lenghtValueWithContent:(NSString *)content {
    if (!content || [content isKindOfClass:[NSNull class]]) {
        return @[@"0",@"0",@"0",@"0"];
    }
    
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",nil];
    NSInteger index = 0;
    while (content.length > 0) {
        contentArray[index ++] = [content substringToIndex:1];
        content = [content substringFromIndex:1];
        
    }

    
    return contentArray;
}

+ (NSString *)version {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return infoDic[@"CFBundleShortVersionString"];
}

+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *aImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return aImage;
}

+ (NSArray *)seperateByContent:(id)content seperate:(NSString *)seperate{
    
    NSString *seperateContent = [NSString stringWithFormat:@"%@",content];
    return [seperateContent componentsSeparatedByString:seperate];
}

+ (void)changeColorWithKey:(NSString *)key content:(NSString *)content textLabel:(UILabel *)textLabel{
    
    if ([key isEqualToString:@""]) {
        return;
    }
    
    NSMutableAttributedString *messageAttriStr = [[NSMutableAttributedString alloc] initWithAttributedString:textLabel.attributedText];
    
    NSArray *contents = [content componentsSeparatedByString:key];
    
    NSInteger start = 0;
    if (contents.count >= 1) {
        start = [contents[0] length];
    }
    for (int i = 1; i < contents.count; i ++) {
        [messageAttriStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(start, key.length)];
        start += ([contents[i] length] + key.length);
        NSLog(@"start = %d",start);
    }
    textLabel.attributedText = messageAttriStr;
}

//添加完成toolBar
+ (UIToolbar *)addToolBarWithTarget:(UIViewController *)target action:(SEL)action {
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(target.view.frame), 35)];
    toolbar.tintColor = [UIColor blackColor];
    toolbar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:target action:action];
    toolbar.items = @[space, bar];
    return toolbar;
}

@end
