//
//  RepairChooseSenderViewController.h
//  单元格的操作
//
//  Created by zhaohe on 16/4/7.
//  Copyright © 2016年 com.MrHe.Mission. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "RepairChooseSenderViewController.h"
#import <Alamofire/Alamofire-Swift.h>
#import <HandyJSON/HandyJSON-Swift.h>

@interface RepairChooseSenderViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *gameTableView;
/** 底部删除按钮 */
@property (nonatomic ,strong) UIButton *deleteButton;
/** 数据源 */
@property (nonatomic ,copy) NSMutableArray *workerArray;
/** 标记是否全选 */
@property (nonatomic ,assign) BOOL isAllSelected;

@property (nonatomic ,strong) NSMutableDictionary *requestDictionary;
@property (nonatomic ,strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSMutableDictionary *executorsDictionary;

@end

@implementation RepairChooseSenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _requestDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    _workerArray = [[NSMutableArray alloc] initWithCapacity:20];
    _selectArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    if ([_chooseType isEqualToString:@"11"]) {
        self.title = @"选择上报人员";
    }else if ([_chooseType isEqualToString:@"1"]) {
        self.title = @"选择处理人";
    }else {
        self.title = @"选择派单员";
    }
    
    self.gameTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)];
    self.gameTableView.delegate = self;
    self.gameTableView.dataSource = self;
    self.gameTableView.tableFooterView = [[UIView alloc] init];
    self.gameTableView.backgroundColor = [UIColor whiteColor];
    self.gameTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.gameTableView];
    
    /*=========================至关重要============================*/
    
    self.gameTableView.allowsMultipleSelectionDuringEditing = YES;
    self.gameTableView.editing = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    [self edit];
    
    UIColor *titleColor = [UIColor whiteColor];
    UIColor *backgroundColor = [UIColor colorWithRed:38.0/255.0 green:143.0/255.0 blue:232.0/255.0 alpha:1.0];
    
    /** 底部删除按钮 */
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:@"取消" forState:UIControlStateNormal];
    [deleteButton setTitleColor:titleColor forState:UIControlStateNormal];
    [deleteButton setBackgroundColor:backgroundColor];
    [deleteButton setFrame:CGRectMake(0, self.view.frame.size.height - 64 - 50, self.view.frame.size.width/2, 50)];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
    deleteButton.layer.borderWidth = 0.5;
    deleteButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [deleteButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
    /** 底部确定按钮 */
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:titleColor forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:backgroundColor];
    [confirmButton setFrame:CGRectMake(deleteButton.frame.size.width, self.view.frame.size.height - 64 - 50, self.view.frame.size.width/2, 50)];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    confirmButton.layer.borderWidth = 0.5;
    confirmButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [confirmButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    [self requestData];
    
}

-(void)edit {
    
    /** 每次点击 rightBarButtonItem 都要取消全选 */
    
    self.isAllSelected = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(selectAll)];
    
}

- (void)back {
    
    if ([self.delegate respondsToSelector:@selector(popAction:)]) {
        [self.delegate popAction:@"fail"];
    }
    else  {
        if ([self.delegate respondsToSelector:@selector(popAction:message:)]) {
            [self.delegate popAction:@"fail" message:@""];
        }
    }
}

- (void)commitDirect {
    
    ReportedEventAPICmd *request = [[ReportedEventAPICmd alloc] init];
    request.baseUrl = self.baseUrl;
    request.parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.accountCode,@"AccountCode",self.upk,@"upk",self.eventCode,@"code",self.updataType,@"type",@[],@"persons", nil];
    
    [request transactionWithSuccess:^(id _Nonnull response) {
        
        if ([response[@"result"] isEqualToString:@"success"]) {
            
            if ([self.delegate respondsToSelector:@selector(popCurrentPageAction:)]) {
                [self.delegate popCurrentPageAction:response[@"result"]];
            }
            
        }else {
            [LocalToastView toastWithText:response[@"msg"]];
        }
        
    } failure:^(id _Nonnull response) {
        
    }];
}

