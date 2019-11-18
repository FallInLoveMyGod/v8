//
//  ManagementIndexFilterView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/12.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "ManagementIndexFilterView.h"
#import "ManagementIndexFilterButtonView.h"
#import "BaseTool.h"

@interface ManagementIndexFilterView () <UITableViewDelegate,UITableViewDataSource,ManagementIndexFilterDelegate>

@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, assign) NSInteger numberSections;
@property (nonatomic, strong) NSMutableArray *tableCategorys;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) NSMutableArray *builds;
@property (nonatomic, strong) NSMutableArray *floors;
@property (nonatomic, strong) NSMutableArray *rooms;
@property (nonatomic, strong) NSMutableDictionary *filterDictionary;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSMutableArray *selectArray;
@end

@implementation ManagementIndexFilterView

- (instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type{
    if (self = [super initWithFrame:frame]) {
        
        self.type = type;
        self.selectArray = [NSMutableArray arrayWithObjects:@"-1",@"-1",@"-1",@"-1",@"-1",@"-1", nil];
        self.filterDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"MeterKind",@"",@"PProjectName",@"",@"PBuildingName",@"",@"PFloorName",@"",@"PRoomName", nil];
        
        self.builds = [NSMutableArray arrayWithCapacity:20];
        self.floors = [NSMutableArray arrayWithCapacity:20];
        self.rooms = [NSMutableArray arrayWithCapacity:20];
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.numberSections = 1;
        
        NSArray *source = [EnergyMeterReadingModel findByCriteriaSQL:[NSString stringWithFormat:@"SELECT DISTINCT MeterKind FROM EnergyMeterReadingModel WHERE TYPE = '%@'",@(type)]];
        self.tableCategorys = [NSMutableArray arrayWithCapacity:20];
        for (EnergyMeterReadingModel *model in source) {
            [self.tableCategorys addObject:model.MeterKind];
        }
        
        source = [EnergyMeterReadingModel findByCriteriaSQL:[NSString stringWithFormat:@"SELECT DISTINCT PProjectName FROM EnergyMeterReadingModel WHERE TYPE = '%@'",@(type)]];
        
        self.projects = [NSMutableArray arrayWithCapacity:20];
        for (EnergyMeterReadingModel *model in source) {
            [self.projects addObject:model.PProjectName];
        }

        if (self.projects.count != 0) {
            self.numberSections ++;
        }
        
        _contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, frame.size.height - 30) style:UITableViewStyleGrouped];
        self.contentTableView.estimatedRowHeight = 0;
        self.contentTableView.estimatedSectionHeaderHeight = 0;
        self.contentTableView.estimatedSectionFooterHeight = 0;
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        [self addSubview:_contentTableView];
    }
    return self;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.numberSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *caculateArray = @[];
    if (indexPath.section == 0) {
        caculateArray = self.tableCategorys;
    }else if (indexPath.section == 1) {
        caculateArray = self.projects;
    }else if (indexPath.section == 2) {
        caculateArray = self.builds;
    }else if (indexPath.section == 3) {
        caculateArray = self.floors;
    }else if (indexPath.section == 4) {
        caculateArray = self.rooms;
    }
    
    CGFloat height = [ManagementIndexFilterButtonView fetchCellHeightWithTitles:caculateArray width:self.frame.size.width - 10] + 20;
    if (height < 40.0) {
        height = 40.0;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width, 30)];
    contentLabel.font = [UIFont systemFontOfSize:16];
    [backView addSubview:contentLabel];
    
    if (section == 0) {
        contentLabel.text = @"表类型";
    }else if (section == 1) {
        contentLabel.text = @"楼盘";
    }else if (section == 2) {
        contentLabel.text = @"楼阁";
    }else if (section == 3) {
        contentLabel.text = @"楼层";
    }else if (section == 4) {
        contentLabel.text = @"房间";
    }
    
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSArray *caculateArray = @[];
    if (indexPath.section == 0) {
        caculateArray = self.tableCategorys;
    }else if (indexPath.section == 1) {
        caculateArray = self.projects;
    }else if (indexPath.section == 2) {
        caculateArray = self.builds;
    }else if (indexPath.section == 3) {
        caculateArray = self.floors;
    }else if (indexPath.section == 4) {
        caculateArray = self.rooms;
    }
    
    CGFloat height = [ManagementIndexFilterButtonView fetchCellHeightWithTitles:caculateArray width:self.frame.size.width - 10] + 20;
    if (height < 40.0) {
        height = 40.0;
    }
    
    NSInteger selectIndex = [self.selectArray[indexPath.section] intValue];
    
    for (UIView *subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[ManagementIndexFilterButtonView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    //[[cell.contentView viewWithTag:20000 + indexPath.section] removeFromSuperview];
    
    ManagementIndexFilterButtonView *view = [[ManagementIndexFilterButtonView alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 10, height) titles:caculateArray];
    [view reloadDataWithIndex:selectIndex];
    view.delegate = self;
    view.tag = 20000 + indexPath.section;
    [cell.contentView addSubview:view];
    
    return cell;
}

#pragma mark - ManagementIndexFilterDelegate

- (void)selectItemSection:(NSInteger)section index:(NSInteger)index {
    
    self.selectArray[section] = [NSString stringWithFormat:@"%d",index];
    
    if (section == 0) {
        self.filterDictionary[@"MeterKind"] = self.tableCategorys[index];
        
    }else if (section == 1) {
        self.filterDictionary[@"PProjectName"] = self.projects[index];
        
        if (self.numberSections >= 3) {
            self.numberSections = 2;
        }
        
        //查找
        self.filterDictionary[@"PBuildingName"] = @"";
        self.filterDictionary[@"PFloorName"] = @"";
        self.filterDictionary[@"PRoomName"] = @"";
        [self.builds removeAllObjects];
        [self.floors removeAllObjects];
        [self.rooms removeAllObjects];
        
        NSArray *source = [EnergyMeterReadingModel findByCriteriaSQL:[NSString stringWithFormat:@"SELECT DISTINCT PBuildingName FROM EnergyMeterReadingModel WHERE TYPE = '%@' AND PProjectName = '%@'",@(self.type),self.filterDictionary[@"PProjectName"]]];
        self.builds = [NSMutableArray arrayWithCapacity:20];
        for (EnergyMeterReadingModel *model in source) {
            [self.builds addObject:model.PBuildingName];
        }
        self.numberSections ++;
        
    }else if (section == 2) {
        
        self.filterDictionary[@"PBuildingName"] = self.builds[index];
        
        if (self.numberSections >= 4) {
            self.numberSections = 3;
        }
        
        //查找
        self.filterDictionary[@"PFloorName"] = @"";
        self.filterDictionary[@"PRoomName"] = @"";
        [self.floors removeAllObjects];
        [self.rooms removeAllObjects];
        
        NSArray *source = [EnergyMeterReadingModel findByCriteriaSQL:[NSString stringWithFormat:@"SELECT DISTINCT PFloorName FROM EnergyMeterReadingModel WHERE TYPE = '%@' AND PBuildingName = '%@'",@(self.type),self.filterDictionary[@"PBuildingName"]]];
        self.floors = [NSMutableArray arrayWithCapacity:20];
        for (EnergyMeterReadingModel *model in source) {
            [self.floors addObject:model.PFloorName];
        }
        self.numberSections ++;
        
    }else if (section == 3) {
        
        self.filterDictionary[@"PFloorName"] = self.floors[index];
        
        if (self.numberSections >= 5) {
            self.numberSections = 4;
        }
        
        //查找
        self.filterDictionary[@"PRoomName"] = @"";
        [self.rooms removeAllObjects];
        
        NSArray *source = [EnergyMeterReadingModel findByCriteriaSQL:[NSString stringWithFormat:@"SELECT DISTINCT PRoomName FROM EnergyMeterReadingModel WHERE TYPE = '%@' AND PFloorName = '%@'",@(self.type),self.filterDictionary[@"PFloorName"]]];
        self.rooms = [NSMutableArray arrayWithCapacity:20];
        for (EnergyMeterReadingModel *model in source) {
            [self.rooms addObject:model.PRoomName];
        }
        self.numberSections ++;
        
        
    }else {
        self.filterDictionary[@"PRoomName"] = self.rooms[index];
    }
    [self.contentTableView reloadData];
    if ([self.delegate respondsToSelector:@selector(selectFilterWithResultDict:)]) {
        [self.delegate selectFilterWithResultDict:self.filterDictionary];
    }
}

- (void)reloadData {
    [self.selectArray removeAllObjects];
    self.numberSections = 2;
    [self.contentTableView reloadData];
}

@end
