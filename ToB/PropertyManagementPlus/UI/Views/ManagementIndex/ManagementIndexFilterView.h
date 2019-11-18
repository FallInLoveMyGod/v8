//
//  ManagementIndexFilterView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManagementIndexFilterResultDelegate <NSObject>
- (void)selectFilterWithResultDict:(NSDictionary *)result;
@end

@interface ManagementIndexFilterView : UIView
@property (nonatomic, weak) id <ManagementIndexFilterResultDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type;
- (void)reloadData;
@end
