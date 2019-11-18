//
//  MyCustonTextView.h
//  TestScrollView
//
//  Created by 田耀琦 on 2017/6/7.
//  Copyright © 2017年 田耀琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustonTextView : UITextView <UITextViewDelegate>

@property (nonatomic,strong)UILabel *placeHolderLab;

@property (nonatomic,strong)UILabel *textNumLab;

@end
