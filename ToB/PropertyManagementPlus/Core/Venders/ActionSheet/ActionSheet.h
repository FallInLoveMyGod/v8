//
//  ActionSheet.h
//  PropertyManagementPlus
//
//  Created by jana on 16/12/30.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LCActionSheet/LCActionSheet.h>

//https://github.com/iTofu/LCActionSheet

@class ActionSheet;

@protocol ActionSheetDelegate <NSObject>

@optional

/**
 *  Handle click button.
 */
- (void)actionSheet:(ActionSheet *)actionSheet tag:(NSString *)tag clickedButtonAtIndex:(NSInteger)buttonIndex;

/**
 *  Handle action sheet will present.
 */
- (void)willPresentActionSheet:(ActionSheet *)actionSheet;
/**
 *  Handle action sheet did present.
 */
- (void)didPresentActionSheet:(ActionSheet *)actionSheet;

/**
 *  Handle action sheet will dismiss.
 */
- (void)actionSheet:(ActionSheet *)actionSheet tag:(NSString *)tag willDismissWithButtonIndex:(NSInteger)buttonIndex;
/**
 *  Handle action sheet did dismiss.
 */
- (void)actionSheet:(ActionSheet *)actionSheet tag:(NSString *)tag didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end

@interface ActionSheet : NSObject

@property (nonatomic, copy) NSString *tag;
@property (nonatomic, weak) id <ActionSheetDelegate> delegate;

+ (instancetype)shareManager;

- (void)sheetWithTitle:(NSString *)title
             cancelButtonTitle:(NSString *)cancelButtonTitle
         otherButtonTitleArray:(NSArray *)otherButtonTitleArray;

@end
