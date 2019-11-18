//
//  PeTimeLine.m
//  01-基本图形绘制
//
//  Created by peter　 on 15/10/31.
//  Copyright © 2015年 itcast. All rights reserved.
//

#import "PeTimeLine.h"

#define TimeLineColor [UIColor colorWithRed:38.0/255.0 green:143.0/255.0 blue:232.0/255.0 alpha:1.0f]

@implementation PeTimeLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
     self.backgroundColor = [UIColor clearColor];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
   
    NSInteger allCount =  [self.allSteps count];
    int nowstep = self.nowStep;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //计算高度宽度
    float height = rect.size.height*0.7/1.0;
    float width = rect.size.width/allCount;
    
    
    CGPoint aPoints[2];//坐标点
    CGContextSetLineWidth(ctx, 5.0);
    [[UIColor lightGrayColor] setStroke];
    aPoints[0] = CGPointMake(width/2 , height);//坐标1
    aPoints[1] = CGPointMake(width/2+width*(allCount-1), height);//坐标2
    
    CGContextAddLines(ctx, aPoints, 2);//添加线
    CGContextDrawPath(ctx, kCGPathStroke); //根据坐标绘制路径
    
    
    //设置完成了的颜色
    CGPoint bPoint[2];//坐标点
    [TimeLineColor setStroke];
    bPoint[0] = CGPointMake(width/2 , height);//坐标1
    bPoint[1] = CGPointMake(width/2+width*(nowstep-1), height);//坐标2
    
    CGContextAddLines(ctx, bPoint, 2);//添加线
    CGContextDrawPath(ctx, kCGPathStroke); //根据坐标绘制路径

    
    for (int i=0; i<allCount; i++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0+i*width, 0, width , rect.size.height * 0.6 / 1.0)];
        label.text = self.allSteps[i];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor blackColor]; //颜色设置
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        //画出三个点
        
        // 1.获取上下文
        
        // 2.拼接路径
        CGPoint center = CGPointMake(width/2+i*width, height);
        CGFloat radius = 8;
        
        if (i == allCount/2) {
            radius = 12;
        }
        
        CGFloat startA = 0;
        CGFloat endA = M_PI*2;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
        
        if (i >= _nowStep) {
            [[UIColor lightGrayColor] setFill];
        }else {
            [TimeLineColor setFill];  //颜色设置
        }
        
        // 3.把路径添加到上下文
        CGContextAddPath(ctx, path.CGPath);
        
        // 4.渲染上下文
        CGContextDrawPath(ctx, kCGPathFill);
        
    }
    CGContextDrawPath(ctx, kCGPathFill);

}

@end
