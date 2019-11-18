//
//  SliderViewController.h
//  SliderViewController
//
//  Created by wwt on 15/6/10.
//  Copyright (c) 2015年 wwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSTabBarController.h"

//P.S. 为了避免循环引用， -Swift.h 文件只能在 .m 文件中 import。如果需要在 .h 文件中使用，就只能用 @class 来前向声明。


@interface SliderViewController :UIViewController

@property (strong, nonatomic) LSTabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *tabbarNavigationController;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)tabbarHidden;
- (void)tabbarShow;
- (void)showMenu;
@end

