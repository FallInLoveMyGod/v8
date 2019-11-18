//
//  MessageModel.m
//  QQ聊天布局
//
//  Created by xiaerfei on 15-10-19.
//  Copyright (c) 2015年 xiaerfei. All rights reserved.
//

#import "MessageModel.h"
#import "MessageCenterMetadataModel.h"
#import "NSString+Extension.h"
#import "MessageTool.h"
#import "AttLinkData.h"

@implementation MessageModel

#pragma mark - public methods
/**
 *   @author xiaerfei, 15-11-03 14:11:25
 *
 *   解析推送过来的信息
 *
 *   @param data Data
 *
 *   @return Model
 */
+ (MessageModel *)parseNotifyData:(id)data modelType:(MessageModelType)modelType
{
    NSDictionary *dict  = data;
    MessageModel *model = [[MessageModel alloc] init];
    model.messageId     = dict[@"_id"];
    model.text          = [dict[@"content"] unescape];
    model.fromId        = dict[@"from"];
    model.groupId       = dict[@"toGroupId"];
    model.userMessageId = dict[@"userMessageId"];
    model.personName    = dict[@"personName"];
    model.messageTime   = dict[@"time"];
    model.clientMsgId   = dict[@"clientMsgId"];
    model.type          = dict[@"type"];
    NSArray *time       = [MessageModel parseTime:dict[@"time"]];
    model.yearAndMoth   = [time firstObject];
    model.time          = [time lastObject];
    model.modelType     = modelType;
    
    NSString *status = dict[@"status"];
    if (!isEmptyString(status)) {
        model.isSendFail = !status.boolValue;
    }
    
    // 判断是否是系统消息
    NSInteger typeValue = [dict[@"type"] integerValue];
    if (typeValue == 101 || typeValue == 106) {
        model.messageType   = MessageTypeSystem;
        if (isEmptyString(model.text) || [model.text isEqualToString:@"(null)"] || [model.text isEqualToString:@"<null>"]) {
            return nil;
        }
    } else {
        model.messageType   = MessageTypeChat;
    }
    
    [MessageModel calculateMessageModel:model];
    return model;
}
/**
 *   @author xiaerfei, 15-11-03 14:11:05
 *
 *   发送消息 转为对应的Model
 *
 *   @param content
 *
 *   @return 
 */
+ (MessageModel *)sendMessageWithContent:(NSString *)content
{
    NSDate *senddate = [NSDate date];
    NSDateFormatter *dateformatter = [MessageTool shareDateForMatter];
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    [dateformatter setTimeZone:timeZone];
    
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *time = [dateformatter stringFromDate:senddate];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yearAndMoth = [dateformatter stringFromDate:senddate];
    
    MessageModel *model = [[MessageModel alloc] init];
    model.text = content;
    model.time = time;
    model.yearAndMoth = yearAndMoth;
    model.modelType = MessageModelTypeMe;
    model.messageType = MessageTypeChat;
    model.animateStatus = YES;
    [MessageModel calculateMessageModel:model];
    return model;
}
#pragma mark 操作db
+ (NSDictionary *)messageCenterStatusWithGroupId:(NSString *)groupId
{
    NSArray *array = [NSArray array];
    
    MessageCenterMetadataModel *messageCenterMetadataModel = [array lastObject];
    
    NSDictionary *dict = @{@"approveStatus":messageCenterMetadataModel.approveStatus== nil?@"":messageCenterMetadataModel.approveStatus,
                           @"unReadMsgCount":messageCenterMetadataModel.unReadMsgCount== nil?@"":messageCenterMetadataModel.unReadMsgCount,
                           @"isTop":messageCenterMetadataModel.isTop== nil?@"":messageCenterMetadataModel.isTop,
                           @"groupName":messageCenterMetadataModel.groupName== nil?@"":messageCenterMetadataModel.groupName,
                           @"companyName":messageCenterMetadataModel.companyName== nil?@"":messageCenterMetadataModel.companyName};
    return dict;
}

/**
 *   @author xiaerfei, 15-11-05 10:11:05
 *
 *   插入时间分割线
 *
 *   @param currentModel     现在的消息
 *   @param lastModel        上一条消息
 *   @param destinationArray 要加入的数组
 *   @param index            插入的地方
 */
