//
//  MyCustonTextView.m
//  TestScrollView
//
//  Created by 田耀琦 on 2017/6/7.
//  Copyright © 2017年 田耀琦. All rights reserved.
//

#import "MyCustonTextView.h"

#define Text_Limit 200
//#define Color_Line [UIColor colorWithHexString:@"#EEEEEE" alpha:1]              //  line 颜色
//#define Color_Text_Gray9 [UIColor colorWithHexString:@"#999999" alpha:1]

@implementation MyCustonTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scrollEnabled = YES;
        [self addSubview:self.placeHolderLab];
        [self addSubview:self.textNumLab];
        for (int i = 0; i < 50; i ++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 6 + 20 * i, self.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor whiteColor];
//            [self addSubview:lineView];
        }
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.scrollEnabled = YES;
        [self addSubview:self.placeHolderLab];
        [self addSubview:self.textNumLab];
        for (int i = 0; i < 50; i ++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 6 + 20 * i, self.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor whiteColor];
            [self addSubview:lineView];
        }
    }
    return self;
}

- (UILabel *)placeHolderLab {
    if (!_placeHolderLab) {
        _placeHolderLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 6.5, self.frame.size.width - 40, 20)];
        _placeHolderLab.font = [UIFont systemFontOfSize:12];
//        _placeHolderLab.textColor = Color_Text_Gray9;
    }
    return _placeHolderLab;
}

- (UILabel *)textNumLab {
    if (!_textNumLab) {
        _textNumLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, self.frame.size.height - 18, 80, 16)];
        _textNumLab.font = [UIFont systemFontOfSize:12];
    }
    return _textNumLab;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle};
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
    
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && position) {
        return;
    }
    NSString *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > Text_Limit) {
        NSString *s = [nsTextContent substringToIndex:Text_Limit];
        [textView setText:s];
    }
    CGRect rec = self.textNumLab.frame;
    rec.origin.y = self.contentSize.height - 18;
    self.textNumLab.frame = rec;
    self.textNumLab.text = [NSString stringWithFormat:@"%ld/%d",MAX(0, MAX(0, Text_Limit - existTextNum)),Text_Limit];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    //  设置placeHolder
   if (![text isEqualToString:@""]) {
        self.placeHolderLab.hidden = YES;
    }
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        self.placeHolderLab.hidden = NO;
    }
    
    if ([[textView textInputMode] primaryLanguage] == nil || [[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"]) {
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    
    if (selectedRange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < Text_Limit) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    NSString *comcastr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caniputlen = Text_Limit - comcastr.length;
    
    if (caniputlen >= 0) {
        return YES;
    }
    else {
        NSInteger len = text.length + caniputlen;
        NSRange rg = {0,MAX(len, 0)};
        if (rg.length > 0) {
            NSString *s = @"";
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];
            }
            else {
                __block NSInteger idx = 0;
                __block NSString *trimString = @"";
                [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                    if (idx >= rg.length) {
                        *stop = YES;
                        return ;
                    }
                    trimString = [trimString stringByAppendingString:substring];
                    idx ++;
                }];
                s = trimString;
            }
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            self.textNumLab.text = [NSString stringWithFormat:@"%d/%d",0,Text_Limit];
        }
        return NO;
    }
    
    return YES;
}

@end
