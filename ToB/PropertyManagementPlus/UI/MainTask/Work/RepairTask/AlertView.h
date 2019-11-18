//
//  AlertView.h
//  yyyy
//
//  Created by 田耀琦 on 2018/5/21.
//  Copyright © 2018年 田耀琦. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import <PropertyManagementPlus-Swift.h>

typedef void (^ChooseArea)(NSString *);

@protocol AlertViewDelegate

//- (void)tableViewDidSelectWithAreaName:(id )model;

@end

@interface AlertView : UIView

@property (nonatomic,assign)BOOL isShow;

@property (nonatomic,strong)NSArray *dataSource;

@property (nonatomic,copy)ChooseArea chooseArea;

@property (nonatomic,weak) id<AlertViewDelegate> delegate;

- (void)show ;

- (void)hidden ;

@end
