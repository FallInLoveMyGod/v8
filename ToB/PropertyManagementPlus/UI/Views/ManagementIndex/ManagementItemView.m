//
//  ManagementItemView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "ManagementItemView.h"
#import "BaseTool.h"

#define Choose @"Choose-Lesoft"

@interface ManagementItemView ()

@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat lastWidth;
@end

@implementation ManagementItemView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.width = kWidth / self.titles.count;
        [self addSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles width:(CGFloat)width {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.width = width;
        [self addSubViews];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles lastItemWidth:(CGFloat)lastItemWidth {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.lastWidth = lastItemWidth;
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    CGFloat contentWidth = self.lastWidth > 0 ? self.lastWidth : self.width;
    CGFloat singleWidth = (kWidth - contentWidth)/(self.titles.count - 1);
    
    for (int i = 0; i < self.titles.count; i ++) {
        
        CGFloat start = self.lastWidth > 0 ? i * singleWidth : (i == 0 ? 0 : contentWidth + (i - 1) * singleWidth);
        
        CGFloat width = self.lastWidth > 0 ? (i == self.titles.count - 1 ? contentWidth : singleWidth) :(i == 0 ? contentWidth : singleWidth);
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(start, 0, width, self.frame.size.height)];
        button.tag = i + 1000;
        
        [self formateWithLabel:button];
        [self addSubview:button];
        
    }
    
}

- (void)formateWithLabel:(UIButton *)button {
    
    NSInteger tag = button.tag - 1000;
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor colorWithRed:108.0/255.0 green:140.0/255.0 blue:170.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    [button setTitle:self.titles[tag] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(managementItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.lastWidth > 0) {
        if ([self.titles[tag] isEqualToString:Choose]) {
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
        }
    }
    button.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:240.0/255.0 blue:254.0/255.0 alpha:1.0f];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor colorWithRed:108.0/255.0 green:140.0/255.0 blue:170.0/255.0 alpha:1.0f].CGColor;
}

- (void)setManagementItemSelect:(NSInteger)managementItemSelect {
    UIButton *select = (UIButton *)[self viewWithTag:1000 + self.titles.count - 1];
    [select setSelected: managementItemSelect];
}

#pragma mark - event response

- (void)managementItemClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(selectManagementItemViewItem:)]) {
        [self.delegate selectManagementItemViewItem:self.tag - 1];
    }
}

@end
