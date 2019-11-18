//
//  SliderViewController.m
//  SliderViewController
//
//  Created by wwt on 15/6/10.
//  Copyright (c) 2015年 wwt. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "SliderViewController.h"
#import "WMNavigationController.h"
#import "LSTabBarController.h"

#define ScreenWith [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

typedef enum state {
    kStateHome,
    kStateMenu
}state;

static const CGFloat viewSlideHorizonRatio = 0.65;
static const CGFloat viewHeightNarrowRatio = 0.80;
static const CGFloat menuStartNarrowRatio  = 0.70;

@interface SliderViewController () <UITabBarControllerDelegate,UIGestureRecognizerDelegate>
@property (assign, nonatomic) state   sta;              // 状态(Home or Menu)
@property (assign, nonatomic) CGFloat distance;         // 距离左边的边距
@property (assign, nonatomic) CGFloat leftDistance;
@property (assign, nonatomic) CGFloat menuCenterXStart; // menu起始中点的X
@property (assign, nonatomic) CGFloat menuCenterXEnd;   // menu缩放结束中点的X
@property (assign, nonatomic) CGFloat panStartX;        // 拖动开始的x值

@property (strong, nonatomic) MenuViewController *menuVC;
@property (strong, nonatomic) UIView             *cover;
@property (strong, nonatomic) UITapGestureRecognizer *tapGes;
@property (strong, nonatomic) UIPanGestureRecognizer *panGes;
@property (strong, nonatomic) UIView *markView;
@end

@implementation SliderViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sta = kStateHome;
    self.distance = 0;
    self.menuCenterXStart = ScreenWith * menuStartNarrowRatio / 2.0;
    self.menuCenterXEnd = self.view.center.x;
    self.leftDistance = ScreenWith * viewSlideHorizonRatio;
    
    // 设置背景
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
    bg.frame        = [[UIScreen mainScreen] bounds];
    //[self.view addSubview:bg];
    
    // 设置menu的view
    self.menuVC = [[MenuViewController alloc] init];
    self.menuVC.view.frame = [[UIScreen mainScreen] bounds];
    self.menuVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, menuStartNarrowRatio, menuStartNarrowRatio);
    self.menuVC.view.center = CGPointMake(self.menuCenterXStart, self.menuVC.view.center.y);
    //[self.view addSubview:self.menuVC.view];
    
    // 设置遮盖
    self.cover = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.cover.backgroundColor = [UIColor blackColor];
    //[self.view addSubview:self.cover];
    
    WorkViewController *work = [[WorkViewController alloc] init];
    //TaskViewController *task = [[TaskViewController alloc] init];
    MessageViewController *message = [[MessageViewController alloc] init];
    ContactViewController *contacts = [[ContactViewController alloc] init];
    MyViewController *my = [[MyViewController alloc] init];
    
    NSArray *controllerArray = @[work,message,contacts,my];
    NSArray *titleArray = @[@"工作",@"消息",@"联系人",@"我的"];
    NSArray *imageArray = @[@"home",@"message",@"link",@"me"];
    NSArray *selImageArray = @[@"homeHL",@"messageHL",@"linkHL",@"meHL"];
    
    /*
     创建tabBarController
     */
    
    self.tabBarController = [[LSTabBarController alloc] initWithControllerArray:controllerArray titleArray:titleArray imageArray:imageArray selImageArray:selImageArray];
    _tabbarNavigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    _tabbarNavigationController.navigationBarHidden = YES;
    
    _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGes.delegate = self;
//    [self.tabBarController.scrollView addGestureRecognizer:_panGes];
    
    [self.view addSubview:_tabbarNavigationController.view];
    
    _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self.markView addGestureRecognizer:_tapGes];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)addGesture {
    [self.markView addGestureRecognizer:_panGes];
    [self.tabBarController.view addSubview:self.markView];
}

- (void)removeGesture {
    [self.tabBarController.scrollView addGestureRecognizer:_panGes];
    [self.markView removeFromSuperview];
}