- (void)commit {
    
    if ([_chooseType isEqualToString:@"11"]) {
        //上报ReportedEventAPICmd
        
        NSMutableArray *persons = [NSMutableArray arrayWithCapacity:20];
        
        for (NSString *key in _selectArray) {
            [persons addObject:self.workerArray[[key intValue]]];
        }
        
        ReportedEventAPICmd *request = [[ReportedEventAPICmd alloc] init];
        request.baseUrl = self.baseUrl;
        request.parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.accountCode,@"AccountCode",self.upk,@"upk",self.eventCode,@"code",self.updataType,@"type",[BaseTool toJson:persons],@"persons", nil];
        
        [request transactionWithSuccess:^(id _Nonnull response) {
            
            if ([response[@"result"] isEqualToString:@"success"]) {
                
                if ([self.delegate respondsToSelector:@selector(popAction:)]) {
                    [self.delegate popAction:response[@"result"]];
                }
                
            }else {
                [LocalToastView toastWithText:response[@"msg"]];
            }
            
            [self.gameTableView reloadData];
            
        } failure:^(id _Nonnull response) {
            
        }];
        
        return;
    }
    
    NSMutableDictionary *sendRepareTaskDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    sendRepareTaskDictionary[@"AccountCode"] = self.accountCode;
    sendRepareTaskDictionary[@"upk"] = self.upk;
    sendRepareTaskDictionary[@"billCode"] = self.billCode;
    
    if ([_chooseType isEqualToString:@"1"]) {
        
    }else {
        sendRepareTaskDictionary[@"pushMSG"] = @"true";
        sendRepareTaskDictionary[@"acceptSrcTask"] = @"true";
    }
    
    if ([_chooseType isEqualToString:@"3"]) {
        //发起抢单
        sendRepareTaskDictionary[@"executors"] = _executorsDictionary[@"executors"];
        
    }else {
        
        NSMutableString *content = [NSMutableString string];
        
        NSInteger i = 0;
        
        if (self.isAllSelected) {
            //全选
            
            for (int i = 0; i < _workerArray.count; i ++) {
                
                NSDictionary *temp = _workerArray[i];
                [content appendString:temp[@"workerid"]];
                
                if (i != _selectArray.count - 1) {
                    [content appendString:@","];
                }
            }
            
        }else {
            for (NSString *index in _selectArray) {
                
                NSDictionary *temp = _workerArray[[index intValue]];
                [content appendString:temp[@"workerid"]];
                
                if (i != _selectArray.count - 1) {
                    [content appendString:@","];
                }
                
                i ++;
            }
        }
        
        if ([content isEqualToString:@""]) {
            [LocalToastView toastWithText:@"没有选择任何内容!"];
            return;
        }
        
        sendRepareTaskDictionary[@"executors"] = content;
    }
    
    if (_chooseType == nil) {
        // 客服联系单转维修
        sendRepareTaskDictionary[@"taskType"] = @"0";
    }
    
    if ([self.chooseTitle containsString:@"抢单"]) {
        sendRepareTaskDictionary[@"taskType"] = @"2";
    }else if ([self.chooseTitle containsString:@"派单"]) {
        sendRepareTaskDictionary[@"taskType"] = @"0";
    }else if ([self.chooseTitle containsString:@"维修"]) {
        sendRepareTaskDictionary[@"taskType"] = @"1";
    }else if ([self.chooseTitle containsString:@"回访"] ) {
        sendRepareTaskDictionary[@"taskType"] = @"3";
    }
    
    
    if ([_chooseType isEqualToString:@"1"] ) {
        sendRepareTaskDictionary[@"taskType"] = @"0";
    }else if ([_chooseType isEqualToString:@"2"] ) {
        sendRepareTaskDictionary[@"taskType"] = @"1";
    }else if ([_chooseType isEqualToString:@"3"]) {
        //发起抢单
        sendRepareTaskDictionary[@"taskType"] = @"2";
    }else if ([_chooseType isEqualToString:@"4"]){
        sendRepareTaskDictionary[@"taskType"] = @"3";
        if ([self.chooseTitle containsString:@"检验"]) {
            sendRepareTaskDictionary[@"taskType"] = @"4";
        }
    }
    
    if ([self.chooseTitle containsString:@"回访投诉单"]) {
        sendRepareTaskDictionary[@"taskType"] = @"1";
    }
    
//    SendRepareTaskAPICmd *request = [[SendRepareTaskAPICmd alloc] init];
//
//    if ([_chooseType isEqualToString:@"1"]) {
//        request = [[SendComplaintTaskAPICmd alloc] init];
//
//    }
//    request.parameters = sendRepareTaskDictionary;
//    request.baseUrl = self.baseUrl;
//    return;
    XYCBaseRequest *request ;
    
    if ([_chooseType isEqualToString:@"1"]) {
        request = [[SendComplaintTaskAPICmd alloc] init];
    }
    else {
        request = [[SendRepareTaskAPICmd alloc] init];
    }
    request.parameters = sendRepareTaskDictionary;
    request.baseUrl = self.baseUrl;
    [request transactionWithSuccess:^(id _Nonnull response) {
        
        LocalToastView *toast = [[LocalToastView alloc] init];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        if ([response[@"result"] isEqualToString:@"success"]) {
            
            if ([_chooseType isEqualToString:@"1"]) {
                [toast toastOCWithText:@"派送成功"];
            }else {
                [toast toastOCWithText:[NSString stringWithFormat:@"%@成功",self.chooseTitle]];
            }
            
            if ([self.delegate respondsToSelector:@selector(changeState:pk:)]) {
                [self.delegate changeState:@"NoDeal" pk:_pk];
            }
            
        }else {
            if ([_chooseType isEqualToString:@"1"]) {
                [toast toastOCWithText:response[@"msg"]];
            }else {
                [toast toastOCWithText:[NSString stringWithFormat:@"%@失败",self.chooseTitle]];
            }
            
        }
        
        if ([self.delegate respondsToSelector:@selector(popAction:)]) {
            [self.delegate popAction:response[@"result"]];
        }

        [self.gameTableView reloadData];
        
    } failure:^(id _Nonnull response) {
        if ([self.delegate respondsToSelector:@selector(popAction:)]) {
            [self.delegate popAction:@"fail"];
        }
    }];
    
}

