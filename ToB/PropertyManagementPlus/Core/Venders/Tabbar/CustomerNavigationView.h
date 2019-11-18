//
//  CustomerNavigationView.h
//  ToCZhuXY
//
//  Created by Mac on 2017/10/13.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerNavigationView : UIView
- (void)reloadWithTitle:(NSString *)title;
- (void)reloadWithCustomerView:(UIView *)customerView;
- (void)removeSubView;
@end
