//
//  UIView+Additions.m
//  
//
//  Created by 二哥 on 14-10-7.
//  Copyright (c) 2014年 xiaerfei. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (UIViewController *)viewController
{
    UIResponder *next = [self nextResponder];
    do {
        //UIViewController
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

- (UINavigationController *)navigationController
{
    UIResponder *next = [self nextResponder];
    do {
        //UIViewController
        if ([next isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}


- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    return nil;
}

- (UITableViewCell *)firstResponderCell
{
    if ([self isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)self;
    }
    if (self.superview) {
        UITableViewCell *tableViewCell = [self.superview firstResponderCell];
        if (tableViewCell != nil) {
            return tableViewCell;
        }
    }
    return nil;
}





@end
