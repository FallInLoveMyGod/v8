//
//  WarehouseInOutContentView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/6/6.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "WarehouseInOutContentView.h"
#import "PropertyManagementPlus-Swift.h"

@interface WarehouseInOutContentView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation WarehouseInOutContentView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    self.contentTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    self.contentTableView.estimatedRowHeight = 0;
    self.contentTableView.estimatedSectionHeaderHeight = 0;
    self.contentTableView.estimatedSectionFooterHeight = 0;
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self addSubview:self.contentTableView];
}

- (void)reloadDataWithDataSource:(NSMutableArray *)dataSource {
    self.dataSource = [NSMutableArray arrayWithArray:dataSource];
    [self.contentTableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"cellID";
    
    WareHouseGoodListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"WareHouseGoodListTableViewCell" owner:self options:nil][0];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        cell.contentView.userInteractionEnabled = YES;
        [cell.contentView addGestureRecognizer:longPress];
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDelete(longPress:)))
//        cell?.contentView.isUserInteractionEnabled = true
//        cell?.contentView.addGestureRecognizer(longPress)
    }
    cell.contentView.tag = 1000 + indexPath.row;
    NSDictionary *info = self.dataSource[indexPath.row];
    cell.code.text = info[@"Code"] ? info[@"Code"] :@"未知";
    cell.name.text = info[@"Name"] ? info[@"Name"] :@"未知";
    cell.price.text = [NSString stringWithFormat:@"单价 %@",(info[@"Price"] ? info[@"Price"] :@"未知")];
    cell.number.text = [NSString stringWithFormat:@"数量 %@",(info[@"Num"] ? info[@"Num"] :@"未知")];
    cell.amount.text = [NSString stringWithFormat:@"金额 %@",(info[@"Amount"] ? info[@"Amount"] :@"未知")];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(subTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate subTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    NSInteger selectIndex = longPress.view.tag;
    if ([self.delegate respondsToSelector:@selector(longPressWithIndex:)]) {
        [self.delegate longPressWithIndex:selectIndex - 1000];
    }
}
@end
