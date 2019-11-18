//
//  MessageTool.m
//  Client
//
//  Created by xiaerfei on 15/10/27.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "MessageTool.h"
@implementation MessageTool


+ (void)setToken:(NSString *)token {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:token forKey:@"token"];
    [settings synchronize];
}

+ (NSString *)token {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"token"];
}

+ (NSString *)PushGlobalNotificationStr {
    return @"PushGlobalNotification";
}

+ (NSString *)DBChangeNotificationStr {
    return @"DBChangeNotification";
}

+ (NSString *)ConnectStateNotificationStr {
    return @"disConnectNotificationStr";
}

+ (void)setConnectStatus:(NSString *)connectStatus {
    
    NSString *oldConnectStatus = [MessageTool connectStatus];
    
    if (![connectStatus isEqualToString:oldConnectStatus] && ![connectStatus isEqualToString:@"-1"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[MessageTool ConnectStateNotificationStr] object:connectStatus];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:connectStatus forKey:[NSString stringWithFormat:@"%@connectStatus",@""]];
    [defaults synchronize];
}

+ (NSString *)connectStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@connectStatus",@""]];
}


+ (void)setDisturbed:(NSString *)disturbedStr {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:disturbedStr forKey:[NSString stringWithFormat:@"%@disturb",@""]];
    [defaults synchronize];
}

+ (NSString *)getDisturbed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@disturb",@""]];
}

+ (void)setUserID:(NSString *)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userID forKey:@"User_ID"];
    [defaults synchronize];
}

+ (NSString *)getUserID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"User_ID"];
}

+ (void)setSessionId:(NSString *)sessionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:sessionId forKey:[NSString stringWithFormat:@"%@sessionId",@""]];
    [defaults synchronize];
}

+ (NSString *)sessionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@sessionId",@""]];
}

+ (void)setClientCacheExprired:(NSString *)clientCacheExprired {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:clientCacheExprired forKey:[NSString stringWithFormat:@"%@clientCacheExprired",@""]];
    [defaults synchronize];
}

+ (NSString *)clientCacheExprired {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@clientCacheExprired",@""]];
}

+ (void)setLastedReadTime:(NSString *)lastedReadTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:lastedReadTime forKey:[NSString stringWithFormat:@"%@lastedReadTime",@""]];
    [defaults synchronize];
}

+ (NSString *)lastedReadTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@lastedReadTime",@""]];
}

+ (void)setDBChange:(NSString *)isChanged {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:isChanged forKey:[NSString stringWithFormat:@"%@isChanged",@""]];
    [defaults synchronize];

}

+ (NSString *)DBChange {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@isChanged",@""]];
}

//置顶groupid
+ (void)setTopGroupId:(NSString *)topGroupId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:topGroupId forKey:[NSString stringWithFormat:@"%@topGroupId",@""]];
    [defaults synchronize];
}

+ (NSString *)topGroupId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@topGroupId",@""]];
}
//区别有无未读消息
+ (void)setUnReadMessage:(NSString *)unReadMessage {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnReadMessage_Notification" object:unReadMessage];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:unReadMessage forKey:[NSString stringWithFormat:@"%@unReadMessage",@""]];
    [defaults synchronize];

}

+ (NSString *)unReadMessage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@unReadMessage",@""]];
}

+ (void)setInterval:(NSString *)intervalStr {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:intervalStr forKey:[NSString stringWithFormat:@"%@Interval",@""]];
    [defaults synchronize];
}

+ (NSString *)getInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@Interval",@""]];
}

+ (void)setDisconnectInterval:(NSString *)disconnectInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:disconnectInterval forKey:[NSString stringWithFormat:@"%@disconnectInterval",@""]];
    [defaults synchronize];
}

+ (NSString *)getDisconnectInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@disconnectInterval",@""]];
}

+ (void)setAppClient:(NSString *)appClient {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:appClient forKey:@"appClient"];
    [defaults synchronize];

}

+ (NSString *)appClient {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"appClient"];
}

+ (void)setDeviceToken:(NSString *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:deviceToken forKey:@"deviceToken"];
    [defaults synchronize];

}

+ (NSString *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"deviceToken"];
}

+ (void)setActiveDisconnect:(NSString *)activeDisconnect {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:activeDisconnect forKey:[NSString stringWithFormat:@"%@activeDisconnect",@""]];
    [defaults synchronize];
}

+ (NSString *)activeDisconnect {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@activeDisconnect",@""]];
}

+ (NSDictionary *)dealDataWithDict:(NSDictionary *)tempDict {
    
    NSMutableDictionary *groupInfo = [[NSMutableDictionary alloc] init];
    
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"createTime"]] forKey:@"CreateTime"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"companyName"]] forKey:@"CompanyName"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"groupName"]] forKey:@"GroupName"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"groupType"]] forKey:@"GroupType"];
    [groupInfo setValue:[MessageTool getUserID] forKey:@"AccountId"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"groupId"]] forKey:@"GroupId"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"approveStatus"]] forKey:@"ApproveStatus"];
    
    if (tempDict[@"lastedMsg"] && ![tempDict[@"lastedMsg"] isKindOfClass:[NSNull class]]) {
        
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"msgId"]] forKey:@"LastedMsgId"];
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"sender"]] forKey:@"LastedMsgSenderName"];
        
        if (tempDict[@"lastedMsg"][@"time"]) {
            [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"time"]] forKey:@"LastedMsgTime"];
        }else{
            [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"createTime"]] forKey:@"LastedMsgTime"];
        }
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"content"]] forKey:@"LastedMsgContent"];
        
    }else{
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"createTime"]] forKey:@"LastedMsgTime"];
    }
    
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"unReadMsgCount"]?tempDict[@"unReadMsgCount"]:@"0"] forKey:@"UnReadMsgCount"];
    
    if ([[MessageTool topGroupId] isEqualToString:tempDict[@"groupId"]]) {
        [groupInfo setObject:@"YES" forKey:@"isTop"];
    }
    
    return groupInfo;
}


+ (NSDateFormatter *)shareDateForMatter
{
    static NSDateFormatter * sharedDateFormatter;
    if(sharedDateFormatter == nil) {
        sharedDateFormatter = [[NSDateFormatter alloc] init];
    }
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [sharedDateFormatter setTimeZone:timeZone];
    return sharedDateFormatter;
}

@end
