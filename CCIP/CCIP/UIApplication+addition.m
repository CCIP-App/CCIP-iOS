//
//  UIApplication+addition.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/08/01.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "UIApplication+addition.h"

@implementation UIApplication (addition)

+ (UIViewController *)getMostTopPresentedViewController {
    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    while ([vc presentedViewController])
        vc = [vc presentedViewController];
    return vc;
}

@end
