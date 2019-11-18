//
//  ChatViewController.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/7/28.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "ChatViewRoomController.h"
#import "NSString+Extension.h"
#import "UIViewExt.h"
#import "RegexKitLite.h"
#import "NSString+Extension.h"
#import "ChatViewRoomController+ChatViewRoom.h"
#import <YYModel/YYModel.h>

@interface ChatViewRoomController ()<UITableViewDataSource, UITableViewDelegate,ChatInputBarDelegate,MessageCellDelegate>
{
    UIAlertView *_dismissAlertView;
}

@property (nonatomic, copy) NSMutableArray *reSendMessageArray;
/// 发送时 messageId 和 Model 对应
@property (nonatomic, copy) NSMutableDictionary *sendMessageDict;
/// 判断是否是自己发送的消息
@property (nonatomic, copy) NSMutableDictionary *isSelfSendmessageDict;
/// 记录该用户的userId
@property (nonatomic, copy) NSString *userId;
/// 记录最上面的一条消息的messageId 以备从服务器拉取数据
@property (nonatomic, copy) NSString *fetchUserMessageId;
/// 记录最上面的一条消息的messageTime 以备从本地DB拉取数据
@property (nonatomic, copy) NSString *fetchUserMessageTime;
/// 记录重新发送的Model
@property (nonatomic, strong) MessageModel *reSendMessageModel;
/// 记录更多消息最上面的一条
@property (nonatomic, strong) MessageModel *moreMessageModelFirst;
/// 标识本地DB的历史消息是否已经拉取完成
@property (nonatomic, assign) BOOL isLocalHistoryMessageOver;
/// 记录是否第一次拉取完成数据，以便tableView最后一条数据能展示出来
/// 1:本地拉取数据20条 2:去服务器拉取数据 3:第一次拉取完成 4:断网后重新拉取消息
@property (nonatomic, assign) NSInteger isFirstLoadMessage;
/// 拉取数据的数量
@property (nonatomic, assign) NSInteger fetchDataNumber;
/// 是否被删除
@property (nonatomic, assign) BOOL isDelete;
/// 是否连接成功
@property (nonatomic, assign) BOOL isConnect;
///  是否下拉刷新
@property (nonatomic, assign) BOOL isGetMsgPullDownLoad;

@property (nonatomic, strong) NSDictionary *loginInfo;
@property (nonatomic, strong) NSDictionary *clientInfo;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) GetLinkBillMSGList *getLinkBillMSGList;
@property (nonatomic, strong) SendLinkBillMSG *sendLinkBillMSG;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchEndEidt:(id)sender;


@end

