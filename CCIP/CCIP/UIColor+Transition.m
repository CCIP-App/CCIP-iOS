//
//  UIColor+Transition.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "UIColor+Transition.h"

@implementation UIColor (Transition)

+ (UIColor *)colorFrom:(UIColor *)from To:(UIColor *)to At:(double)location {
    CIColor *f = [CIColor colorWithCGColor:[from CGColor]];
    CIColor *t = [CIColor colorWithCGColor:[to CGColor]];
    double resultRed = f.red + location * (t.red - f.red);
    double resultGreen = f.green + location * (t.green - f.green);
    double resultBlue = f.blue + location * (t.blue - f.blue);
    double resultAlpha = f.alpha + location * (t.alpha - f.alpha);
    return [UIColor colorWithRed:resultRed
                           green:resultGreen
                            blue:resultBlue
                           alpha:resultAlpha];
}

@end
