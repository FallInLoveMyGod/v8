//
//  DeviceRepairVC.m
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/24.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import "DeviceRepairVC.h"
#import "PropertyManagementPlus-Swift.h"
#import "DetailDeviceVC.h"
#import "DeviceRepairListModel.h"
static NSString *identify = @"RepairTaskTableViewCell";
static NSString *url = @"/CSService/GetDevicesCareList.ashx";
@interface DeviceRepairVC () <UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _pageIndex;
    NSInteger _pageSize;
}

@property (nonatomic, strong)UITableView *tableV;

@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation DeviceRepairVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备保养";
    [self creatUI];
    _pageSize = 30;
    _pageIndex = 1;
    [self requestData];
    
}

- (void)creatUI {
    [self.view addSubview:self.tableV];
    [self.tableV registerNib:[UINib nibWithNibName:identify bundle:[NSBundle mainBundle]] forCellReuseIdentifier:identify];
}

- (UITableView *)tableV {
    if (!_tableV) {
        _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) style:UITableViewStylePlain];
        _tableV.estimatedSectionHeaderHeight = 10.0;
//        _tableV.backgroundColor = [UIColor lightTextColor];
        _tableV.separatorColor = [UIColor clearColor];
        _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableV.delegate = self;
        _tableV.dataSource = self;
    }
    return _tableV;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceRepairListModel *model = self.dataSource[indexPath.section];
    RepairTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    cell.titleNameLabel.text = model.name;
    cell.addressLabel.text = model.code;
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ 至 %@",model.expectedBeginDate    ,model.expectedEndDate];
    cell.contentLabel.text = model.planMemo;
    if ([model.isFinish intValue] != 1) {
        cell.stateLabel.text = @"未完成";
        cell.stateLabel.textColor = [UIColor redColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceRepairListModel *model = self.dataSource[indexPath.section];
    DetailDeviceVC *vc = [[DetailDeviceVC alloc] init];
    vc.baseUrl = self.baseUrl;
    vc.accountCode = self.accountCode;
    vc.upk = self.upk;
    vc.code = model.code;
    vc.myId = model.myId;
    vc.isFinish = [model.isFinish boolValue];
    vc.planMemo = model.planMemo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 109;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

#pragma mark - 服务器 // GetDeviceRepairCmd
- (void)requestData {
    GetDeviceRepairCmd *getIndicatorsAPICmd = [[GetDeviceRepairCmd alloc] init];
    getIndicatorsAPICmd.baseUrl = self.baseUrl;
    getIndicatorsAPICmd.parameters = [@{@"AccountCode":self.accountCode,@"upk":self.upk,@"type":self.type,@"pageSize":@"30",@"pageIndex":@"1"} mutableCopy];
    [getIndicatorsAPICmd transactionWithSuccess:^(id _Nonnull response) {
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSArray *arr = response[@"infos"];
            if (_pageIndex == 1) {
                [self.dataSource removeAllObjects];
            }
            for (NSDictionary *dict in arr) {
                DeviceRepairListModel *model = [[DeviceRepairListModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [self.dataSource addObject:model];
            }
            [self.tableV reloadData];
        }
        else {
            [LocalToastView toastWithText:response[@"msg"]];
            
        }
    } failure:^(id _Nonnull error) {
        [LocalToastView toastWithText:@"服务器错误"];
    }];
}

@end