@implementation ChatViewRoomController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configData];
    [self configUI];
    [self requestMassageList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ////////////去掉导航栏最下面那条线///////////////
    //[self configNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
    [_dismissAlertView dismissWithClickedButtonIndex:0 animated:NO];
    [self readMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
#pragma mark viewDidLoad methods
- (void)configData
{
    ////////////注册通知///////////////
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _loginInfo = [BaseTool dictionaryWithJsonString:[[LocalStoreData userDefault] objectForKey:[LocalStoreData LoginInfoKey]]];
    _clientInfo = [BaseTool dictionaryWithJsonString:[[LocalStoreData userDefault] objectForKey:[LocalStoreData ClientInfoKey]]];
    _userInfo = [BaseTool dictionaryWithJsonString:[[LocalStoreData userDefault] objectForKey:[LocalStoreData UserInfoKey]]];

    ////////////初始化数组///////////////
    _sendMessageDict       = [[NSMutableDictionary alloc] init];
    _isSelfSendmessageDict = [[NSMutableDictionary alloc] init];
    _reSendMessageArray    = [[NSMutableArray alloc] init];
    _messageDataModelArray = [[NSMutableArray alloc] init];
    ////////////初始化变量///////////////
    _userId  = @"";
    _fetchDataNumber = kFetchMessageNumber;
    
    self.isConnect = YES;
    
//    self.isDelete = YES;
    
    //[self.getMembersAPICmd loadData];
    ////////////载入消息///////////////
    [self loadNewData];
}
- (void)configUI
{
//    self.view.backgroundColor = [UIColor greenColor];
    NSDictionary *dict = [NSDictionary dictionary];
    
    ////////////创建 导航栏右边Item///////////////
    [self configNavigationBarItemWithActions:@[@"gotoBack",@"chatInfoAction"]];
    ////////////配置 导航栏title///////////////
    [self configNavigationBarWithTitles:@[@"沟通记录"]];
    ////////////创建 申请状态View///////////////
//    [self.applicationStatusView updateAplicationStatusText:@""];
    ////////////调整tableView frame///////////////
    [self configTableViewWithTapAction:@"tapKeyEvent"];
    /**
     *  addsubViews 
     *  applicationStatusView、disconnectTipLabel、moreMessageView、chatInputBar
     **/
    [self addSubViewsWithInfo:dict];
    ////////////配置下拉刷新///////////////
    [self addHeaderRefreshWithAction:@"loadNewData"];
    
//    self.moreMessageView.hidden = YES;
    [self disconnectViewHide:self.isConnect];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)requestSendMassage:(NSString *)chartInfo {
    
    [LoadView setStoreLabelText:@"正在发送信息"];
    
    self.sendLinkBillMSG.loadView = [[LoadView alloc] init];
    self.sendLinkBillMSG.loadParentView = self.navigationController.view;
    self.sendLinkBillMSG.baseUrl = _clientInfo[@"PMSAddress"];
    self.sendLinkBillMSG.parameters = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:_loginInfo[@"accountCode"],@"AccountCode",self.billcode,@"billcode",_userInfo[@"upk"],@"upk",chartInfo,@"ChartInfo", nil]];
    
    __weak typeof(self) weaSelf = self;
    [self.sendLinkBillMSG transactionWithSuccess:^(id _Nonnull successData) {
        if ([successData[@"result"] isEqualToString:@"fail"]) {
            [LocalToastView toastWithText:successData[@"msg"]];
        }else {
            weaSelf.chatInputBar.inputTextView.text = @"";
            weaSelf.chatInputBar.inputPlaceholder.hidden = NO;
        }
        [weaSelf requestMassageList];
    } failure:^(id _Nonnull failError) {
    
    }];
}

- (void)delay {
    if (_messageDataModelArray.count > 0) {
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_messageDataModelArray.count inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    self.tableView.hidden = NO;
}

- (NSString *)dealWithTime:(NSString *)time {
    
    NSMutableArray *timeFore = [NSMutableArray arrayWithArray:[time componentsSeparatedByString:@" "]];
    NSMutableArray *times = [NSMutableArray arrayWithArray:[timeFore[1] componentsSeparatedByString:@":"]];
    [times removeLastObject];
    NSString *timeNext = [NSString stringWithFormat:@"%@ %@",timeFore[0],[times componentsJoinedByString:@":"]];
    return timeNext;
}

- (void)requestMassageList {
    
    self.getLinkBillMSGList.loadView = [[LoadView alloc] init];
    self.getLinkBillMSGList.baseUrl = _clientInfo[@"PMSAddress"];
    self.getLinkBillMSGList.parameters = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:_loginInfo[@"accountCode"],@"AccountCode",self.billcode,@"billcode", nil]];
    self.getLinkBillMSGList.loadParentView = self.view;
    
    __weak typeof(self) weaSelf = self;
    [self.getLinkBillMSGList transactionWithSuccess:^(id _Nonnull successData) {
        
        if ([successData[@"result"] isEqualToString:@"success"]) {
            
            [weaSelf refreshTableView];
            NSArray *sortList = [[NSArray alloc] initWithArray:successData[@"list"]];
            sortList = [sortList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSDictionary *first = (NSDictionary *)obj1;
                NSDictionary *second = (NSDictionary *)obj2;
                return [[BaseTool dealFormateDate:first[@"CreateTime"] seperate:@"/"] compare:[BaseTool dealFormateDate:second[@"CreateTime"] seperate:@"/"]];
            }];
            
            NSString *time = @"";
            
            for (NSDictionary *tempDict in sortList) {
                NSMutableDictionary *modelDict = [[NSMutableDictionary alloc] init];
                
                modelDict[@"content"] = tempDict[@"Content"];
                modelDict[@"time"] = tempDict[@"CreateTime"];
                modelDict[@"type"] = tempDict[@"Type"];
                modelDict[@"personName"] = tempDict[@"SendUser"];
                
                NSString *timeNext = [self dealWithTime:tempDict[@"CreateTime"]];
                
                if (![time isEqualToString:@""] && ![time isEqualToString:timeNext]) {
                    MessageModel *model = [MessageModel parseNotifyData:modelDict modelType:MessageModelTypeMe];
                    model.messageType = MessageTypeTime;
                    [weaSelf.messageDataModelArray addObject:model];
                }
                
                time = [self dealWithTime:tempDict[@"CreateTime"]];
                
                MessageModel *model = nil;
                if ([tempDict[@"Type"] intValue] == 0) {
                    model = [MessageModel parseNotifyData:modelDict modelType:MessageModelTypeMe];
                }else {
                    model = [MessageModel parseNotifyData:modelDict modelType:MessageModelTypeOther];
                }
                
                [weaSelf.messageDataModelArray addObject:model];
            }
            [weaSelf.tableView zj_stopHeaderAnimation];
            weaSelf.tableView.hidden = YES;
            [weaSelf.tableView reloadData];
            [weaSelf performSelector:@selector(delay) withObject:nil afterDelay:0.1];
        }
        
    } failure:^(id _Nonnull failError) {
        
    }];
}

