//
//  UIColor+addition.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (addition)

+ (UIColor *)colorFrom:(UIColor *)from To:(UIColor *)to At:(double)location;
+ (UIColor *)colorFromHtmlColor:(NSString *)htmlColorString;

@end
