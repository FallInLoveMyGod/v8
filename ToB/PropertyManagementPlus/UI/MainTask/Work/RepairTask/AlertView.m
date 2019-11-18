//
//  AlertView.m
//  yyyy
//
//  Created by 田耀琦 on 2018/5/21.
//  Copyright © 2018年 田耀琦. All rights reserved.
//

#import "AlertView.h"
#import <PropertyManagementPlus-Swift.h>
@interface AlertView() <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *mytable;

@end

@implementation AlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;
}

#pragma mark - UI
- (void)creatUI {
    self.backgroundColor = [UIColor grayColor];
    self.alpha = 0;
    [self addSubview:self.mytable];
}

- (UITableView *)mytable {
    if (!_mytable) {
        _mytable = [[UITableView alloc] initWithFrame:CGRectMake(80, 50, [UIScreen mainScreen].bounds.size.width - 80, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _mytable.delegate = self;
        _mytable.dataSource = self;
    }
    return _mytable;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    HouseStructureModel *model = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
//    cell.textLabel.text = model.Name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    HouseStructureModel *model = self.dataSource[indexPath.row];
    [self hidden];
    if (self.chooseArea) {
        self.chooseArea(@"abc");
    }
//    [self.delegate tableViewDidSelectWithAreaName:model];
}

#pragma mark - Metohd
- (void)show {
    self.isShow = YES;
    [UIView animateWithDuration:0.6 animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        self.alpha = 0.1;
    }];
}

- (void)hidden {
    self.isShow = NO;
    [UIView animateWithDuration:0.6 animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y , self.frame.size.width, self.frame.size.height)];
        self.alpha = 0;
    }];
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isShow) {
        [self hidden];
    }
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [self.mytable reloadData];
//    HouseStructureModel

}

@end
