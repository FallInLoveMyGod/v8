//
//  HomeIndicatorDetailVC.h
//  PropertyManagementPlus
//
//  Created by 上海乐软信息科技有限公司 on 2018/4/13.
//  Copyright © 2018年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeIndicatorDetailVC : UIViewController

@property (nonatomic,assign)NSInteger clickIndex;  //  点击的tag

@property (nonatomic,strong)NSString *baseUrl;

@property (nonatomic,strong)NSString *upk;

@property (nonatomic,strong)NSString *accountCode;

@property (nonatomic,strong)NSString *panelType;

@end
