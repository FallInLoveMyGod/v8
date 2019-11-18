//
//  RepairChooseSenderViewController.h
//  单元格的操作
//
//  Created by zhaohe on 16/4/7.
//  Copyright © 2016年 com.MrHe.Mission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RepairChooseSenderResultDelegate <NSObject>

@optional
- (void)popAction:(NSString *)result;
@optional
- (void)popAction:(NSString *)result message:(NSString *)message;
@optional
- (void)popCurrentPageAction:(NSString *)result;

@optional
- (void)changeState:(NSString *)state pk:(NSString *)pk;

@end

@interface RepairChooseSenderViewController : UIViewController

@property (nonatomic, weak) id<RepairChooseSenderResultDelegate> delegate;

@property (nonatomic, copy) NSString *pk;
//1: 新增投诉单(任务派送) 2:派单 3:发起抢单 11:上报
@property (nonatomic, copy) NSString *chooseType;
@property (nonatomic, copy) NSString *eventCode;
@property (nonatomic, copy) NSString *updataType;
@property (nonatomic, copy) NSString *chooseTitle;
@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, copy) NSString *accountCode;
@property (nonatomic, copy) NSString *upk;
@property (nonatomic, copy) NSString *billCode;
@property (nonatomic, copy) NSString *RightName;
@property (nonatomic, copy) NSString *LineState;
- (void)commit;
- (void)commitDirect;
- (void)requestData;
@end

