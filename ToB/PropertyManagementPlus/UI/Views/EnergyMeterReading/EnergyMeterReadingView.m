//
//  EnergyMeterReadingView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "EnergyMeterReadingView.h"
#import "BaseTool.h"

@interface EnergyMeterReadingView ()
@property (nonatomic, copy) NSArray *names;
@property (nonatomic, copy) NSArray *contents;
@end

@implementation EnergyMeterReadingView
- (instancetype)initWithFrame:(CGRect)frame names:(NSArray *)names contents:(NSArray *)contents{
    if (self = [super initWithFrame:frame]) {
        self.names = names;
        self.contents = contents;
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    CGFloat width = kWidth/(self.names.count * 1.0);
    
    for (int i = 0; i < self.names.count; i++) {
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(i * width, 0, width, self.frame.size.height)];
        
        CGFloat subWidth = width / 3.0;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, subWidth, contentView.frame.size.height)];
        nameLabel.text = self.names[i];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [contentView addSubview:nameLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.size.width + 15, 0, width - subWidth - 10, contentView.frame.size.height)];
        contentLabel.text = self.contents[i];
        contentLabel.textColor = [UIColor darkTextColor];
        contentLabel.font = [UIFont systemFontOfSize:15];
        [contentView addSubview:contentLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width - 0.5, 0, 0.5, contentView.frame.size.height)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [contentView addSubview:line];
        
        [self addSubview:contentView];
        
    }
    
}
@end
