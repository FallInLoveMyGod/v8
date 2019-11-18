//
//  RentControlTipView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "RentControlTipView.h"
#import "BaseTool.h"
#import "UIView+SDAutoLayout.h"

@implementation RentControlTipView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    CGFloat height = self.frame.size.height / 3.0;
//    self.topTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, height)];
//    self.topTipLabel.textAlignment = NSTextAlignmentCenter;
//    self.topTipLabel.font = [UIFont systemFontOfSize:15.0];
//    self.topTipLabel.textColor = [UIColor grayColor];
//    [self addSubview:self.topTipLabel];
//
//    self.bottomTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.topTipLabel.frame.size.height + self.topTipLabel.frame.origin.y, self.frame.size.width, height * 2.0)];
//    self.bottomTipLabel.textAlignment = NSTextAlignmentCenter;
//    self.bottomTipLabel.font = [UIFont boldSystemFontOfSize:17];
//    [self addSubview:self.bottomTipLabel];
    self.topTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.width, height)];
    self.topTipLabel.textAlignment = NSTextAlignmentCenter;
    self.topTipLabel.font = [UIFont systemFontOfSize:15.0];
    self.topTipLabel.textColor = [UIColor grayColor];
    [self addSubview:self.topTipLabel];

    self.bottomTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.topTipLabel.height + self.topTipLabel.top, self.width, height * 2.0)];
    self.bottomTipLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomTipLabel.font = [UIFont boldSystemFontOfSize:17];
    [self addSubview:self.bottomTipLabel];
    
}
@end
