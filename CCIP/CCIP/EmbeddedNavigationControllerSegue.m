//
//  EmbeddedNavigationControllerSegue.m
//  CCIP
//
//  Created by FrankWu on 2016/8/14.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "EmbeddedNavigationControllerSegue.h"

@implementation EmbeddedNavigationControllerSegue

- (void)perform {
    [self.sourceViewController presentViewController:self.destinationViewController
                                            animated:YES
                                          completion:nil];
}

@end
