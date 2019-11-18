//
//  DetailDeviceVC.m
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/29.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import "DetailDeviceVC.h"
#import "FinishDeviceRepairVC.h"
#import "WGChooseLabCell.h"
#import "WYTextViewCell.h"
#import "DeviceItemModel.h"
#import "PropertyManagementPlus-Swift.h"
@interface DetailDeviceVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UILabel *contextLab;

@property (nonatomic,strong)UITableView *mytable;

@property (nonatomic,strong)UIView *bottomView;

@property (nonatomic,strong)NSMutableArray *dataSource;

@end

static NSString *chooseLabId = @"WGChooseLabCell";
static NSString *textViewId = @"WYTextViewCell";

@implementation DetailDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contextLab];
    [self.view addSubview:self.mytable];
    self.title = @"保养详情";
    NSString *str = self.planMemo;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    CGFloat height = rect.size.height;
    CGRect newRect = self.contextLab.frame;
    CGRect newTableRect = self.mytable.frame;
    
    newRect.size.height = height + 20;
    newTableRect.origin.y = CGRectGetMaxY(newRect) + 10;
    newTableRect.size.height = SCREENHEIGHT - (CGRectGetMaxY(newRect) + 10) - 50 - 64;
    self.contextLab.frame = newRect;
    self.contextLab.text = str;
    self.mytable.frame = newTableRect;
    
    [self.mytable registerNib:[UINib nibWithNibName:chooseLabId bundle:[NSBundle mainBundle]] forCellReuseIdentifier:chooseLabId];
    [self.mytable registerClass:NSClassFromString(textViewId) forCellReuseIdentifier:textViewId];
    
    [self requestData];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT -  - 64 - 50 - 128, SCREENWIDTH, 50)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    [self creatBottomView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 700, 300, 100)];
    [datePicker setDate:[NSDate date] animated:YES];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.view addSubview:datePicker];
}

- (void)creatBottomView {
    [[self.bottomView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.isFinish) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
        btn.backgroundColor = ThemeColor;
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:btn];
    }
    else {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, SCREENWIDTH/2.0 - 0.5, 50);
        btn.backgroundColor = ThemeColor;
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:btn];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextBtn.frame = CGRectMake(SCREENWIDTH/2.0 + 0.5, 0, SCREENWIDTH/2.0 - 0.5, 50);
        nextBtn.backgroundColor = ThemeColor;
        [nextBtn setTitle:@"完成保养" forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(finish:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:nextBtn];
    }
}

- (void)dateChanged:(UIDatePicker *)picker {
    NSLog(@"-- %@",picker.date);
}

- (void)back:(id)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finish:(id)btn {
    FinishDeviceRepairVC *vc = [[FinishDeviceRepairVC alloc] init];
    vc.baseUrl = self.baseUrl;
    vc.accountCode = self.accountCode;
    vc.upk = self.upk;
    vc.code = self.myId;
    vc.planMemo = self.planMemo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UILabel *)contextLab {
    if (!_contextLab) {
        _contextLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 20 , 1000)];
//        _contextLab.backgroundColor = [UIColor redColor];
        _contextLab.numberOfLines = 0;
    }
    return _contextLab;
}

- (UITableView *)mytable {
    if (!_mytable) {
        _mytable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:UITableViewStyleGrouped];
        _mytable.delegate = self;
        _mytable.dataSource = self;
        _mytable.estimatedSectionHeaderHeight = 10.0;
        _mytable.estimatedSectionFooterHeight = 10.0;
    }
    return _mytable;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DeviceItemModel *model = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld.%@",indexPath.row,model.content];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH , 44)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH, 44)];
    lab.text = @"完成情况";
    lab.textColor = [UIColor darkGrayColor];
    lab.font = [UIFont systemFontOfSize:18];
    [header addSubview:lab];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

#pragma mark - 服务器

- (void)requestData {
    GetDeviceRepairDetailCmd *getIndicatorsAPICmd = [[GetDeviceRepairDetailCmd alloc] init];
    getIndicatorsAPICmd.baseUrl = self.baseUrl;
    getIndicatorsAPICmd.parameters = [@{@"AccountCode":self.accountCode,@"BillCode":self.code,@"upk":self.upk,@"pageSize":@"30",@"pageIndex":@"1"} mutableCopy];
    [getIndicatorsAPICmd transactionWithSuccess:^(id _Nonnull response) {
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSDictionary *infosDic = response[@"infos"];
            NSArray *infosArr = infosDic[@"items"];
            for (NSDictionary *tempDic in infosArr) {
                DeviceItemModel *itemModel = [[DeviceItemModel alloc] init];
                [itemModel setValuesForKeysWithDictionary:tempDic];
                [self.dataSource addObject:itemModel];
            }
            [self.mytable reloadData];
            NSLog(@"-- %@",response);
        }
        else {
            [LocalToastView toastWithText:response[@"msg"]];
            
        }
    } failure:^(id _Nonnull error) {
        [LocalToastView toastWithText:@"服务器错误"];
    }];
}

@end
