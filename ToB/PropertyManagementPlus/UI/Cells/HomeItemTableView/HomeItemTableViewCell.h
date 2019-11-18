//
//  HomeItemTableViewCell.h
//  支付宝跟新demo
//
//  Created by wwt on 16/8/24.
//  Copyright © 2016年 zgy_smile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeItemViewIconButton.h"

@protocol HomeItemTableViewCellDelegate <NSObject>

- (void)clickItem:(NSString *)title;

@end

@interface HomeItemTableViewCell : UITableViewCell <HomeItemViewIconButtonDataSource>

@property (nonatomic, weak) id <HomeItemTableViewCellDelegate> delegate;

// type == 1 normal type == -1(更多功能)
- (instancetype)initWithFrame:(CGRect)frame lineNumber:(NSInteger)lineNumber roles:(NSMutableArray *)roles type:(NSInteger)type;

@end
