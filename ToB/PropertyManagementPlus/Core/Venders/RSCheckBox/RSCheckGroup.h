//
//  RSCheckGroup.h
//  RSCheckBox
//
//  Created by founderbn on 16/6/6.
//  Copyright © 2016年 founderbn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSCheckBox.h"

@protocol RSCheckGroupDelegate <NSObject>

- (void)clickWithItem:(NSInteger)item index:(NSInteger)index isAll:(BOOL)isAll isSelected:(BOOL)isSelected sender:(UIButton *)sender;

@end

@interface RSCheckGroup : UIView
@property (nonatomic, strong) NSString *selectText;
@property (nonatomic) NSInteger selectValue;
@property (nonatomic, strong) NSMutableArray *selectTextArr;
@property (nonatomic, strong) NSMutableArray *selectValueArr;
@property (nonatomic,assign) BOOL isCheck;//是否复选

@property (nonatomic, weak) id <RSCheckGroupDelegate> delegate;

- (id)initWithFrame:(CGRect)frame WithCheckBtns:(NSArray*)checkBtns;
- (void)checkboxBtnChecked:(RSCheckBox *)sender;

@end
