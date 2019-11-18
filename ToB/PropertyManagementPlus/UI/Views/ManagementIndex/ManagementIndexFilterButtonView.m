//
//  ManagementIndexFilterButtonView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "ManagementIndexFilterButtonView.h"
#import "DataInfoDetailManager.h"

#define itemHeight 35

@interface ManagementIndexFilterButtonView ()

@property (nonatomic, copy) NSArray *titles;

@end

@implementation ManagementIndexFilterButtonView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    CGFloat startX = 0;
    CGFloat startY = 0;
    
    for (int i = 0; i < self.titles.count; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIFont *font = [UIFont systemFontOfSize:15];
        
        CGFloat width = [DataInfoDetailManager caculateWidthWithContent:self.titles[i] font:font height:itemHeight];
        
        button.frame = CGRectMake(startX, startY, width, itemHeight);
        
        [button addTarget:self action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = font;
        [button setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 5);
        button.tag = 1000 + i;
        
        startX += button.frame.size.width;
        
        if (startX > self.frame.size.width - 5) {
            //初始位置归0
            startX = 0;
            startY += 30;
            //重置button frame
            i -= 1;
            continue;
        }
        [self addSubview:button];
    }
    
}

+ (CGFloat)fetchCellHeightWithTitles:(NSArray *)titles width:(CGFloat)width{
    
    CGFloat startX = 0;
    CGFloat startY = 0;
    
    for (int i = 0; i < titles.count; i ++) {
        
        UIFont *font = [UIFont systemFontOfSize:15];
        
        CGFloat subWidth = [DataInfoDetailManager caculateWidthWithContent:titles[i] font:font height:36];
        
        startX += subWidth;
        
        if (startX > width - 5) {
            //初始位置归0
            startX = 0;
            startY += 36;
            //重置button frame
            i -= 1;
            continue;
        }
    }
    NSLog(@"startY = %f",startY);
    return startY;
}


- (void)onRadioButtonValueChanged:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(selectItemSection:index:)]) {
        [self.delegate selectItemSection:self.tag - 20000 index:sender.tag - 1000];
    }
    
    for (int i = 0; i < self.titles.count; i ++) {
        UIButton *button = (UIButton *)[self viewWithTag:1000 + i];
        button.selected = NO;
    }
    
    sender.selected = YES;
}

- (void)reloadDataWithIndex:(NSInteger)index{
    for (int i = 0; i < self.titles.count; i ++) {
        
        UIButton *button = (UIButton *)[self viewWithTag:1000 + i];
        if (index == i) {
            button.selected = YES;
        }else {
            button.selected = NO;
        }
    }
}

@end
