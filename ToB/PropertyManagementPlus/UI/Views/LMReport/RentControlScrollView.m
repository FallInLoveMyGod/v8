//
//  RentControlScrollView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "RentControlScrollView.h"
#import "BaseTool.h"

#define SCREEN_BOUND_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_BOUND_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface SingleLabel : UIView
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;
@end

@implementation SingleLabel

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    if (self = [super initWithFrame:frame]) {
        
        NSInteger position = 0;
        for (int i = 0; i < title.length; i ++) {
            NSString *temp = [title substringWithRange:NSMakeRange(i, 1)];
            if ([temp isEqualToString:@"0"]
                || [temp isEqualToString:@"1"]
                || [temp isEqualToString:@"2"]
                || [temp isEqualToString:@"3"]
                || [temp isEqualToString:@"4"]
                || [temp isEqualToString:@"5"]
                || [temp isEqualToString:@"6"]
                || [temp isEqualToString:@"7"]
                || [temp isEqualToString:@"8"]
                || [temp isEqualToString:@"9"]) {
                position = i;
                break;
            }
            
        }
        
        NSString *titleName = [title substringToIndex:position];
        NSString *data = [title substringFromIndex:position];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, frame.size.height/2 - 10)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = titleName;
        [self addSubview:titleLabel];
        
        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, frame.size.height/2 - 10)];
        dataLabel.font = [UIFont systemFontOfSize:16];
        dataLabel.textAlignment = NSTextAlignmentCenter;
        dataLabel.text = data;
        [self addSubview:dataLabel];
    }
    return self;
}

@end

@interface RentControlScrollView ()

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, copy) NSArray *titles;
@end

@implementation RentControlScrollView

- (instancetype)initWithFrame:(CGRect)frame titles:(id)titles {
    
    if (self = [super initWithFrame:frame]) {
        
        self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.contentScrollView.scrollEnabled = YES;
        [self addSubview:self.contentScrollView];
        self.titles = [NSArray arrayWithArray:titles];
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    CGFloat width = SCREEN_BOUND_WIDTH / 3.0;
    
    for (int i = 0; i < _titles.count; i ++) {
        NSDictionary *dict = (NSDictionary *)self.titles[i];
        SingleLabel *view = [[SingleLabel alloc] initWithFrame:CGRectMake(i * width, 0, width, self.frame.size.height) title:dict[@"StateTxt"]];
        view.backgroundColor = [self fetchColorWithTitle:dict[@"StateColor"]];
        [self.contentScrollView addSubview:view];
    }
    
    self.contentScrollView.contentSize = CGSizeMake(width * _titles.count, self.frame.size.height);
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
}

- (UIColor *)fetchColorWithTitle:(NSString *)title {
    return [BaseTool colorWithHexString:title];
}

@end
