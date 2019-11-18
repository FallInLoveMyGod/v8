//
//  LSDatePicker.m
//  TestDemo
//
//  Created by Jin on 2016/12/12.
//  Copyright © 2016年 com.baidu.123. All rights reserved.
//

#import "LSDatePicker.h"
#import "NSDate+CPBaseDatePicker.h"

/*   全局数组,传递给LSDatePicker 目前支持三种日期格式:
 *   1.年月日
 *   2.时分秒
 *   3.年月日时分秒
 */
NSArray *tempDateArray;

typedef enum {
    ePickerViewTagYear = 2012,
    ePickerViewTagMonth,
    ePickerViewTagDay,
    ePickerViewTagHour,
    ePickerViewTagMinute,
    ePickerViewTagSecond
}PickViewTag;

#define Height 216
#define Width 300
#define SWidth [UIScreen mainScreen].bounds.size.width
#define SHeight [UIScreen mainScreen].bounds.size.height

@interface LSDatePicker ()
/**
 * create dataSource
 */
-(void)createDataSource;

/**
 * create month Arrays
 */
-(void)createMonthArrayWithYear:(NSInteger)yearInt month:(NSInteger)monthInt;

@property (nonatomic, strong) UIView  *contentView;
@property (nonatomic, strong) NSDate  *scrollDate;
@end


@implementation LSDatePicker

@synthesize delegate;
@synthesize yearPicker, monthPicker, dayPicker, hourPicker, minutePicker,secondPicker;
@synthesize date;
@synthesize yearArray, monthArray, dayArray, hourArray, minuteArray,secondArray;
@synthesize toolBar,hintsLabel;
@synthesize yearValue, monthValue;
@synthesize dayValue, hourValue, minuteValue,secondValue;


#pragma mark -

