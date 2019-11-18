//
//  MJSignatureView.h
//  MJNSFA
//
//  Created by zhiqing on 16/2/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZQBaseSignatureView.h"

@interface ZQSignatureView : UIView

//默认允许
@property (nonatomic, assign) BOOL allowDealWithPhoto;

/**
 *  @brief 用户签名后，形成的略缩图
 */

@property (nonatomic, strong) UIImageView *signImageView;
@property (nonatomic, strong) ZQBaseSignatureView *signatureView;
@property (nonatomic, strong) UIImage *signatureSuccessImage;
- (void)showSignatureView;

@end
