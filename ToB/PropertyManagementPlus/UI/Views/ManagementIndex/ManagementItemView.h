//
//  ManagementItemView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManagementItemViewDelegate <NSObject>
- (void)selectManagementItemViewItem:(NSInteger)tag;
@end

@interface ManagementItemView : UIView
@property (nonatomic, weak) id <ManagementItemViewDelegate> delegate;
@property (nonatomic, assign) NSInteger managementItemSelect;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles width:(CGFloat)width;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles lastItemWidth:(CGFloat)lastItemWidth;
@end
