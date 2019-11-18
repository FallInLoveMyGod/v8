//
//  LSAlertViewController.h
//  自定义警告框
//
//  Created by WWT on 16/8/24.
//  Copyright © 2016年 wwt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, CKAlertViewType){
    CKAlertViewInputType = 0,
    CKAlertViewTextType = 1,
    CKAlertViewNoTextType = 2,
    CKAlertViewChangeButtonType = 3
};

@interface CKAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(CKAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;

@end


@interface LSAlertViewController : UIViewController

@property (nonatomic, readonly) NSArray<CKAlertAction *> *actions;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, assign) NSTextAlignment messageAlignment;

//自定义视图
@property (nonatomic, strong) NSArray *itemImages;
@property (nonatomic, strong) UIScrollView *contentView;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message placeHolder:(NSString *)placeHolder type:(CKAlertViewType)type;
- (void)addAction:(CKAlertAction *)action;

@end

