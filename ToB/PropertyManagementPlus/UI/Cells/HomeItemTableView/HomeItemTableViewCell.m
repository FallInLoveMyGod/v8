//
//  HomeItemTableViewCell.m
//  支付宝跟新demo
//
//  Created by wwt on 16/8/24.
//  Copyright © 2016年 zgy_smile. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "HomeItemTableViewCell.h"
#import <HandyJSON/HandyJSON.h>

#define ScreenWith [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height


@interface HomeItemTableViewCell ()

@property (strong,nonatomic) NSDictionary * plistRootDictionary;
@property (strong,nonatomic) NSMutableArray * titles,*iconPaths,*jumpTitles;
@property (strong,nonatomic) NSMutableArray *roles;

@property (nonatomic, assign) NSInteger lineNumber;
@property (nonatomic, assign) NSInteger showType;
@property (nonatomic, strong) NSMutableArray *sortArray;

@end

@implementation HomeItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithFrame:(CGRect)frame lineNumber:(NSInteger)lineNumber roles:(NSMutableArray *)roles type:(NSInteger)type{
    
    if (self = [super initWithFrame:frame]) {
        
        self.lineNumber = lineNumber;
        self.showType = type;
        self.roles = [NSMutableArray arrayWithArray:roles];
        
        //加载plist文件
        
        NSMutableArray *iconNames = [[NSMutableArray alloc] initWithCapacity:20];
        
        NSString * sFiles = [[NSBundle mainBundle] pathForResource:@"HomeItemViewIcons.bundle/HomeIcons" ofType:@"plist"];
        NSString * moreFiles = [[NSBundle mainBundle] pathForResource:@"HomeItemViewIcons.bundle/MoreIcons" ofType:@"plist"];
        
        [iconNames addObjectsFromArray:[NSDictionary dictionaryWithContentsOfFile:sFiles].allValues];
        [iconNames addObjectsFromArray:[NSDictionary dictionaryWithContentsOfFile:moreFiles].allValues];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
        
        for (NSString *tempName in iconNames) {
            
            [tempArray addObject:[tempName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_@"]][1]];
            
        }
        
        iconNames = [NSMutableArray arrayWithArray:tempArray];
        
        if (self.showType == -1) {
            sFiles = moreFiles;
        }
        
        if (sFiles) {
            self.plistRootDictionary=[NSDictionary dictionaryWithContentsOfFile:sFiles];
        }
        
        self.titles= [[NSMutableArray alloc]init];
        self.iconPaths= [[NSMutableArray alloc]init];
        self.jumpTitles = [[NSMutableArray alloc] init];
        
        //根据排序数组排序结果
        
        NSString *pathResource = @"HomeItemViewIcons.bundle/HomeNameSort";
        
        if (self.showType == -1) {
            pathResource = @"HomeItemViewIcons.bundle/MoreNameSort";
        }
        
        _sortArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:pathResource ofType:@"plist"]];
        
        [_sortArray removeAllObjects];
        
        NSMutableArray *tempIcons = [[NSMutableArray alloc] initWithCapacity:20];
        
        NSInteger startIndex = 7;
        
        if (self.showType == -1) {
            //显示更多
            startIndex = self.roles.count;
        }else {
            //首页
            
            if (self.roles.count <= 8) {
                startIndex = self.roles.count;
            }
        }
        
        for (int i = 0; i < startIndex; i ++) {
            NSDictionary *tempDict = self.roles[i];
            NSString *nameStr = [tempDict[@"Name"] componentsSeparatedByString:@"."][0];
            [_sortArray addObject:nameStr];
            
            if ([iconNames containsObject:[tempDict[@"Code"] lowercaseString]]) {
                [tempIcons addObject:[tempDict[@"Code"] lowercaseString]];
            }else {
                [tempIcons addObject:@"ic_launcher-web@2x.png"];
            }
            
        }
        
        for (int i = 0; i < _sortArray.count; i ++) {
            
            [self.titles addObject:_sortArray[i]];
            [self.iconPaths addObject:[NSString stringWithFormat:@"index_%@@2x.png",tempIcons[i]]];
            [self.jumpTitles addObject:tempIcons[i]];
        }
        
        if (startIndex == 7 && type != -1) {
            [self.titles addObject:@"更多"];
            [self.iconPaths addObject:@"index_more@2x.png"];
            [self.jumpTitles addObject:@"more"];
        }
        
        if (self.roles.count != 0) {
            [self addSubviews];
        }
    }
    return self;
}

- (void)addSubviews {
    
    NSInteger number = (_lineNumber <= (self.titles.count/4 - 1)) ? 4: self.titles.count%4;
    
    for (int i=0; i< number; i++) {
        HomeItemViewIconButton *fg_tableViewIconButton = [[HomeItemViewIconButton alloc] initWithFrame:CGRectMake((ScreenWith/4)*i, 0, ScreenWith/4, 90.0)];
        //fg_tableViewIconButton.dataSource = self;
        fg_tableViewIconButton.tag = 4 * _lineNumber + i;
        
        if (self.titles.count <= 4 * _lineNumber + i) {
            break;
        }
        
        fg_tableViewIconButton.titleName = self.titles[4 * _lineNumber + i];
        fg_tableViewIconButton.iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"HomeItemViewIcons.bundle/%@",self.iconPaths[4 * _lineNumber + i]]];
        [fg_tableViewIconButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:fg_tableViewIconButton];
        
//        //设置下面的边框
//        UILabel * tempLabel=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWith/4)*i, 90.0, ScreenWith/4.0, 0.5)];
//        tempLabel.backgroundColor=[UIColor colorWithRed:235./255 green:235./255 blue:235./255 alpha:1];
//        [self.contentView addSubview:tempLabel];
    }
    
    
//    //设置右边的竖线边框
//    for (int i=1; i<=3; i++) {
//        UILabel * tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(ScreenWith/4.0*i+0.5, 0, 0.5, 90.0)];
//        tempLabel.backgroundColor=[UIColor colorWithRed:235./255 green:235./255 blue:235./255 alpha:1];
//        [self.contentView addSubview:tempLabel];
//    }
    
}

#pragma mark - event response

- (void)clickItem:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(clickItem:)]) {
        [self.delegate clickItem:self.jumpTitles[sender.tag]];
    }
    
}

#pragma mark Fg_tableViewIconButtonDataSource

-(UIImage *)setIcon{
    static int  i=0;
    
    NSString * s=[NSString stringWithFormat:@"HomeItemViewIcons.bundle/%@",self.iconPaths[i++ % self.iconPaths.count]];
    UIImage * img= [UIImage imageNamed:s];
    UIImage * scaledimg=[UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:img.imageOrientation];
    
    return  scaledimg;
}

-(NSString *)setIconTitle{
    static int i=0;
    
    return self.titles[i++ % self.titles.count];
}

@end