- (void)refreshTableView {
    _isLocalHistoryMessageOver = NO;
    [_messageDataModelArray removeAllObjects];
    [self.tableView reloadData];
    _fetchUserMessageTime = nil;
    _isFirstLoadMessage = 2;
    [self loadNewData];
}

#pragma mark - System Delegate
#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isDelete) {
        return 1;
    } else {
        if (_messageDataModelArray.count != 0) {
            return _messageDataModelArray.count + 1;
        } else {
            return _messageDataModelArray.count;
        }
    }
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = nil;
    if (self.isDelete) {
        self.chatInputBar.isCanSendMessage = NO;
        self.moreMessageView.hidden = YES;
        self.tableView.scrollEnabled = NO;
        cell = [self tableView:tableView reuseIdentifier:kMessageCellDelete];
    } else {
        
        if (indexPath.row == 0 && _messageDataModelArray.count != 0 ) {
            //顶部的时间轴
            cell = [self tableView:tableView reuseIdentifier:kMessageCellTopTime];
            MessageModel *firstModel = _messageDataModelArray.firstObject;
            MessageModel *messageModel = [[MessageModel alloc] init];
            messageModel.yearAndMoth = firstModel.yearAndMoth;
            messageModel.messageType = MessageTypeTime;
            [cell configData:messageModel reuseIdentifier:kMessageCellTopTime];
        } else {
            MessageModel *message = _messageDataModelArray[indexPath.row - 1];
            if (message.messageType == MessageTypeTime) {
                cell = [self tableView:tableView reuseIdentifier:kMessageCellTime];
                [cell configData:message reuseIdentifier:kMessageCellTime];
            } else if (message.messageType == MessageTypeChat) {
                cell = [self tableView:tableView reuseIdentifier:kMessageCellChat];
                cell.delegate = self;
                [cell configData:message reuseIdentifier:kMessageCellChat];
            } else {
                cell = [self tableView:tableView reuseIdentifier:kMessageCellSystem];
                [cell configData:message reuseIdentifier:kMessageCellSystem];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isDelete) {
        return SCREENHEIGHT - 40 - 40;
    } else {
        if (indexPath.row == 0) {
            return 44;
        } else {
            MessageModel *message = _messageDataModelArray[indexPath.row - 1];
            if (message.messageType == MessageTypeTime) {
                return 44;
            } else {
                return message.cellHeght;
            }
        }
    }
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        _reSendMessageModel.isSendFail = NO;
        _reSendMessageModel.animateStatus = YES;
        [self reloadDataWithModel:_reSendMessageModel];
    } else {
        _reSendMessageModel = nil;
    }
}

#pragma mark ChatInputBarDelegate
- (void)chatInputBar:(ChatInputBar *)chatInputBar changeHeigh:(CGFloat)changeHeigh
{
    self.tableView.height = self.chatInputBar.top;
}
/**
 *   @author xiaerfei, 15-10-30 13:10:05
 *
 *   发送消息处理
 *
 *   @param chatInputBar
 *   @param message
 */