- (void)requestData{
    
    if ([_chooseType isEqualToString:@"11"]) {
        
        GetContactFormInfoGetReceiverAPICmd *request = [[GetContactFormInfoGetReceiverAPICmd alloc] init];
        request.baseUrl = self.baseUrl;
        request.parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.accountCode,@"AccountCode",self.upk,@"upk",self.LineState,@"type", nil];
        
        [request transactionWithSuccess:^(id _Nonnull response) {
            
            if ([response[@"result"] isEqualToString:@"success"]) {
                self.workerArray = response[@"infos"];
            }else {
                [LocalToastView toastWithText:response[@"msg"]];
            }
            
            [self.gameTableView reloadData];
            
        } failure:^(id _Nonnull response) {
            
        }];
        
        return;
    }
    
    if ([_chooseType isEqualToString:@"3"]) {
        _requestDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
        _workerArray = [[NSMutableArray alloc] initWithCapacity:20];
        _selectArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    
    _requestDictionary[@"AccountCode"] = self.accountCode;
    _requestDictionary[@"upk"] = self.upk;
    _requestDictionary[@"billCode"] = self.billCode;
    _requestDictionary[@"LineState"] = self.LineState;
    
    if ([self.chooseTitle containsString:@"抢单"]) {
        _requestDictionary[@"RightName"] = @"APP中接收维修单";
    }else if ([self.chooseTitle containsString:@"维修"]) {
        _requestDictionary[@"RightName"] = @"APP中接收维修单";
    }else if ([self.chooseTitle containsString:@"派单"]) {
        _requestDictionary[@"RightName"] = @"APP中分派维修单";
    }
    else if ([self.chooseTitle containsString:@"回访"] ){
        _requestDictionary[@"RightName"] = @"APP中回访维修单";
    }
    else if ([self.chooseTitle containsString:@"检验"]) {
        _requestDictionary[@"RightName"] = @"APP中检验维修单";
    }
    
    if ([_chooseType isEqualToString:@"1"]) {
        _requestDictionary[@"RightName"] = @"APP中处理投诉单";
        if ([_chooseTitle containsString:@"回访投诉单"]) {
            _requestDictionary[@"RightName"] = @"APP中回访投诉单";
        }
    }
    
    XYCBaseRequest *request;
//    GetRightUserListAPICmd *request = [[GetRightUserListAPICmd alloc] init];
    if ([self.chooseTitle containsString:@"抢单"]) {
        request = [[GetRightUsersAPICmd alloc] init];
    }
    else {
        request = [[GetRightUserListAPICmd alloc] init];
    }
    request.baseUrl = self.baseUrl;
    request.parameters = _requestDictionary;
    [request transactionWithSuccess:^(id _Nonnull response) {
        
        if ([response[@"result"] isEqualToString:@"success"]) {
            
            if ([_chooseType isEqualToString:@"3"]) {
                //发起抢单
                
                _executorsDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
                
                _executorsDictionary[@"executors"] = response[@"excutors"];
                
                [self commit];
                
            }else {
                if ([response[@"users"] count] == 0) {
                    
                    if ([self.delegate respondsToSelector:@selector(popAction:message:)]) {
                        [self.delegate popAction:@"fail" message:@"没有查询到处理人"];
                    }
                    
                }else {
                    for (NSDictionary *tempDict in response[@"users"]) {
                        [_workerArray addObject:tempDict];
                    }
                }
            }
            
        }else {
            
            if ([self.delegate respondsToSelector:@selector(popAction:message:)]) {
                [self.delegate popAction:@"fail" message:response[@"msg"]];
            }
        }
        
        [self.gameTableView reloadData];
        
    } failure:^(id _Nonnull response) {
        
    }];
    
}

#pragma mark - 全选删除
-(void)selectAll
{
    self.isAllSelected = !self.isAllSelected;
    
    for (int i = 0; i<self.workerArray.count; i++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        if (self.isAllSelected) {
            [self.gameTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }else{//反选
            
            [self.gameTableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifi = @"gameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifi];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifi];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    NSDictionary *tempDict = self.workerArray[indexPath.row];
    if ([_chooseType isEqualToString:@"11"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",tempDict[@"pname"]];
    }else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",tempDict[@"workerid"]];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

#pragma mark - UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"点击了第%zd行",indexPath.row);
    
    NSString *selectStr = [NSString stringWithFormat:@"%d",indexPath.row];
    
    if ([_selectArray containsObject:selectStr]) {
        [_selectArray removeObject:selectStr];
    }else {
        [_selectArray addObject:selectStr];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

@end
