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
    NSInteger oldIndex = [self selectedSegmentIndex];
    NSString *oldTitle = (oldIndex != -1) ? [self titleForSegmentAtIndex:oldIndex] : nil;
    [self removeAllSegments];
    
    for (int i = 0; i < [segments count]; ++i) {
        NSString *title = [segments objectAtIndex:i];
        [self insertSegmentWithTitle:title
                             atIndex:self.numberOfSegments
                            animated:NO];
        if ([title isEqualToString:oldTitle])
            [self setSelectedSegmentIndex:i];
    }
}

@end