+ (void)getTimeIntervalCurrentModel:(MessageModel *)currentModel lastModel:(MessageModel *)lastModel destinationArray:(NSMutableArray *)destinationArray atIndex:(NSInteger)index
{
    if (lastModel.messageType == MessageTypeTime) {
        return;
    }
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date1 = [formatter dateFromString:currentModel.yearAndMoth];
    NSDate *date2 = [formatter dateFromString:lastModel.yearAndMoth];
    NSTimeInterval aTimer = [date1 timeIntervalSinceDate:date2];
    if (aTimer >= 86400.0f) {
        MessageModel *message = [[MessageModel alloc] init];
        message.yearAndMoth = currentModel.yearAndMoth;
        message.messageType = MessageTypeTime;
        [destinationArray insertObject:message atIndex:index];
    }
}

+ (NSString *)createClientMsgId
{
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [NSDate date];

    return [NSString stringWithFormat:@"%.0f-%@",[date timeIntervalSince1970],[MessageTool sessionId]];
}


#pragma mark - private methods
/**
 *   @author xiaerfei, 15-11-03 14:11:01
 *
 *   解析成对应的Model 或计算每条消息对应的frame
 *
 *   @param model
 */
+ (void)calculateMessageModel:(MessageModel *)model
{
    CGFloat screenWith   = [UIScreen mainScreen].bounds.size.width;
    if (model.messageType == MessageTypeChat) {
        CGFloat maxWidth = screenWith - 60 - 80;
        AttFrameParserConfig *config = [[AttFrameParserConfig alloc] init];
        config.width = maxWidth;
        config.fontSize = 15.0f;
        if (model.modelType == MessageModelTypeMe) {
            config.textColor = [UIColor whiteColor];
        } else {
            config.textColor = [UIColor blackColor];
        }
        AttTextData *attTextData = nil;
        CGSize textSize;
        if (model.text.length != 0) {
            NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            model.text = [[NSString alloc]initWithString:[model.text stringByTrimmingCharactersInSet:whiteSpace]];
            attTextData = [AttFrameParser parseWithContentString:model.text config:config];
            model.attTextData = attTextData;
            textSize = attTextData.textSize;
        } else {
            textSize = CGSizeMake(0, 0);
        }
        
        if (textSize.width > maxWidth) {
            textSize.width = maxWidth;
        }
        
        model.textHeigh = textSize.height;
        model.textSize  = textSize;
        if (textSize.width < 26) {
            textSize.width = 26;
        }
        if (textSize.height < 22) {
            textSize.height = 22;
        }
        
        if (model.modelType == MessageModelTypeMe) {
            model.iconFrame = CGRectMake(screenWith-50, 0, 40, 40);
            model.chatFrame = CGRectMake(screenWith-65-200, 0, 200, 20);
            model.bgFrame   = CGRectMake(screenWith-60- (textSize.width+20), 21, textSize.width+20, textSize.height+10);
        } else if (model.modelType == MessageModelTypeOther) {
            model.iconFrame = CGRectMake(10, 0, 40, 40);
            model.chatFrame = CGRectMake(65, 0, 200, 20);
            model.bgFrame   = CGRectMake(60, 21, textSize.width+20, textSize.height+10);
        }
        
        CGFloat cellHeight = model.chatFrame.size.height + textSize.height;
        if (cellHeight < model.iconFrame.size.height) {
            cellHeight = model.iconFrame.size.height + 10;
        } else {
            cellHeight += 10;
        }
        model.cellHeght = cellHeight+10;
    }
    
    if (model.messageType == MessageTypeSystem) {
        CGFloat maxWidth = screenWith - 70-20;
        CGSize textSize;
        if (model.text.length != 0) {
            textSize = [model.text sizeWithFont:[UIFont systemFontOfSize:14.0] maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
        } else {
            textSize = CGSizeMake(0, 0);
        }
        model.textSize  = textSize;
        model.textHeigh = textSize.height;
        model.cellHeght = textSize.height + 30;
        model.bgFrame = CGRectMake((SCREENWIDTH - model.textSize.width - 10)/2.0f, (model.cellHeght - model.textHeigh - 10)/2.0f,model.textSize.width+10, model.textHeigh+10);
    }
}
/**
 *   @author xiaerfei, 15-11-17 09:11:52
 *
 *   解析系统返回的时间 2015-11-19T07:46:57.525Z
 *                   2015-11-20T02:05:46.000Z
 *   @param time
 *
 *   @return
 */
+ (NSArray *)parseTime:(NSString *)time
{
    if (isEmptyString(time) || [time isEqualToString:@"(null)"]) {
        return nil;
    }
    NSArray *array = [time componentsSeparatedByString:@"T"];
    NSString *yearAndMoth = [array firstObject];
    NSString *timeText = [[[array lastObject] componentsSeparatedByString:@"."] firstObject];
    if (isEmptyString(timeText) || isEmptyString(yearAndMoth)) {
        return @[@"",@""];
    }
    
    NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSArray *nowTimes = [nowDate componentsSeparatedByString:@" "];
    
    
    NSArray *times = [time componentsSeparatedByString:@" "];
    //时间
    NSString *timeDateStr = [[times[0] componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
    
    NSArray *dateArray = [nowTimes[0] componentsSeparatedByString:@"-"];
    NSArray *compareDateArray = [timeDateStr componentsSeparatedByString:@"-"];
    
    if ([dateArray[0] intValue] == [compareDateArray[0] intValue] && [dateArray[1] intValue] == [compareDateArray[1] intValue] && [dateArray[2] intValue] == [compareDateArray[2] intValue]) {
        //不需要日期
        return @[[self parseHours:times[1]],[self parseHours:times[1]]];
    }else {
        //需要日期
        
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        //当前日期
        NSDate *nowDate = [NSDate date];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *nowDateStr = [formatter stringFromDate:nowDate];
        nowDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",[nowDateStr componentsSeparatedByString:@" "][0]]];
        
        //经过转换后的日期
        NSDate *dataDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",timeDateStr,times[1]]];
        
        NSTimeInterval gapInterval = [dataDate timeIntervalSinceDate:nowDate];
        
        if (gapInterval < 0) {
            if (gapInterval > -secondsPerDay) {
                //昨天
                return @[[NSString stringWithFormat:@"昨天 %@",[self parseHours:times[1]]],[NSString stringWithFormat:@"昨天 %@",[self parseHours:times[1]]]];
            }
        }
        
        NSArray *months= [times[0] componentsSeparatedByString:@"/"];
        
        if ([dateArray[0] intValue] == [compareDateArray[0] intValue]) {
            return @[[NSString stringWithFormat:@"%@月%@日 %@",months[1],months[2],[self parseHours:times[1]]]];
        }else {
            return @[[NSString stringWithFormat:@"%@年%@月%@日 %@",months[0],months[1],months[2],[self parseHours:times[1]]]];
        }
    }
    
    return [yearAndMoth componentsSeparatedByString:@" "];
}

+ (NSString *)parseHours:(NSString *)hour {
    
    NSArray *hours = [hour componentsSeparatedByString:@":"];
    
    switch ([hours[0] intValue]) {
        case 0:
        case 2:
        case 3:
        case 4:
        case 5:
            case 6:
            return [NSString stringWithFormat:@"凌晨 %@:%@",hours[0],hours[1]];
            break;
        case 7:
        case 8:
            return [NSString stringWithFormat:@"早上 %@:%@",hours[0],hours[1]];
            break;
        case 9:
        case 10:
        case 11:
        case 12:
            return [NSString stringWithFormat:@"上午 %@:%@",hours[0],hours[1]];
            break;
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
            return [NSString stringWithFormat:@"下午 %@:%@",hours[0],hours[1]];
            break;
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
            return [NSString stringWithFormat:@"晚上 %@:%@",hours[0],hours[1]];
            break;
            
        default:
            break;
    }
    return hour;
}

/**
 *   @author xiaerfei, 15-11-13 15:11:02
 *
 *   拼接时间字符串为： 2015-11-13T15:54:07.000Z 格式
 *
 *   @return
 */
+ (NSString *)componentsTime
{
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    NSDate *date = [NSDate date];
    NSString *timeStr = [formatter stringFromDate:date];
    return timeStr;
}

+ (NSArray *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [MessageTool shareDateForMatter];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yearAndMonth = [dateFormatter stringFromDate:dateFormatted];
    [timeArray addObject:yearAndMonth];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *second = [dateFormatter stringFromDate:dateFormatted];
    [timeArray addObject:second];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *allTime = [dateFormatter stringFromDate:dateFormatted];
    [timeArray addObject:allTime];
    return timeArray;
}


@end

