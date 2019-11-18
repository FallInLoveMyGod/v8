//
//  DJFloatingVoiceView.h
//  DeJiaIM
//
//  Created by fjf on 16/5/16.
//  Copyright © 2016年 tsningning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FJFloatingViewDelegate <NSObject>

- (void)floatingViewClick;

@end

#define    FJ_FLOATING_VOICE_VIEW_SIZE  68
@interface FJFloatingView : UIView
// 图标
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, weak) id <FJFloatingViewDelegate> delegate;

@end
