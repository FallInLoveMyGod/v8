//
//  ManagementIndexFilterButtonView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManagementIndexFilterDelegate <NSObject>

- (void)selectItemSection:(NSInteger)section index:(NSInteger)index;

@end

@interface ManagementIndexFilterButtonView : UIView
@property (nonatomic, weak) id <ManagementIndexFilterDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
+ (CGFloat)fetchCellHeightWithTitles:(NSArray *)titles width:(CGFloat)width;
- (void)reloadDataWithIndex:(NSInteger)index;
@end
