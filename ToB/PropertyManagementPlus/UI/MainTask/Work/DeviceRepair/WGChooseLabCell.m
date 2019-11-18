//
//  WGChooseLabCell.m
//  property_v9
//
//  Created by 田耀琦 on 2018/5/13.
//  Copyright © 2018年 田耀琦. All rights reserved.
//

#import "WGChooseLabCell.h"

@implementation WGChooseLabCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithIndexPath:(NSIndexPath *)indexPath withModel:(id )model {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.contentLab.text = @"shima";
        }
    }
    
}

- (IBAction)chooseBtn:(id)sender {
    if (self.chooseContent) {
        self.chooseContent();
    }
}



@end
