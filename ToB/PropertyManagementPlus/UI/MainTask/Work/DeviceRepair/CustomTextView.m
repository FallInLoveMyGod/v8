//
//  CustomTextView.m
//  ppp
//
//  Created by zglnbjys on 2019/1/7.
//  Copyright © 2019年 tianyaoqi. All rights reserved.
//

#import "CustomTextView.h"
#import "UIColor+HexString.h"
#define Text_Limit 500
#define Color_Line [UIColor colorWithHexString:@"#EEEEEE" alpha:1]              //  line 颜色
#define Color_Text_Gray9 [UIColor colorWithHexString:@"#999999" alpha:1]

@interface CustomTextView() <UITextViewDelegate>

@property (nonatomic,strong)UILabel *textNumLab;

@property (nonatomic,strong)UILabel *placeHolderLab;

@end

@implementation CustomTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textCount = Text_Limit;
        [self setupUI];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.textV];
    [self addSubview:self.textNumLab];
    
    [self.textV addSubview:self.placeHolderLab];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 34, self.frame.size.width - 10, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
}

- (UITextView *)textV {
    if (!_textV) {
        _textV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 34.5)];
        _textV.delegate = self;
        _textV.font = [UIFont systemFontOfSize:16];
    }
    return _textV;
}

- (UILabel *)textNumLab {
    if (!_textNumLab) {
        _textNumLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100,  self.frame.size.height - 34, 100, 34)];
        _textNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.textCount,(long)self.textCount];
        _textNumLab.font = [UIFont systemFontOfSize:14];
    }
    return _textNumLab;
}

- (UILabel *)placeHolderLab {
    if (!_placeHolderLab) {
        _placeHolderLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 6.5, self.frame.size.width - 40, 20)];
        _placeHolderLab.font = [UIFont systemFontOfSize:14];
        _placeHolderLab.textColor = Color_Text_Gray9;
    }
    return _placeHolderLab;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.placeHolderLab.text = placeHolder;
}

- (void)setTextCount:(NSInteger)textCount {
    _textCount = textCount;
    _textNumLab.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.textCount,(long)self.textCount];
}

- (void)textViewDidChange:(UITextView *)textView {
    //    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //    paragraphStyle.lineSpacing = 3;
    //    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle};
    //    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];

    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && position) {
        return;
    }
    NSString *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > self.textCount) {
        NSString *s = [nsTextContent substringToIndex:self.textCount];
        [textView setText:s];
    }

	self.textNumLab.text = [NSString stringWithFormat:@"%d/%ld",MAX(0, MAX(0, self.textCount - existTextNum)),(long)self.textCount];
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
        
        if (offsetRange.location < self.textCount) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    
    NSString *comcastr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caniputlen = self.textCount - comcastr.length;
    
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
            self.textNumLab.text = [NSString stringWithFormat:@"%d/%ld",0,(long)self.textCount];
        }
        return NO;
        
    }
    return YES;
}




@end
