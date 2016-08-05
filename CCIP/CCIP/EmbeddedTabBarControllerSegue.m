//
//  EmbeddedTabBarControllerSegue.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "EmbeddedTabBarControllerSegue.h"

@implementation EmbeddedTabBarControllerSegue

- (void)perform {
    __block UIView *sourceView = self.sourceViewController.view;
    __block UIView *destinationView = self.destinationViewController.view;
    CGRect frame = sourceView.frame;
    //frame.size.height -= [self.sourceViewController.bottomLayoutGuide length];
    frame.size.height += 15;
    [self.sourceViewController presentViewController:self.destinationViewController
                                            animated:YES
                                          completion:^{
                                              destinationView.superview.frame = frame;
                                              [destinationView.superview setClipsToBounds:YES];
                                          }];
}

@end
