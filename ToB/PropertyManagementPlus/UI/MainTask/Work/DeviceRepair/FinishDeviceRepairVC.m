//
//  FinishDeviceRepairVC.m
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2019/3/29.
//  Copyright © 2019 Lesoft. All rights reserved.
//

#import "FinishDeviceRepairVC.h"
#import "DeviceRepairVC.h"
#import "WGChooseLabCell.h"
#import "WYTextViewCell.h"
#import "PropertyManagementPlus-Swift.h"
#import <PGDatePicker/PGDatePicker.h>
#import "UUDatePicker.h"
//#import "UITableView+TYTouches.h"
@interface FinishDeviceRepairVC ()<UITableViewDelegate,UITableViewDataSource,PGDatePickerDelegate,UUDatePickerDelegate>

@property (nonatomic,strong)UILabel *contextLab;

@property (nonatomic,strong)UITableView *mytable;

@property (nonatomic,strong)UIView *bottomView;

@property (nonatomic,assign)NSInteger currentRow;

@property (nonatomic,strong)UILabel *beginTime;

@property (nonatomic,strong)UILabel *endTime;

@property (nonatomic,strong)UIDatePicker *datePicker;

@property (nonatomic,strong)CustomTextView *textView;

@property (nonatomic,strong)UUDatePicker *uDatePicker;

@end

static NSString *chooseLabId = @"WGChooseLabCell";
static NSString *textViewId = @"WYTextViewCell";

@implementation FinishDeviceRepairVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contextLab];
    [self.view addSubview:self.mytable];
    self.title = @"完成保养";
    NSString *str =self.planMemo;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    CGFloat height = rect.size.height;
    CGRect newRect = self.contextLab.frame;
    CGRect newTableRect = self.mytable.frame;
    
    newRect.size.height = height + 20;
    newTableRect.origin.y = CGRectGetMaxY(newRect) + 10;
    newTableRect.size.height = SCREENHEIGHT - (CGRectGetMaxY(newRect) + 10) - 50;
    self.contextLab.frame = newRect;
    self.contextLab.text = str;
    self.mytable.frame = newTableRect;
    
    [self.mytable registerNib:[UINib nibWithNibName:chooseLabId bundle:[NSBundle mainBundle]] forCellReuseIdentifier:chooseLabId];
    [self.mytable registerClass:NSClassFromString(textViewId) forCellReuseIdentifier:textViewId];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT -  - 64 - 50 - 128, SCREENWIDTH, 50)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    [self creatBottomView];
    
//    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 64 - 50 - 100, SCREENWIDTH, 150)];
//    datePicker.backgroundColor = [UIColor whiteColor];
//    [datePicker setDate:[NSDate date] animated:YES];
//    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
//    [datePicker setDatePickerMode:UIDatePickerModeDate];
//    [self.view addSubview:self.datePicker];
    
}

- (void)creatBottomView {
    [[self.bottomView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, SCREENWIDTH/2.0 - 0.5, 50);
    btn.backgroundColor = ThemeColor;
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:btn];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(SCREENWIDTH/2.0 + 0.5, 0, SCREENWIDTH/2.0 - 0.5, 50);
    nextBtn.backgroundColor = ThemeColor;
    [nextBtn setTitle:@"提交" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(finish:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:nextBtn];
    
}

- (void)back:(id)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finish:(id)btn {
    [self requestData];
}

- (void)dateChanged:(UIDatePicker *)picker {
    NSDate *date = picker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:date];
    if (self.currentRow == 0) {
        self.beginTime.text = dateString;
    }
    else {
        self.endTime.text = dateString;
    }
    NSLog(@"-- %@",picker.date);
}

- (UILabel *)contextLab {
    if (!_contextLab) {
        _contextLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 20 , 1000)];
