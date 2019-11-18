//
//  MJSignatureView.h
//  MJNSFA
//
//  Created by zhiqing on 13/2/2.
//  Copyright © 2016年 weida studio. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ZQBaseSignatureView : GLKView

//默认允许
@property (nonatomic, assign) BOOL allowDealWithPhoto;

@property (assign, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) BOOL hasSignature;
@property (strong, nonatomic) UIImage *signatureImage;

- (void)erase;

@end
