//
//  CustomerNavigationView.m
//  ToCZhuXY
//
//  Created by Mac on 2017/10/13.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "CustomerNavigationView.h"
#import "BaseTool.h"

@interface CustomerNavigationView()
@property (nonatomic, strong) UIView *customerView;
@end

@implementation CustomerNavigationView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = ThemeColor;
    }
    return self;
}

- (void)reloadWithTitle:(NSString *)title {
    [self removeSubView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, kWidth, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    self.customerView = titleLabel;
    [self addSubview:titleLabel];
}

- (void)reloadWithCustomerView:(UIView *)customerView {
    [self removeSubView];
    customerView.center = self.center;
    customerView.frame = CGRectMake(customerView.frame.origin.x, customerView.frame.origin.y + 10, customerView.frame.size.width, customerView.frame.size.height);
    self.customerView = customerView;
    [self addSubview:self.customerView];
}

- (void)removeSubView {
    self.backgroundColor = ThemeColor;
    [self.customerView removeFromSuperview];
}
@end
