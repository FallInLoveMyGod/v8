//
//  WGChooseLabCell.h
//  property_v9
//
//  Created by 田耀琦 on 2018/5/13.
//  Copyright © 2018年 田耀琦. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BLOCK)(void);
@interface WGChooseLabCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (nonatomic, copy) BLOCK chooseContent;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;


@end
