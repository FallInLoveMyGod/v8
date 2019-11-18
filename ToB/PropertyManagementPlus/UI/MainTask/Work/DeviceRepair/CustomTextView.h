//
//  CustomTextView.h
//  ppp
//
//  Created by zglnbjys on 2019/1/7.
//  Copyright © 2019年 tianyaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTextView : UIView

@property (nonatomic,strong)UITextView *textV;

@property (nonatomic,strong)NSString *placeHolder;

@property (nonatomic,assign)NSInteger textCount;

@end

NS_ASSUME_NONNULL_END
