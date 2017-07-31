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

- (void)addDashedLine:(UIColor *_Nonnull)color;

@end

@interface UIView (linear_diagonal_gradient)

- (void)sizeGradientToFit;
- (void)setGradientColor:(UIColor * _Nullable)from To:(UIColor * _Nullable)to StartPoint:(CGPoint)fromPoint ToPoint:(CGPoint)toPoint;

@end