//        _contextLab.backgroundColor = [UIColor redColor];
        _contextLab.numberOfLines = 0;
    }
    return _contextLab;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
            UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 64 - 50 - 100, SCREENWIDTH, 150)];
            datePicker.backgroundColor = [UIColor whiteColor];
            [datePicker setDate:[NSDate date] animated:YES];
            [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            [datePicker setDatePickerMode:UIDatePickerModeDate];
        _datePicker = datePicker;
//        _datePicker = [[PGDatePicker alloc] init];
//        _datePicker.delegate = self;
//        _datePicker.datePickerMode = PGDatePickerModeDate;
//        //        _datePicker.autoSelected = YES;
////        NSDate *date = [self getPriousorLaterDateFromDate:[NSDate date] withMonth:1];
//        NSDate *date = [NSDate date];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//        [_datePicker setDate:[NSDate date]];
////        NSString *dateString = [dateFormatter stringFromDate:date];
////        NSArray *arr = [dateString componentsSeparatedByString:@"-"];
////        _datePicker.maximumDate = [NSDate setYear:[arr[0] integerValue] month:[arr[1] integerValue] day:[arr[2] integerValue] hour:[arr[3] integerValue] minute:[arr[4] integerValue]];
//        _datePicker.datePickerType = PGDatePickerTypeSegment;
    }
    return _datePicker;
}

- (UUDatePicker *)uDatePicker {
    if (!_uDatePicker) {
        _uDatePicker = [[UUDatePicker alloc] initWithframe:CGRectMake(0, SCREENHEIGHT - 64 - 50 - 150, SCREENWIDTH, 150) Delegate:self PickerStyle:UUDateStyle_YearMonthDay];
        [_uDatePicker setScrollToDate:[NSDate date]];
    }
    return _uDatePicker;
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

#pragma mark - PGDatePickerDelegate
- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calender dateFromComponents:dateComponents];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //    NSInteger weekday = dateComponents.weekday;
    NSString *dateString = [dateFormatter stringFromDate:date];
    if (self.currentRow == 0) {
        self.beginTime.text = dateString;
    }
    else {
        self.endTime.text = dateString;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <= 1) {
        WGChooseLabCell *cell = [tableView dequeueReusableCellWithIdentifier:chooseLabId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentLab.text = @"";
        if (indexPath.row == 0) {
            cell.titleLab.text = @"开始时间";
            self.beginTime = cell.contentLab;
            cell.chooseContent = ^{
                if (_datePicker && self.currentRow == 0) {
                    [_datePicker removeFromSuperview];
                    _datePicker = nil;
                }
                else {
                    [self.view addSubview:self.datePicker];
                }
                self.currentRow = 0;
            };
        }
        else {
            cell.titleLab.text = @"结束时间";
            self.endTime = cell.contentLab;
            cell.chooseContent = ^{
                
                if (_datePicker && self.currentRow == 1) {
                    [_datePicker removeFromSuperview];
                    _datePicker = nil;
                }
                else {
                    [self.view addSubview:self.datePicker];
                }
                self.currentRow = 1;
            };
        }
        return cell;
    }
    else if (indexPath.row == 2) {
        WYTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:textViewId];
        cell.titleLab.text = @"完成情况";
        self.textView = cell.textView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"-%ld",indexPath.row];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH , 44)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH, 44)];
    lab.text = @"完成情况";
    lab.textColor = [UIColor darkGrayColor];
    lab.font = [UIFont systemFontOfSize:16];
    [header addSubview:lab];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return 95 + 30;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_datePicker) {
        [_datePicker removeFromSuperview];
        _datePicker = nil;
    }
}



- (void)requestData {
    if (self.beginTime.text.length == 0) {
        [LocalToastView toastWithText:@"请选择开始时间"];
        return;
    }
    if (self.endTime.text.length == 0) {
        [LocalToastView toastWithText:@"请选择结束时间"];
        return;
    }
    if (self.textView.textV.text.length == 0) {
        [LocalToastView toastWithText:@"请输入完成情况"];
        return;
    }
    FinishDeviceRepairCmd *getIndicatorsAPICmd = [[FinishDeviceRepairCmd alloc] init];
    getIndicatorsAPICmd.baseUrl = self.baseUrl;
    NSDictionary *infos = @{@"beginDate":self.beginTime.text,@"endDate":self.endTime.text,@"finishMemo":self.textView.textV.text,@"id":self.code};
    getIndicatorsAPICmd.parameters = [@{@"AccountCode":self.accountCode,@"upk":self.upk,@"infos":[self convertToJsonData:infos],@"pageIndex":@"1"} mutableCopy];
    [getIndicatorsAPICmd transactionWithSuccess:^(id _Nonnull response) {
        if ([response[@"result"] isEqualToString:@"success"]) {
           
            NSLog(@"== %@",response);
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            [LocalToastView toastWithText:response[@"msg"]];

        }
    } failure:^(id _Nonnull error) {
        [LocalToastView toastWithText:@"服务器错误"];
    }];
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}



@end
