//
//  RentControlTipView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RentControlTipView : UIView
@property (nonatomic, strong) UILabel *topTipLabel;
@property (nonatomic, strong) UILabel *bottomTipLabel;
- (instancetype)initWithFrame:(CGRect)frame;
@end
