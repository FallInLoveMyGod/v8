//
//  CompressionImage.m
//  PropertyManagementPlus
//
//  Created by jana on 17/1/13.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "CompressionImage.h"

@implementation CompressionImage

+ (NSData *)compressionImage:(UIImage*)image {
    return [CompressionImage imageWithImage:image scaledToSize:CGSizeMake(image.size.width*0.8, image.size.height*0.8)];
}

+ (NSData *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 0.3);
}

@end
