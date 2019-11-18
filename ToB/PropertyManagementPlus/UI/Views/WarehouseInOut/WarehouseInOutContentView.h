//
//  WarehouseInOutContentView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WarehouseInOutDelegate <NSObject>

- (void)subTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)longPressWithIndex:(NSInteger)index;
@end

@interface WarehouseInOutContentView : UIView
@property (nonatomic, weak) id <WarehouseInOutDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)reloadDataWithDataSource:(NSMutableArray *)dataSource;
@end
