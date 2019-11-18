//
//  WYTextViewCell.h
//  propertyservices
//
//  Created by 田耀琦 on 2018/1/15.
//  Copyright © 2018年 javajy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCustonTextView.h"
#import "CustomTextView.h"
@interface WYTextViewCell : UITableViewCell

@property (nonatomic,strong)MyCustonTextView *textV;

@property (nonatomic,strong)CustomTextView *textView;

@property (nonatomic,strong)UILabel *titleLab;


@end
