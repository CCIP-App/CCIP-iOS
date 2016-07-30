//
//  UIImage+addition.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "UIImage+addition.h"

@implementation UIImage (addition)

- (UIImage *)imageWithColor:(UIColor *)color1 {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