-(instancetype)initWithFrame:(CGRect)frame array:(NSArray *)contentArray scrollDate:(NSString *)scrollDate
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if(self) {
        
        _scrollDate = [NSDate date];
        
        @try {
            
            if (scrollDate && ![scrollDate isEqualToString:@""]) {
                
                NSArray *values = [[NSString stringWithFormat:@"%@",_scrollDate] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-T:. "]];
                
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                if ([contentArray count] == 3) {
                    if ([contentArray[0] isEqualToString:@"时"]) {
                        [formater setDateFormat:@"HH:mm:ss"];
                        scrollDate = [NSString stringWithFormat:@"%@-%@-%@",values[3],values[4],values[5]];
                    }else {
                        [formater setDateFormat:@"yyyy-MM-dd"];
                        scrollDate = [NSString stringWithFormat:@"%@-%@-%@",values[0],values[1],values[2]];
                    }
                }else {
                    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                }
                
                _scrollDate = [formater dateFromString:scrollDate];
                
                yearValue = [values[0] intValue];
                monthValue = [values[1] intValue];
                dayValue = [values[2] intValue];
                hourValue = [values[3] intValue];
                minuteValue = [values[4] intValue];
                secondValue = [values[5] intValue];
            }
            
            
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }

        tempDateArray = [NSArray arrayWithArray:contentArray];
        /*创建灰色背景*/
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SWidth, SHeight)];
        bgView.alpha = 0.3;
        bgView.backgroundColor = [UIColor blackColor];
        [self addSubview:bgView];
        
        /*添加手势事件,移除View*/
        //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissContactView:)];
        //[self addGestureRecognizer:tapGesture];
        
        /*创建显示View*/
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        _contentView.frame = CGRectMake((self.frame.size.width-Width)/2, (self.frame.size.height-260)/2, Width, 260);
        _contentView.backgroundColor=[UIColor whiteColor];
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
        
        
        // 创建 toolBar & hintsLabel & enter button
        UIToolbar* tempToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, Width, 44)];
        [tempToolBar setBarStyle:UIBarStyleDefault];
        [self setToolBar:tempToolBar];
        [_contentView addSubview:self.toolBar];
        
        //create hintsLabel
        _tempHintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 80, 34)];
        [self setHintsLabel:_tempHintsLabel];
        [self.hintsLabel setBackgroundColor:[UIColor clearColor]];
        [_contentView addSubview:self.hintsLabel];
        [self.hintsLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.hintsLabel setTextColor:[UIColor blackColor]];
        
        //crate enter Button
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn sizeToFit];
        [_confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_contentView addSubview:_confirmBtn];
        [_confirmBtn setCenter:CGPointMake(Width-15-_confirmBtn.frame.size.width*.5, 22)];
        [_confirmBtn addTarget:self action:@selector(actionEnter:) forControlEvents:UIControlEventTouchUpInside];
        
        _resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn sizeToFit];
        _resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_resetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_contentView addSubview:_resetBtn];
        [_resetBtn setCenter:CGPointMake(_confirmBtn.center.x - _confirmBtn.frame.size.width, 22)];
        [_resetBtn addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn sizeToFit];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_contentView addSubview:_cancelBtn];
        [_cancelBtn setCenter:CGPointMake(_resetBtn.center.x - _resetBtn.frame.size.width, 22)];
        [_cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)layoutSubviews
{
    /*添加PickerView*/
    NSMutableArray* tempArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray3 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray4 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray5 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray6 = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self setYearArray:tempArray1];
    [self setMonthArray:tempArray2];
    [self setDayArray:tempArray3];
    [self setHourArray:tempArray4];
    [self setMinuteArray:tempArray5];
    [self setSecondArray:tempArray6];
    
    // 更新数据源
    [self createDataSource];
    
    if([tempDateArray isEqualToArray:@[@"时",@"分",@"秒"]])
    {
        
        UIPickerView* hourPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(40, 44, 80, Height)];
        [self setHourPicker:hourPickerTemp];
        [hourPickerTemp setValue:[UIColor blackColor] forKey:@"textColor"];
        [self.hourPicker setFrame:CGRectMake(40, 44, 80, Height)];
        
        UIPickerView* minutesPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(hourPickerTemp.frame.size.width + hourPickerTemp.frame.origin.x, 44, 80, Height)];
        [self setMinutePicker:minutesPickerTemp];
        [minutesPickerTemp setValue:[UIColor blackColor] forKey:@"textColor"];
        [self.minutePicker setFrame:CGRectMake(hourPickerTemp.frame.size.width + hourPickerTemp.frame.origin.x, 44, 80, Height)];
        
        UIPickerView* secondsPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(minutesPickerTemp.frame.size.width + minutesPickerTemp.frame.origin.x, 44, 80, Height)];
        [self setSecondPicker:secondsPickerTemp];
        [secondsPickerTemp setValue:[UIColor blackColor] forKey:@"textColor"];
        [self.secondPicker setFrame:CGRectMake(minutesPickerTemp.frame.size.width + minutesPickerTemp.frame.origin.x, 44, 80, Height)];
        
        
        
    }else if([tempDateArray isEqualToArray:@[@"年",@"月",@"日"]])
    {
        
        UIPickerView*  yearPickerTemp= [[UIPickerView alloc] initWithFrame:CGRectMake(30, 44, 100, Height)];
        //        [hourPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setYearPicker:yearPickerTemp];
        [self.yearPicker setFrame:CGRectMake(30, 44, 100, Height)];
        
        UIPickerView* monthPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(yearPickerTemp.frame.size.width + yearPickerTemp.frame.origin.x, 44, 80, Height)];
        //        [minutesPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setMonthPicker:monthPickerTemp];
        [self.monthPicker setFrame:CGRectMake(yearPickerTemp.frame.size.width + yearPickerTemp.frame.origin.x, 44, 80, Height)];
        
        UIPickerView* dayPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(monthPickerTemp.frame.size.width + monthPickerTemp.frame.origin.x, 44, 80, Height)];
        //        [secondsPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setDayPicker:dayPickerTemp];
        [self.dayPicker setFrame:CGRectMake(monthPickerTemp.frame.size.width + monthPickerTemp.frame.origin.x, 44, 80, Height)];
    }else if ([tempDateArray isEqualToArray:@[@"年",@"月",@"日",@"时",@"分",@"秒"]])
    {
        
        CGFloat yearWidth = 80;
        CGFloat normalWidth = (Width - yearWidth)/4.0;
        
        // 初始化各个视图
        UIPickerView* yearPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, yearWidth, Height)];
        [self setYearPicker:yearPickerTemp];
        //        [yearPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self.yearPicker setFrame:CGRectMake(0, 44, yearWidth, Height)];
        
        UIPickerView* monthPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(yearPickerTemp.frame.size.width + yearPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        //        [monthPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setMonthPicker:monthPickerTemp];
        [self.monthPicker setFrame:CGRectMake(yearPickerTemp.frame.size.width + yearPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        
        UIPickerView* dayPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(monthPickerTemp.frame.size.width + monthPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        //        [dayPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setDayPicker:dayPickerTemp];
        [self.dayPicker setFrame:CGRectMake(monthPickerTemp.frame.size.width + monthPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        
        UIPickerView* hourPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(dayPickerTemp.frame.size.width + dayPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        //        [hourPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setHourPicker:hourPickerTemp];
        [self.hourPicker setFrame:CGRectMake(dayPickerTemp.frame.size.width + dayPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        
        UIPickerView* minutesPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(hourPickerTemp.frame.size.width + hourPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        //        [minutesPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setMinutePicker:minutesPickerTemp];
        [self.minutePicker setFrame:CGRectMake(hourPickerTemp.frame.size.width + hourPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        
        UIPickerView* secondsPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(minutesPickerTemp.frame.size.width + minutesPickerTemp.frame.origin.x, 44, normalWidth, Height)];
        //        [secondsPickerTemp setValue:[UIColor whiteColor] forKey:@"textColor"];
        [self setSecondPicker:secondsPickerTemp];
        [self.secondPicker setFrame:CGRectMake(minutesPickerTemp.frame.size.width + minutesPickerTemp.frame.origin.x, 44, normalWidth, Height)];
    }
    
    
    [self.yearPicker setDataSource:self];
    [self.monthPicker setDataSource:self];
    [self.dayPicker setDataSource:self];
    [self.hourPicker setDataSource:self];
    [self.minutePicker setDataSource:self];
    [self.secondPicker setDataSource:self];
    
    [self.yearPicker setDelegate:self];
    [self.monthPicker setDelegate:self];
    [self.dayPicker setDelegate:self];
    [self.hourPicker setDelegate:self];
    [self.minutePicker setDelegate:self];
    [self.secondPicker setDelegate:self];
    
    [self.yearPicker setTag:ePickerViewTagYear];
    [self.monthPicker setTag:ePickerViewTagMonth];
    [self.dayPicker setTag:ePickerViewTagDay];
    [self.hourPicker setTag:ePickerViewTagHour];
    [self.minutePicker setTag:ePickerViewTagMinute];
    [self.secondPicker setTag:ePickerViewTagSecond];
    
    
    if([tempDateArray isEqualToArray:@[@"年",@"月",@"日"]])
    {
        [_contentView addSubview:self.yearPicker];
        [_contentView addSubview:self.monthPicker];
        [_contentView addSubview:self.dayPicker];
    }else if ([tempDateArray isEqualToArray:@[@"时",@"分",@"秒"]])
    {
        [_contentView addSubview:self.hourPicker];
        [_contentView addSubview:self.minutePicker];
        [_contentView addSubview:self.secondPicker];
    }else if([tempDateArray isEqualToArray:@[@"年",@"月",@"日",@"时",@"分",@"秒"]])
    {
        [_contentView addSubview:self.yearPicker];
        [_contentView addSubview:self.monthPicker];
        [_contentView addSubview:self.dayPicker];
        [_contentView addSubview:self.hourPicker];
        [_contentView addSubview:self.minutePicker];
        [_contentView addSubview:self.secondPicker];
    }
    
    
    [self.yearPicker setShowsSelectionIndicator:YES];
    [self.monthPicker setShowsSelectionIndicator:YES];
    [self.dayPicker setShowsSelectionIndicator:YES];
    [self.hourPicker setShowsSelectionIndicator:YES];
    [self.minutePicker setShowsSelectionIndicator:YES];
    [self.secondPicker setShowsSelectionIndicator:YES];
    
    [self resetDateToCurrentDate:_scrollDate];
}


//- (void)dismissContactView:(UITapGestureRecognizer *)tapGesture{
//
//    [self dismissContactView];
//}



-(void)showViewInSelectView:(UIView *)view
{
    [view addSubview:self];
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (ePickerViewTagYear == pickerView.tag) {
        return [self.yearArray count];
    }
    
    if (ePickerViewTagMonth == pickerView.tag) {
        return [self.monthArray count];
    }
    
    if (ePickerViewTagDay == pickerView.tag) {
        return [self.dayArray count];
    }
    
    if (ePickerViewTagHour == pickerView.tag) {
        return [self.hourArray count];
    }
    
    if (ePickerViewTagMinute == pickerView.tag) {
        return [self.minuteArray count];
    }
    
    if (ePickerViewTagSecond == pickerView.tag) {
        return [self.secondArray count];
    }
    return 0;
}

#pragma makr - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (ePickerViewTagYear == pickerView.tag) {
        return [self.yearArray objectAtIndex:row];
    }
    
    if (ePickerViewTagMonth == pickerView.tag) {
        return [self.monthArray objectAtIndex:row];
    }
    
    if (ePickerViewTagDay == pickerView.tag) {
        return [self.dayArray objectAtIndex:row];
    }
    
    if (ePickerViewTagHour == pickerView.tag) {
        return [self.hourArray objectAtIndex:row];
    }
    
    if (ePickerViewTagMinute == pickerView.tag) {
        return [self.minuteArray objectAtIndex:row];
    }
    
    if (ePickerViewTagSecond == pickerView.tag) {
        return [self.secondArray objectAtIndex:row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (ePickerViewTagYear == pickerView.tag) {
        self.yearValue = [[self.yearArray objectAtIndex:row] intValue];
    } else if(ePickerViewTagMonth == pickerView.tag){
        self.monthValue = [[self.monthArray objectAtIndex:row] intValue];
    }else if(ePickerViewTagDay == pickerView.tag){
        self.dayValue = [[self.dayArray objectAtIndex:row] intValue];
    }else if(ePickerViewTagHour == pickerView.tag){
        self.hourValue = [[self.hourArray objectAtIndex:row] intValue];
    } else if(ePickerViewTagMinute == pickerView.tag){
        self.minuteValue = [[self.minuteArray objectAtIndex:row] intValue];
    } else if(ePickerViewTagSecond == pickerView.tag){
        self.secondValue = [[self.secondArray objectAtIndex:row] intValue];
    }
    if (ePickerViewTagMonth == pickerView.tag || ePickerViewTagYear == pickerView.tag) {
        [self createMonthArrayWithYear:self.yearValue month:self.monthValue];
        [self.dayPicker reloadAllComponents];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectItemPickerDelegate:)]){
        [self.delegate selectItemPickerDelegate:self];
    }
}
#pragma mark - 年月日闰年＝情况分析
/**
 * 创建数据源
 */
-(void)createDataSource{
    // 年
    int yearInt = [[NSDate date] getYear];
    [self.yearArray removeAllObjects];
    for (int i=yearInt -99; i<=yearInt+99; i++) {
        [self.yearArray addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    
    // 月
    [self.monthArray removeAllObjects];
    for (int i=1; i<=12; i++) {
        [self.monthArray addObject:[NSString stringWithFormat:@"%d月",i]];
    }
    
    
    NSInteger month = [[NSDate date] getMonth];
    
    [self createMonthArrayWithYear:yearInt month:month];
    
    // 时
    [self.hourArray removeAllObjects];
    for(int i=0; i<24; i++){
        [self.hourArray addObject:[NSString stringWithFormat:@"%02d时",i]];
    }
    
    // 分
    [self.minuteArray removeAllObjects];
    for(int i=0; i<60; i++){
        [self.minuteArray addObject:[NSString stringWithFormat:@"%02d分",i]];
    }
    
    // 秒
    [self.secondArray removeAllObjects];
    for(int i=0; i<60; i++){
        [self.secondArray addObject:[NSString stringWithFormat:@"%02d秒",i]];
    }
}
#pragma mark -
-(void)resetDateToCurrentDate:(NSDate *)nowDate{
    
    if (!nowDate) {
        return;
    }
    
    [self.yearPicker selectRow:[self.yearArray count]-100 inComponent:0 animated:YES];
    [self.monthPicker selectRow:[nowDate getMonth]-1 inComponent:0 animated:YES];
    [self.dayPicker selectRow:[nowDate getDay]-1 inComponent:0 animated:YES];
    
    [self.hourPicker selectRow:[nowDate getHours] inComponent:0 animated:YES];
    [self.minutePicker selectRow:[nowDate getMinutes] inComponent:0 animated:YES];
    [self.secondPicker selectRow:[nowDate getSeconds] inComponent:0 animated:YES];
    
    [self setYearValue:[nowDate getYear]];
    [self setMonthValue:[nowDate getMonth]];
    [self setDayValue:[nowDate getDay]];
    [self setHourValue:[nowDate getHours]];
    [self setMinuteValue:[nowDate getMinutes]];
    [self setSecondValue:[nowDate getSeconds]];
    
}
#pragma mark -
-(void)createMonthArrayWithYear:(NSInteger)yearInt month:(NSInteger)monthInt{
    int endDate = 0;
    switch (monthInt) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            endDate = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            endDate = 30;
            break;
        case 2:
            // 是否为闰年
            if (yearInt % 400 == 0) {
                endDate = 29;
            } else {
                if (yearInt % 100 != 0 && yearInt %4 ==4) {
                    endDate = 29;
                } else {
                    endDate = 28;
                }
            }
            break;
        default:
            break;
    }
    
    if (self.dayValue > endDate) {
        self.dayValue = endDate;
    }
    // 日
    [self.dayArray removeAllObjects];
    for(int i=1; i<=endDate; i++){
        [self.dayArray addObject:[NSString stringWithFormat:@"%d日",i]];
    }
}



#pragma mark - 设置提示信息
-(void)setHintsText:(NSString*)hints{
    [self.hintsLabel setText:hints];
}

#pragma mark - 确定按钮
-(void)actionEnter:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DatePickerDelegateEnterActionWithDataPicker:)]){
        [self.delegate DatePickerDelegateEnterActionWithDataPicker:self];
    }
    [self dismissContactView];
}

- (void)cancel:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClick)]){
        [self.delegate cancelButtonClick];
    }
    [self dismissContactView];
}

- (void)reset:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(resetButtonClickWithDataPicker:)]){
        [self.delegate resetButtonClickWithDataPicker:self];
    }
    [self dismissContactView];
}

#pragma mark - 移除view [以下 二选一]
-(void)removeFromSuperview{
    
    self.delegate = nil;
    [super removeFromSuperview];
}

-(void)dismissContactView
{
    self.delegate = nil;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    
}

#pragma mark ---------------------------
#pragma mark -pickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [pickerLabel setTextColor:[UIColor blackColor]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


@end

