//
//  HomeItemViewIconButton.m
//  test
//
//  Created by wwt on 14-11-13.
//  Copyright (c) 2014年 wsy.Inc. All rights reserved.
//

#import "HomeItemViewIconButton.h"
@interface HomeItemViewIconButton ()

@property (nonatomic, assign) CGFloat contentLabelHeight;

-(void)pressed;
-(void)touchUp;

@end

@implementation HomeItemViewIconButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.initialized=NO;
        _contentLabelHeight = 60;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame contentLabelHeight:(CGFloat)contentLabelHeight {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.initialized=NO;
        _contentLabelHeight = contentLabelHeight;
    }
    return self;
    
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.initialized) {
        return;
    }
    //取消IB中的title
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateHighlighted];
    //显示自己添加的的title
    _contentLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, _contentLabelHeight, self.bounds.size.width ,22)];
    //l.text=[self.dataSource setIconTitle];
    _contentLabel.text=_titleName;
    _contentLabel.textAlignment=NSTextAlignmentCenter;
    _contentLabel.font = [UIFont fontWithName:@"Arial" size:12];
    _contentLabel.textColor=[UIColor blackColor];
    [self addSubview:_contentLabel];
    //添加图片
    //UIImage * img=[self.dataSource setIcon];
    UIImage * img = _iconImage;
    [self setImage:img forState:UIControlStateNormal];
    [self setImage:img forState:UIControlStateHighlighted];
    //设置背景图片
    UIImage * bgimg=[UIImage imageNamed:@"HomeItemViewIcons.bundle/app_item_pressed_bg.png"];
    [self setBackgroundImage:bgimg forState:UIControlStateHighlighted];
    
    _contentLabel.frame = CGRectMake(0, (self.frame.size.height + _iconImage.size.height)/2 + 5, self.bounds.size.width ,22);
    
    //设置insets
    self.contentEdgeInsets=UIEdgeInsetsMake(-11, 0, 0, 0);
    //响应事件
    self.initialized=YES;
}
-(void)pressed{
    self.backgroundColor=[UIColor colorWithRed:235./255 green:235./255 blue:235./255 alpha:1];
}
-(void)touchUp{
    self.backgroundColor=[UIColor whiteColor];
}
@end
