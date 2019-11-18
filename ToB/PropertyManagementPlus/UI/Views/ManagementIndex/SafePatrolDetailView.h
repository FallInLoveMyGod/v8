//
//  SafePatrolDetailView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SafePatrolDetailViewDelegate <NSObject>
- (void)selectSafePatrolDetailViewItem:(NSInteger)tag;
@end

@interface SafePatrolDetailView : UIView
@property (nonatomic, weak) id <SafePatrolDetailViewDelegate> delegate;
@property (nonatomic, assign) NSInteger safePatrolDetailSelect;
- (instancetype)initWithFrame:(CGRect)frame width:(CGFloat)width count:(NSInteger)count;
- (instancetype)initWithFrame:(CGRect)frame lastWidth:(CGFloat)lastWidth count:(NSInteger)count;
- (void)reloadWithTitles:(NSArray *)titles image:(NSString *)image colors:(NSArray *)colors;
@end
