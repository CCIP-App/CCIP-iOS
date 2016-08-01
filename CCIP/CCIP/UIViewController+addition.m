//
//  UIViewController+addition.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/08/01.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "UIViewController+addition.h"

@implementation UIView (addition)

- (CGFloat)topGuideHeight {
    return [((UIViewController *)self.nextResponder) topGuideHeight];
}

- (CGFloat)bottomGuideHeight {
    return [((UIViewController *)self.nextResponder) bottomGuideHeight];
}

@end

@implementation UIViewController (addition)

- (CGFloat)topGuideHeight {
    CGFloat guide = 0.0;
    if (self.navigationController.navigationBar.translucent) {
        if (self.prefersStatusBarHidden == NO) guide += 20;
        if (self.navigationController.navigationBarHidden == NO) guide += self.navigationController.navigationBar.bounds.size.height;
    }
    return guide;
}

- (CGFloat)bottomGuideHeight {
    CGFloat guide = 0.0;
    if (self.tabBarController.tabBar.hidden == NO) guide += self.tabBarController.tabBar.bounds.size.height;
    return guide;
}

@end