- (void)chatInputBar:(ChatInputBar *)chatInputBar sendMessage:(NSString *)message
{
    self.tableView.height = self.chatInputBar.top;
    MessageModel *messageModel = [MessageModel sendMessageWithContent:message];
    [self sendMessage:messageModel];
}

#pragma mark MessageCellDelegate

- (void)messageCell:(MessageCell *)cell touchData:(MessageModel *)model
{
    if (model.isSendFail == YES) {
        _reSendMessageModel = model;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"重发该消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        _dismissAlertView = alertView;
        [alertView show];
    }
}

- (void)messageCell:(MessageCell *)cell iconTouchData:(MessageModel *)model
{
//    UserInfoViewController *userInfo = [[UserInfoViewController alloc] init];
//    userInfo.groupId = _groupId;
//    userInfo.userId  = model.fromId;
//    if ([model.fromId isEqualToString:_userId]) {
//        userInfo.isUserSelf = YES;
//    }
//    [self.navigationController pushViewController:userInfo animated:YES];
}

#pragma mark - events response

/**
 *   @author xiaerfei, 15-10-20 18:10:08
 *
 *   未读消息 响应事件处理
 */
- (void)moreMessageAction
{
    self.moreMessageView.hidden = YES;
    NSInteger unReadMessageNumber = self.moreMessageView.unReadMessageNumber;
    if (unReadMessageNumber > 60) {
        _fetchDataNumber = 60;
    } else if (unReadMessageNumber < kFetchMessageNumber){
        _fetchDataNumber = kFetchMessageNumber;
    }
    [self.tableView zj_stopHeaderAnimation];
}
/**
 *   @author xiaerfei, 15-10-26 14:10:39
 *
 *   点击取消键盘响应  处理
 *
 *   @param sender
 */
- (IBAction)touchEndEidt:(id)sender {

    [self.chatInputBar textViewResignFirstResponder];
}

- (void)tapKeyEvent
{
    [self.chatInputBar textViewResignFirstResponder];
}

/**
 *   @author xiaerfei, 15-11-02 17:11:22
 *
 *   下拉刷新
 */
- (void)loadNewData
{
    if (_isLocalHistoryMessageOver) {
        
        MessageModel *model = [self selectModelOfMessageSendArray:NO];
        [self getHistoryMessageWithCount:kFetchMessageNumber messageId:model.messageId==nil?@"":model.messageId];
        return;
    }
    NSMutableArray *historyArray = [NSMutableArray array];
    BOOL isFirstLoad = NO;
    if (_fetchUserMessageTime == nil) {
        isFirstLoad = YES;
    }
    _fetchUserMessageTime = [historyArray.firstObject messageTime];
    if (historyArray.count == 0) {
        _fetchUserMessageId = [[self selectModelOfMessageSendArray:NO] messageId];
    } else {
        _fetchUserMessageId   = [historyArray.firstObject messageId];
    }
    
    if (historyArray.count < _fetchDataNumber) {
        
        [self getHistoryMessageWithCount:(_fetchDataNumber - historyArray.count) messageId:_fetchUserMessageId==nil?@"":_fetchUserMessageId];
        _isLocalHistoryMessageOver = YES;
        _isFirstLoadMessage = (_isFirstLoadMessage == 3?3:2);
    } else {
        _isFirstLoadMessage = (_isFirstLoadMessage == 3?3:1);
    }

    _fetchDataNumber = kFetchMessageNumber;
    [self messageDataModelArrayAddModels:historyArray completeFinishBlock:^{
        if (isFirstLoad) {
            if (_messageDataModelArray.count >= 1) {
                if (_isFirstLoadMessage == 1) {
                    _isFirstLoadMessage = 3;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_messageDataModelArray.count inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    [self performSelector:@selector(scrollCellAtIndex:) withObject:indexPath afterDelay:0.001f];
                }
                [self readMessage];
            }
        } else {
            self.moreMessageView.hidden = YES;
        }
        [self.tableView zj_stopHeaderAnimation];
    }];
}

