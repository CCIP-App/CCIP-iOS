//
//  UISegmentedControl+addition.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "UISegmentedControl+addition.h"

@implementation UISegmentedControl (addition)

- (void)resetAllSegments:(NSArray *)segments
{
    [self removeAllSegments];
    
    for (NSString *segment in segments) {
        [self insertSegmentWithTitle:segment atIndex:self.numberOfSegments animated:NO];
    }
}


@end

