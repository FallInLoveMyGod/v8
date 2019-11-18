//
//  MJSignatureView.m
//  MJNSFA
//
//  Created by zhiqing on 16/2/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "ZQSignatureView.h"
#define kTextColor              (RGBCOLOR(19, 124, 198))
#define kSizeSignImage          (CGSizeMake(80, 90))
#define kTagSignView            (111)
#define kAnnimateTime           (0.5)
#define kButtonFont             [UIFont systemFontOfSize:16]

@interface ZQSignatureView ()
{
    
    /**
     *  @brief 用户签名的视图
     */
    UIView      *_signBoardView;
    
    UIView      *_maskView;
    
    CATransform3D _transfrom;
}

@end


@implementation ZQSignatureView

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    
        _signImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, kSizeSignImage.width, kSizeSignImage.height)];
        _signImageView.contentMode = UIViewContentModeScaleAspectFit;
        _signImageView.backgroundColor = [UIColor clearColor];
        _signImageView.image = [UIImage imageNamed:@"icon_qz"];
        [self addSubview:_signImageView];
    }
    
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self showSignatureView];
}

- (void)showSignatureView
{
    if (_signBoardView)
    {//非第一次
        
        if (_signBoardView.hidden) {
            
            _signBoardView.hidden = NO;
            _maskView.hidden = NO;
            
            [UIView animateWithDuration:kAnnimateTime animations:^
             {
                 _maskView.alpha = 0.5;
                 _signBoardView.layer.transform = CATransform3DIdentity;
             } completion:^(BOOL finished) {
             }];
        }else {
            [self dismiss];
        }
    }else
    {//第一次显示
        
        UIWindow * window = [[[UIApplication sharedApplication] windows] firstObject];
        UIView * rootView = window.rootViewController.view;
        
        _maskView = [[UIView alloc] initWithFrame:rootView.bounds];
        _maskView.userInteractionEnabled = YES;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;
        [rootView addSubview:_maskView];
        
        CGFloat width  = rootView.bounds.size.width*0.85;

        CGRect frame = CGRectMake((rootView.frame.size.width-width)/2, 50, width, rootView.frame.size.height - 100);
        _signBoardView = [[UIView alloc]initWithFrame:frame];
        _signBoardView.backgroundColor = [UIColor whiteColor];
        _signBoardView.layer.borderColor = [UIColor grayColor].CGColor;
        _signBoardView.layer.borderWidth = 0.6;
        _signBoardView.layer.cornerRadius = 5;
        _signBoardView.layer.masksToBounds = YES;
        _signBoardView.userInteractionEnabled = YES;
        [rootView addSubview:_signBoardView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, _signBoardView.bounds.size.height - 50, _signBoardView.bounds.size.width, 50)];
        bgView.backgroundColor = [UIColor lightGrayColor];
        [_signBoardView addSubview:bgView];
        /**
         *  @brief 增加删除按钮
         */
        
        CGFloat space = 10;
        CGFloat widthButton = (_signBoardView.bounds.size.width - 4 * space)/3;
        
        UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(space, 8, widthButton, 34)];
        [returnButton setTitle:@"返回" forState:UIControlStateNormal];
        [returnButton setTitleColor:[UIColor blackColor]  forState:UIControlStateNormal];
        [returnButton setBackgroundColor:[UIColor whiteColor]];
        returnButton.titleLabel.font = kButtonFont;
        [returnButton addTarget:self action:@selector(returnButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:returnButton];
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(space*2 + widthButton, 8, widthButton, 34)];
        [deleteBtn setTitle:@"清空" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor blackColor]  forState:UIControlStateNormal];
        [deleteBtn setBackgroundColor:[UIColor whiteColor]];
        deleteBtn.titleLabel.font = kButtonFont;
        [bgView addSubview:deleteBtn];
        
        /**
         *  @brief 增加保存按钮
         */
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(space*3 + 2 * widthButton, 8, widthButton, 34)];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        saveBtn.titleLabel.font = kButtonFont;
        [saveBtn setBackgroundColor:[UIColor whiteColor]];
        [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:saveBtn];
        
        _signatureView = [[ZQBaseSignatureView alloc] initWithFrame:rootView.bounds];
        _signatureView.signatureImage = _signImageView.image;
        _signatureView.allowDealWithPhoto = self.allowDealWithPhoto;
        _signatureView.tag = kTagSignView;
        
        [_signBoardView addSubview:_signatureView];
        [_signBoardView bringSubviewToFront:bgView];
        [_signBoardView bringSubviewToFront:deleteBtn];
        [_signBoardView bringSubviewToFront:saveBtn];
        
        [deleteBtn addTarget:_signatureView action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:kAnnimateTime animations:^
         {
             _maskView.alpha = 0.5;
             _signBoardView.layer.transform = CATransform3DIdentity;
             deleteBtn.hidden = NO;
             saveBtn.hidden = NO;
         } completion:^(BOOL finished) {
             
         }];
        
    }
}

-(void)save
{
    if (!_allowDealWithPhoto) {
        return;
    }
    ZQBaseSignatureView *signatureView = [_signBoardView viewWithTag:kTagSignView];
    _signImageView.image =  signatureView.signatureImage;
    _signatureSuccessImage = signatureView.signatureImage;
    _signImageView.hidden = YES;
   
    [self dismiss];
    
}

- (void)returnButtonClick {
    [self dismiss];
}

/**
 *  @brief 点击隐藏视图
 *
 */
-(void)dismiss
{
    _signBoardView.hidden = NO;
    _maskView.hidden = NO;
    
    [UIView animateWithDuration:kAnnimateTime animations:^
     {
         _maskView.alpha = 0;
         _signBoardView.layer.transform = _transfrom;
     } completion:^(BOOL finished)
    {
        _signBoardView.hidden = YES;
        _maskView.hidden = YES;
         _signImageView.hidden = NO;
     }];
}



-(void)dealloc
{
    [_maskView removeFromSuperview];
    _maskView = nil;
    
    [_signBoardView removeFromSuperview];
    _signBoardView = nil;
}

-(id)value
{
    return _signImageView.image;
}

@end
