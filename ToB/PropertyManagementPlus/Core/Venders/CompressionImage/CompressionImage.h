//
//  CompressionImage.h
//  PropertyManagementPlus
//
//  Created by jana on 17/1/13.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CompressionImage : NSObject

/**
 *   @author xiaerfei, 16-07-12 16:07:21
 *
 *   压缩图片 比例0.3 宽高 0.8
 *
 *   @param image
 *
 *   @return
 */
+ (NSData *)compressionImage:(UIImage*)image;

@end
