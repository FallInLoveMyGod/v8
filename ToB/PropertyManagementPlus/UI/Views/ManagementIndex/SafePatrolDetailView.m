//
//  SafePatrolDetailView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "SafePatrolDetailView.h"
#import "BaseTool.h"

#define Tag 7777
#define Choose @"Choose-Lesoft"

@interface SafePatrolDetailView ()

@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat lastWidth;
@end

@implementation SafePatrolDetailView

- (instancetype)initWithFrame:(CGRect)frame width:(CGFloat)width count:(NSInteger)count{
    if (self = [super initWithFrame:frame]) {
        self.count = count;
        self.width = width;
        [self addSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame lastWidth:(CGFloat)lastWidth count:(NSInteger)count {
    if (self = [super initWithFrame:frame]) {
        self.count = count;
        self.lastWidth = lastWidth;
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    
    CGFloat contentWidth = self.lastWidth > 0 ? self.lastWidth : self.width;
    CGFloat singleWidth = (kWidth - contentWidth)/(self.count - 1);
    
    for (int i = 0; i < self.count; i ++) {
        
        CGFloat start = self.lastWidth > 0 ? i * singleWidth : (i == 0 ? 0 : contentWidth + (i - 1) * singleWidth);
        
        CGFloat width = self.lastWidth > 0 ? (i == self.count - 1 ? contentWidth : singleWidth) :(i == 0 ? contentWidth : singleWidth);
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(start, 0, width, self.frame.size.height)];
        [self formateWithLabel:button];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [self addSubview:button];
        button.tag = i + 2000;
        
    }
}

- (void)formateWithLabel:(UIButton *)button {
    
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(safePatrolDetailButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
}

- (void)reloadWithTitles:(NSArray *)titles image:(NSString *)image colors:(NSArray *)colors{
    UIImage *myImage = [UIImage imageNamed:image];
    for (int i = 0; i < titles.count; i ++) {
        
        UIButton *button = [self viewWithTag:2000 + i];
        if (self.lastWidth > 0) {
            if (i == self.count - 1 && ![image isEqualToString:@""]) {
                NSString *imageName = @"";
                NSString *selectImageName = @"";
                if ([image isEqualToString:Choose]) {
                    imageName = @"unchecked";
                    selectImageName = @"checked";
                }
                [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
            } else {
                [button setTitle:titles[i] forState:UIControlStateNormal];
            }
        } else {
            
            if (i == 0 && myImage != nil) {
                NSString *imageName = @"";
                NSString *selectImageName = @"";
                if ([image isEqualToString:Choose]) {
                    imageName = @"unchecked";
                    selectImageName = @"checked";
                }
                [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
            } else {
                [button setTitle:titles[i] forState:UIControlStateNormal];
            }
        }
        
        [button setTitleColor:colors[i] forState:UIControlStateNormal];
        
    }
    
}

- (void)setSafePatrolDetailSelect:(NSInteger)safePatrolDetailSelect {
    UIButton *select = (UIButton *)[self viewWithTag:2000 + self.count - 1];
    [select setSelected: safePatrolDetailSelect];
}


#pragma mark - event response

- (void)safePatrolDetailButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(selectSafePatrolDetailViewItem:)]) {
        [self.delegate selectSafePatrolDetailViewItem:self.tag - 1000];
    }
}

@end