- (void)scrollCellAtIndex:(NSIndexPath *)indexPath
{
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

/**
 *   @author xiaerfei, 15-11-06 15:11:19
 *
 *   返回上一页
 */
- (void)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - private methods
/**
 *   @author xiaerfei, 15-11-19 09:11:56
 *
 *   消息失败后重新发送
 *
 *   @param model
 */
- (void)reloadDataWithModel:(MessageModel *)model
{
    MessageModel *messageModel = [MessageModel sendMessageWithContent:model.text];
    messageModel.clientMsgId = model.clientMsgId;
    messageModel.fromId  = _userId;
    [_messageDataModelArray removeObject:model];
    [self sendMessage:messageModel];
}
/**
 *   @author xiaerfei, 15-11-13 11:11:55
 *
 *   设置消息已读
 */
- (void)readMessage
{
//    if (_messageDataModelArray.count > 0 && self.isConnect == YES) {
//        MessageModel *model = [self selectModelOfMessageSendArray:YES];
//        if (!isEmptyString(model.messageId) && !isEmptyString(model.messageTime)) {
//            self.readChatHandler.parameters = @{@"groupId":_groupId,
//                                                @"lastedReadMsgId":model.messageId,
//                                                @"time":model.messageTime};
//            [self.readChatHandler chat];
//        }
//    }
}
/**
 *   @author xiaerfei, 15-11-13 11:11:43
 *
 *   发送消息 发送和重新发送
 *
 *   @param messageModel
 */
- (void)sendMessage:(MessageModel *)messageModel
{
    messageModel.animateStatus = YES;
    messageModel.isSendFail    = NO;
    
    if (self.isConnect == NO) {
        [self messageSendFailedOfNetDisconnect];
        return;
    }
    [self requestSendMassage:messageModel.text];
}
/**
 *   @author xiaerfei, 15-11-18 11:11:58
 *
 *   从服务器获取历史消息
 *
 *   @param count
 */
- (void)getHistoryMessageWithCount:(NSInteger)count messageId:(NSString *)messageId
{
    if (count == 0) {
        [self.tableView zj_stopHeaderAnimation];
        return;
    }
    
    if (self.isConnect == NO) {
        [self.tableView zj_stopHeaderAnimation];
        return;
    }
    
    /*
    if (self.tableView.mj_header.isRefreshing) {
        return;
    }
     */
    if (_isGetMsgPullDownLoad) {
        [self.tableView zj_stopHeaderAnimation];
        return;
    }
    
    _isGetMsgPullDownLoad = YES;
    
}
/**
 *   @author xiaerfei, 15-11-18 17:11:26
 *
 *   发送消息 后 刷新菊花 状态
 *
 *   @param obj
 */
- (void)delayMessageRefreshAction:(id)obj
{
    [self.tableView reloadData];
}
#pragma mark - getters
- (ChatInputBar *)chatInputBar
{
    if (_chatInputBar == nil) {
        _chatInputBar = [[ChatInputBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
        _chatInputBar.backgroundColor = [UIColor whiteColor];
        _chatInputBar.delegate = self;
    }
    return _chatInputBar;
}

- (MoreMessageView *)moreMessageView
{
    if (_moreMessageView == nil) {
        _moreMessageView = [[MoreMessageView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        [_moreMessageView addTarget:self action:@selector(moreMessageAction)];
    }
    return _moreMessageView;
}

- (ApplicationStatusView *)applicationStatusView
{
    if (_applicationStatusView == nil) {
       _applicationStatusView = [[ApplicationStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    }
    return _applicationStatusView;
}

- (UILabel *)disconnectTipLabel
{
    if (_disconnectTipLabel == nil) {
        _disconnectTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
        _disconnectTipLabel.text = @"暂时无法连接服务，不能获取最新消息";
        _disconnectTipLabel.textColor = [UIColor whiteColor];
        _disconnectTipLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _disconnectTipLabel.textAlignment = NSTextAlignmentCenter;
        _disconnectTipLabel.font = [UIFont systemFontOfSize:16];
        _disconnectTipLabel.hidden = YES;
    }
    return _disconnectTipLabel;
}

- (GetLinkBillMSGList *)getLinkBillMSGList {
    if (!_getLinkBillMSGList) {
        _getLinkBillMSGList = [[GetLinkBillMSGList alloc] init];
    }
    return _getLinkBillMSGList;
}

- (SendLinkBillMSG *)sendLinkBillMSG {
    if (!_sendLinkBillMSG) {
        _sendLinkBillMSG = [[SendLinkBillMSG alloc] init];
    }
    return _sendLinkBillMSG;
}

@end

