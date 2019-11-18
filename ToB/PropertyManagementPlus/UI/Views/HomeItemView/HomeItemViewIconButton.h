//
//  HomeItemViewIconButton.h
//  test
//
//  Created by wwt on 14-11-13.
//  Copyright (c) 2014年 wsy.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeItemViewIconButtonDataSource <NSObject>
-(NSString *)setIconTitle;
-(UIImage * )setIcon;

@end

@interface HomeItemViewIconButton : UIButton
@property (nonatomic, strong) NSString * titleBelowIcon;
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, weak) id <HomeItemViewIconButtonDataSource> dataSource;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) UILabel * contentLabel;

- (id)initWithFrame:(CGRect)frame contentLabelHeight:(CGFloat)contentLabelHeight;

@end
