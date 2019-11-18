//
//  SearchBarView.h
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SearchBarType){
    SearchBarTypeCar = 0,
    SearchBarTypeMaterial = 1,
    SearchBarTypeIntent = 2,
    SearchBarTypeEnergyMeter = 3
};

@protocol SearchBarViewDelegate <NSObject>
- (void)textFieldDidChange:(UITextField *)textField;
@end

@interface SearchBarView : UIView
@property (nonatomic, weak) id <SearchBarViewDelegate> delegate;
@property (nonatomic, strong) UISearchController *textSearchDisplayController;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL isCommon;
- (instancetype)initWithFrame:(CGRect)frame placeHolder:(NSString *)holder searchBarType:(SearchBarType)searchBarType;
@end