/**
 *  设置statusbar的状态
 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)tapGes:(UITapGestureRecognizer *)gesture {
    [self showHome];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

/**
 *  处理拖动事件
 *
 *  @param recognizer
 */
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    // 当滑动水平X大于75时禁止滑动
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.panStartX = [recognizer locationInView:self.view].x;
    }
    if (self.sta == kStateHome && self.panStartX >= 75) {
        self.tabBarController.scrollView.scrollEnabled = [LocalStoreData getOnLine];
        return;
    }
    
    CGFloat x = [recognizer translationInView:self.view].x;
    // 禁止在主界面的时候向左滑动
    if (self.sta == kStateHome && x < 0) {
        self.tabBarController.scrollView.scrollEnabled = [LocalStoreData getOnLine];
        return;
    }
    
    CGFloat dis = self.distance + x;
    // 当手势停止时执行操作
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (dis >= ScreenWith * viewSlideHorizonRatio / 2.0) {
            //[self showMenu];
        } else {
            [self showHome];
        }
        self.tabBarController.scrollView.scrollEnabled = [LocalStoreData getOnLine];
        return;
    }
    
    return;
    
    /*
    
    self.tabBarController.scrollView.scrollEnabled = NO;
    
    CGFloat proportion = (viewHeightNarrowRatio - 1) * dis / self.leftDistance + 1;
    if (proportion < viewHeightNarrowRatio || proportion > 1) {
        return;
    }
    _tabbarNavigationController.view.center = CGPointMake(self.view.center.x + dis, self.view.center.y);
    _tabbarNavigationController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
    
    self.cover.alpha = 1 - dis / self.leftDistance;
    
    CGFloat menuProportion = dis * (1 - menuStartNarrowRatio) / self.leftDistance + menuStartNarrowRatio;
    CGFloat menuCenterMove = dis * (self.menuCenterXEnd - self.menuCenterXStart) / self.leftDistance;
    self.menuVC.view.center = CGPointMake(self.menuCenterXStart + menuCenterMove, self.view.center.y);
    self.menuVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, menuProportion, menuProportion);
    */
}

/**
 *  展示侧边栏
 */
- (void)showMenu {
    self.distance = self.leftDistance;
    self.sta = kStateMenu;
    [self doSlide:viewHeightNarrowRatio];
    [self addGesture];
}

/**
 *  展示主界面
 */
- (void)showHome {
    self.distance = 0;
    self.sta = kStateHome;
    [self doSlide:1];
    [self removeGesture];
}

/**
 *  实施自动滑动
 *
 *  @param proportion 滑动比例
 */
- (void)doSlide:(CGFloat)proportion {
    [UIView animateWithDuration:0.3 animations:^{
        _tabbarNavigationController.view.center = CGPointMake(self.view.center.x + self.distance, self.view.center.y);
        _tabbarNavigationController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
        
        self.cover.alpha = proportion == 1 ? 1 : 0;
        
        CGFloat menuCenterX;
        CGFloat menuProportion;
        if (proportion == 1) {
            menuCenterX = self.menuCenterXStart;
            menuProportion = menuStartNarrowRatio;
        } else {
            menuCenterX = self.menuCenterXEnd;
            menuProportion = 1;
        }
        self.menuVC.view.center = CGPointMake(menuCenterX, self.view.center.y);
        self.menuVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, menuProportion, menuProportion);
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - WMHomeViewController代理方法
- (void)leftBtnClicked {
    [self showMenu];
}

#pragma mark - WMMenuViewController代理方法
- (void)didSelectItem:(NSString *)title {
    //[self.tabNav pushViewController:other animated:NO];
    [self showHome];
    
}

#pragma mark - event response

- (void)tabbarHidden {
    [self.tabBarController hide];
}
- (void)tabbarShow {
    [self.tabBarController show];
}

#pragma mark - getters & setters

- (UIView *)markView {
    
    if (!_markView) {
        _markView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWith, ScreenHeight)];
        _markView.userInteractionEnabled = YES;
        _markView.backgroundColor = [UIColor clearColor];
    }
    return _markView;
}

@end
