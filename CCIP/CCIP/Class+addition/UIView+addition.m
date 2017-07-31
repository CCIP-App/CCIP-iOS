//
//  UIView+DashedLine.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/23.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "UIView+addition.h"

@implementation UIView (DashedLine)

- (void)addDashedLine:(UIColor *)color {
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:DASHLINE_VIEW_ID]) {
            [layer removeFromSuperlayer];
        }
    }
    [self setBackgroundColor:[UIColor clearColor]];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setName:DASHLINE_VIEW_ID];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setLineWidth:self.frame.size.height];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:@[ @(5), @(5) ]];
    
    CGAffineTransform transform = self.transform;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &transform, 0, 0);
    CGPathAddLineToPoint(path, &transform, self.frame.size.width, 0);
    [shapeLayer setPath:path];
    
    [self.layer addSublayer:shapeLayer];
}

@end

@implementation UIView (linear_diagonal_gradient)

- (void)sizeGradientToFit {
    [self setGradientColor:nil
                        To:nil
                StartPoint:CGPointZero
                   ToPoint:CGPointZero];
}

- (void)setGradientColor:(UIColor * _Nullable)from To:(UIColor * _Nullable)to StartPoint:(CGPoint)fromPoint ToPoint:(CGPoint)toPoint {
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
    if (from != nil && to != nil && !CGPointEqualToPoint(CGPointZero, fromPoint) && !CGPointEqualToPoint(CGPointZero, toPoint)) {
        theViewGradient.colors = [NSArray arrayWithObjects: (id)from.CGColor, (id)to.CGColor, nil];
        theViewGradient.startPoint = fromPoint;
        theViewGradient.endPoint = toPoint;
    } else {
        theViewGradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    [self.layer insertSublayer:theViewGradient
                       atIndex:0];
}

@end
