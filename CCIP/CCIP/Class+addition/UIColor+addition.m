//
//  UIColor+addition.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "UIColor+addition.h"

@implementation UIColor (addition)

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

+ (UIColor *)colorFromHtmlColor:(NSString *)htmlColorString {
    NSAssert([htmlColorString hasPrefix:@"#"], @"Must prefix begin with '#'");
    NSUInteger length = [htmlColorString length];
    BOOL hasAlpha = length == 9 || length == 5;
    BOOL singleByteColor = hasAlpha ? length == 5 : length == 4;
    NSString *r = [htmlColorString substringWithRange:NSMakeRange(1 + ((singleByteColor ? 1 : 2) * (hasAlpha ? 1 : 0)), singleByteColor ? 1 : 2)];
    NSString *g = [htmlColorString substringWithRange:NSMakeRange(1 + ((singleByteColor ? 1 : 2) * (hasAlpha ? 1 : 0)) + (singleByteColor ? 1 : 2), singleByteColor ? 1 : 2)];
    NSString *b = [htmlColorString substringWithRange:NSMakeRange(1 + ((singleByteColor ? 1 : 2) * (hasAlpha ? 1 : 0)) + (singleByteColor ? 2 : 4), singleByteColor ? 1 : 2)];
    NSString *a = hasAlpha ? [htmlColorString substringWithRange:NSMakeRange(1, singleByteColor ? 1 : 2)] : (singleByteColor ? @"f" : @"ff");
    return [UIColor colorWithRed:[self HexToIntColor:r isSingleByteOnly:singleByteColor]
                           green:[self HexToIntColor:g isSingleByteOnly:singleByteColor]
                            blue:[self HexToIntColor:b isSingleByteOnly:singleByteColor]
                           alpha:[self HexToIntColor:a isSingleByteOnly:singleByteColor]];
}

+ (float)HexToIntColor:(NSString *)hex isSingleByteOnly:(BOOL)singleByte {
    NSString *h = hex;
    if (singleByte) {
        h = [h stringByAppendingString:hex];
    }
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:h];
    [scanner scanHexInt:&result];
    return result / 255.0f;
}

@end

@implementation UIView (linear_diagonal_gradient)

- (void)setGradientColor:(UIColor *)from To:(UIColor *)to StartPoint:(CGPoint)fromPoint ToPoint:(CGPoint)toPoint {
    NSString *name = @"GradientBackground";
    // Set view background linear diagonal gradient
    //   Create the gradient
    CAGradientLayer *theViewGradient = nil;
    for (CALayer *layer in [self.layer sublayers]) {
        if (layer.name == name) {
            theViewGradient = (CAGradientLayer *)layer;
            [layer removeFromSuperlayer];
            break;
        }
    }
    if (theViewGradient == nil) {
        theViewGradient = [CAGradientLayer layer];
        theViewGradient.name = name;
        theViewGradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    theViewGradient.colors = [NSArray arrayWithObjects: (id)from.CGColor, (id)to.CGColor, nil];
    theViewGradient.startPoint = fromPoint;
    theViewGradient.endPoint = toPoint;
    [self.layer insertSublayer:theViewGradient
                       atIndex:0];
}

@end
