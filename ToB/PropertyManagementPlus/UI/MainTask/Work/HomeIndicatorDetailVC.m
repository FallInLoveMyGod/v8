//
//  HomeIndicatorDetailVC.m
//  PropertyManagementPlus
//
//  Created by 上海乐软信息科技有限公司 on 2018/4/13.
//  Copyright © 2018年 Lesoft. All rights reserved.
//

#import "HomeIndicatorDetailVC.h"
#import "SCChart.h"
#import "PropertyManagementPlus-Swift.h"
@interface HomeIndicatorDetailVC () <SCChartDataSource>

@property (nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation HomeIndicatorDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor ];
    [self initNav];
    [self requestData];
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self forceOrientationLandscape];
    //设置屏幕的转向为竖屏
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self forceOrientationPortrait];
    //设置屏幕的转向为竖屏
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)creatUI {
//    SCChart *chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(10, (self.view.frame.size.height - 300) / 2.0, [UIScreen mainScreen].bounds.size.width - 20, 350 )
//                                                        withSource:self
//                                                         withStyle:SCChartBarStyle];
    SCChart *chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(10, 44, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 60)
                                                        withSource:self
                                                         withStyle:SCChartBarStyle];
    [chartView showInView:self.view];
}

- (void)initNav {
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 44)];
    navView.backgroundColor = [UIColor colorWithRed:0.0 green:168/255.0 blue:234/255.0 alpha:1.0];
    [self.view addSubview:navView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"ic_after_pressed.png"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(15, 0, 44, 44)];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLab  =  [[UILabel alloc] initWithFrame:CGRectMake(65, 0, [UIScreen mainScreen].bounds.size.height - 130, 44)];
    titleLab.text = @"统计数据";
    titleLab.font = [UIFont fontWithName:@".PingFangSC-Medium" size:18];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLab];
}

#pragma mark - 服务器
- (void)requestData {
    GetIndicatorsAPICmd *getIndicatorsAPICmd = [[GetIndicatorsAPICmd alloc] init];
    getIndicatorsAPICmd.baseUrl = self.baseUrl;
    getIndicatorsAPICmd.parameters = [@{@"AccountCode":self.accountCode,@"upk":self.upk,@"panelType":self.panelType,@"tag":@(self.clickIndex)} mutableCopy];
    [getIndicatorsAPICmd transactionWithSuccess:^(id _Nonnull response) {
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSArray *dataArr = response[@"infos"];
            NSDictionary *dataDic = dataArr[0];
            for (NSDictionary *tempDic in dataDic[@"viewDate"]) {
                IndicateModel *model = [[IndicateModel alloc] init];
                [model setValuesForKeysWithDictionary:tempDic];
                [self.dataSource addObject:model];
            }
            self.title = @"可租面积（）";
            [self creatUI];
        }else {
            [LocalToastView toastWithText:response[@"msg"]];
        }
    } failure:^(id _Nonnull response) {
        
    }];
}

#pragma mark - SCChartDataSource
#pragma mark - @required
//横坐标标题数组
- (NSArray *)SCChart_xLableArray:(SCChart *)chart {
    return [self getXTitles:self.dataSource.count];
}

//数值多重数组
- (NSArray *)SCChart_yValueArray:(SCChart *)chart {
    
    NSMutableArray *data = [NSMutableArray array];
    for (IndicateModel *model in self.dataSource) {
        //        NSArray *arr = @[@([model.date intValue])];
        [data addObject:@([model.date intValue])];
    }
    return @[data];
    
}

#pragma mark - @optional
//颜色数组
//- (NSArray *)SCChart_ColorArray:(SCChart *)chart {
//    UIColor *color = [UIColor colorWithRed:arc4random_uniform(100) / 255.0   green:arc4random_uniform(100) / 255.0 blue:arc4random_uniform(100) / 255.0 alpha:1.0];
//    return @[[UIColor redColor]];
//}

//标记数值区域
- (CGRange)SCChartMarkRangeInLineChart:(SCChart *)chart {
    return CGRangeZero;
}


#pragma mark - Method
- (NSArray *)getXTitles:(int)num {
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        IndicateModel *model = self.dataSource[i];
        NSString * str = [NSString stringWithFormat:@"%@",model.label];
        [xTitles addObject:str];
    }
    return xTitles;
}

- (void)forceChangeOrientation:(UIInterfaceOrientation)orientation
{
    int val = orientation;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

//强制横屏
- (void)forceOrientationLandscape{
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}

//强制竖屏
- (void)forceOrientationPortrait{
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=NO;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}

#pragma mark - setter && getter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - Handle Action
- (void)back:(id)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
