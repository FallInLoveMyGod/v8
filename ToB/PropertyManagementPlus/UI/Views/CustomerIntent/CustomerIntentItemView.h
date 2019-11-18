//
//  CustomerIntentItemView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/2.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomerIntentItemView;
@protocol CustomerIntentItemViewDelegate <NSObject>
- (void)buttonItemClick:(UIButton *)sender intentView:(CustomerIntentItemView *)intentView;
@end

@interface CustomerIntentItemView : UIView
@property (nonatomic, weak) id <CustomerIntentItemViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles icons:(NSArray *)icons;
@end
