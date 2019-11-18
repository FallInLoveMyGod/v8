//
//  WYTextViewCell.m
//  propertyservices
//
//  Created by 田耀琦 on 2018/1/15.
//  Copyright © 2018年 javajy. All rights reserved.
//

#import "WYTextViewCell.h"
#import "PropertyManagementPlus-Swift.h"

@implementation WYTextViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 77, 21)];
        lab.text = @"详情描述";
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor darkGrayColor];
        self.titleLab = lab;
        [self.contentView addSubview:lab];
//        [self.contentView addSubview:self.textV];
        [self.contentView addSubview:self.textView];
    }
    return self;
}

- (CustomTextView *)textView {
    if (!_textView) {
        _textView = [[CustomTextView alloc] initWithFrame:CGRectMake(97, 10, SCREENWIDTH - 77 - 20 - 10, 80 + 30)];
        _textView.placeHolder = @"输入内容";
        _textView.textCount = 200;
    }
    return _textView;
}

- (MyCustonTextView *)textV {
    if (!_textV) {
//        _textV = [[MyCustonTextView alloc] initWithFrame:CGRectMake(97, 10, App_Width - 77 - 20 - 10, 80)];
        _textV = [[MyCustonTextView alloc] initWithFrame:CGRectMake(97, 10, SCREENHEIGHT - 77 - 20 - 10, 80)];
        _textV.placeHolderLab.text = @"限制200字";
//        _textV.layer.borderColor = Color_Line_Gray.CGColor;
        _textV.layer.borderWidth = 1;
        _textV.layer.cornerRadius = 4;
        _textV.textNumLab.hidden = NO;
    }
    return _textV;
}


@end
