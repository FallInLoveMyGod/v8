//
//  UIColor+HexString.m
//  Pra
//
//  Created by 田耀琦 on 2017/5/24.
//  Copyright © 2017年 田耀琦. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha {
    NSString *cStr = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cStr length] <= 6) {
        return [UIColor clearColor];
    }
    
    // 判断前缀
    if ([cStr hasPrefix:@"0x"]) {
        cStr = [cStr substringFromIndex:2];
    }
    if ([cStr hasPrefix:@"#"]) {
        cStr = [cStr substringFromIndex:1];
    }
    
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *redStr = [cStr substringWithRange:range];
    
    range.location = 2;
    NSString *greenStr = [cStr substringWithRange:range];
    
    range.location = 4;
    NSString *blueStr = [cStr substringWithRange:range];
        
    unsigned int r, g, b;
    [[NSScanner scannerWithString:redStr] scanHexInt:&r];
    [[NSScanner scannerWithString:greenStr] scanHexInt:&g];
    [[NSScanner scannerWithString:blueStr] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}



@end
