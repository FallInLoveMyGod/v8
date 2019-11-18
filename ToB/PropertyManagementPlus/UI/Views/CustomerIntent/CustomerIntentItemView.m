//
//  CustomerIntentItemView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "CustomerIntentItemView.h"
#import "BaseTool.h"

@interface CustomerIntentItemView ()

@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *icons;

@end

@implementation CustomerIntentItemView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles icons:(NSArray *)icons {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.icons = icons;
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    
    CGFloat width = kWidth/self.titles.count;
    
    for (int i = 0; i < self.titles.count; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * width, 0, width, self.frame.size.height);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:self.icons[i]] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(buttonItemClick:intentView:)]) {
        [self.delegate buttonItemClick:sender intentView:self];
    }
}

@end
