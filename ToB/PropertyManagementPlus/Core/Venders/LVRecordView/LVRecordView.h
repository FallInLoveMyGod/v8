//
//  LVRecordView.h
//  RecordAndPlayVoice
//
//  Created by 刘春牢 on 15/3/15.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordRelateView.h"

@protocol LVRecordViewDelegate <NSObject>

@optional
- (void)finishedRecord;

@end

@interface LVRecordView : UIView

@property (nonatomic, weak) id <LVRecordViewDelegate> delegate;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *confirmFileName;


+ (instancetype)recordView;

- (NSData *)recordDataWithName:(NSString *)recordFileName;
//数据提交时需要转存数据到指定目录下
- (BOOL)turnRecordFileWithName:(NSString *)confirmFileName;

- (void)setup;
- (void)relateRelationShipWithRecordRelateView:(RecordRelateView *)recordRelateView;

@end
