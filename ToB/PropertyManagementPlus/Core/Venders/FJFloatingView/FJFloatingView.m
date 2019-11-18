//
//  DJFloatingVoiceView.m
//  DeJiaIM
//
//  Created by fjf on 16/5/16.
//  Copyright © 2016年 tsningning. All rights reserved.
//

#import "FJFloatingView.h"
//#import "UIGestureRecognizer+Block.h"


////获取当前屏幕的宽高
#define  SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define  SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// 十六进制RGB颜色 格式为（0xffffff）
#define FJColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


@interface FJFloatingView() {
   
    // 当前坐标
    CGPoint _curPoint;
    
    // 开始坐标
    CGPoint _beganPoint;
}

@property (nonatomic, strong) UIView *tmpView;

// 提示 信息
@property (nonatomic, strong) UILabel *tipMessageLabel;

@end

@implementation FJFloatingView
#pragma mark --- init method
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.tag = 5577;
        // 添加 手势
        [self addPanGestureRecognizer];
        // 图标
        [self addSubview:self.iconImageView];
        // 提示 消息
        [self addSubview:self.tipMessageLabel];
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark --- private method
// 添加 手势
- (void)addPanGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}


#pragma mark --- response event

- (void)tap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(floatingViewClick)]) {
        [self.delegate floatingViewClick];
    }
}

-(void)pan:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            _beganPoint = [sender locationInView:self.superview];
            _curPoint = self.center;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [sender locationInView:self.superview];
            
            NSInteger x_offset = point.x - _beganPoint.x;
            NSInteger y_offset = point.y - _beganPoint.y;
            self.tmpView.center = self.center;
            self.tmpView.center = CGPointMake(_curPoint.x + x_offset, _curPoint.y + y_offset);
            // 设置 左边距
            if (CGRectGetMinX(self.tmpView.frame) < 0){
                x_offset -= CGRectGetMinX(self.tmpView.frame);
            }
            // 设置 右边距
            if (CGRectGetMaxX(self.tmpView.frame) > SCREEN_WIDTH) {
                x_offset += SCREEN_WIDTH - CGRectGetMaxX(self.tmpView.frame);
            }
            // 设置 上边距
            if (CGRectGetMinY(self.tmpView.frame) < 0) {
                y_offset -= CGRectGetMinY(self.tmpView.frame);
            }
            // 设置 下边距
            if (CGRectGetMaxY(self.tmpView.frame) > SCREEN_HEIGHT) {
                y_offset += SCREEN_HEIGHT - CGRectGetMaxY(self.tmpView.frame);
            }
            self.center = CGPointMake(_curPoint.x + x_offset, _curPoint.y + y_offset);
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}


#pragma mark --- getter method
// 提示 信息
- (UILabel *)tipMessageLabel {
    if (!_tipMessageLabel) {
        
        _tipMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 36, self.frame.size.width, 32)];
        _tipMessageLabel.text = @"";
        _tipMessageLabel.font = [UIFont systemFontOfSize:10.0f];
        _tipMessageLabel.textAlignment = NSTextAlignmentCenter;
        _tipMessageLabel.textColor = [UIColor whiteColor];
        
    }
    return _tipMessageLabel;
}

// 图标
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        _iconImageView.image = [UIImage imageNamed:@"zb_bg"];
        
        _iconImageView.clipsToBounds = YES;
        
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(23, 15, 22, 22)];
        imageView1.image = [UIImage imageNamed:@"icon_zb.png"];
        
        [_iconImageView addSubview:imageView1];
        self.numberLabel.hidden = YES;
        [_iconImageView addSubview:self.numberLabel];
    }
    return _iconImageView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.frame.size.width - 20, 0, 20, 20)];
        _numberLabel.layer.cornerRadius = 10;
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.backgroundColor = [UIColor redColor];
        _numberLabel.text = @"10";
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:11];
        _numberLabel.textColor = [UIColor whiteColor];
    }
    return _numberLabel;
}

// 中间view 用来计算位置
- (UIView *)tmpView {
    if (!_tmpView) {
        _tmpView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _tmpView;
}



@end
