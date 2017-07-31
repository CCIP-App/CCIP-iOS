//
//  UIView+DashedLine.h
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/23.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DASHLINE_VIEW_ID    (@"DashedLine")

@interface UIView (DashedLine)

- (void)addDashedLine:(UIColor *)color;

@end

@interface UIView (linear_diagonal_gradient)

- (void)setGradientColor:(UIColor *)from To:(UIColor *)to StartPoint:(CGPoint)fromPoint ToPoint:(CGPoint)toPoint;

@end
