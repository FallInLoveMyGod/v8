//
//  LSTabBarController.h
//  LSTabBarController
//
//  Created by WWT on 15/11/20.
//  Copyright © 2015年 WWT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerNavigationView.h"

@interface LSTabBarController : UITabBarController <UITabBarControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CustomerNavigationView *customerNavigation;
- (instancetype)initWithControllerArray:(NSArray *)controllers titleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray selImageArray:(NSArray *)selImageArray;
- (void)show;
- (void)hide;
@end
