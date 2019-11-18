//
//  ActionSheet.m
//  PropertyManagementPlus
//
//  Created by jana on 16/12/30.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

#import "ActionSheet.h"

static ActionSheet *shareManager = nil;

@interface ActionSheet () <LCActionSheetDelegate>

@property (nonatomic, strong) LCActionSheet *actionSheet;

@end

@implementation ActionSheet

+ (instancetype)shareManager {
    
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        shareManager = [[ActionSheet alloc] init];
    });
    return shareManager;
}

- (void)sheetWithTitle:(NSString *)title
             cancelButtonTitle:(NSString *)cancelButtonTitle
         otherButtonTitleArray:(NSArray *)otherButtonTitleArray {
    
    if (_actionSheet && !_actionSheet.isHidden) {
        return;
    }
    
    _actionSheet = [LCActionSheet sheetWithTitle:title
                                        delegate:[ActionSheet shareManager]
                               cancelButtonTitle:cancelButtonTitle
                           otherButtonTitleArray:otherButtonTitleArray];
    _actionSheet.scrolling = YES;
    _actionSheet.visibleButtonCount = 6;
    [_actionSheet show];
}

#pragma mark - LCActionSheet Delegate

- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clickedButtonAtIndex: %d", (int)buttonIndex);
    
    if ([self.delegate respondsToSelector:@selector(actionSheet:tag:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self tag:_tag clickedButtonAtIndex:buttonIndex];
    }
}

- (void)willPresentActionSheet:(LCActionSheet *)actionSheet {
    NSLog(@"willPresentActionSheet");
    if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:self];
    }
}

- (void)didPresentActionSheet:(LCActionSheet *)actionSheet {
    NSLog(@"didPresentActionSheet");
    if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
        [self.delegate didPresentActionSheet:self];
    }
}

- (void)actionSheet:(LCActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"willDismissWithButtonIndex: %d", (int)buttonIndex);
    if ([self.delegate respondsToSelector:@selector(actionSheet:tag:willDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self tag:_tag willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)actionSheet:(LCActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"didDismissWithButtonIndex: %d", (int)buttonIndex);
    if ([self.delegate respondsToSelector:@selector(actionSheet:tag:didDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self tag:_tag didDismissWithButtonIndex:buttonIndex];
    }
    
    _actionSheet = nil;
}

@end
