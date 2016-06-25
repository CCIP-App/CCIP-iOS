//
//  StatusView.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/26.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusView.h"

@interface StatusView()

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation StatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)gotoTop {
    [((UINavigationController *)[self.appDelegate.splitViewController.viewControllers firstObject]) popToRootViewControllerAnimated:YES];
}

- (void)setScenario:(NSDictionary *)scenario {
    _scenario = scenario;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
