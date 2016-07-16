//
//  MainTabBarViewController.m
//  CCIP
//
//  Created by Sars on 7/16/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "GatewayWebService/GatewayWebService.h"
#import "NSInvocation+addition.h"
#import "RoomLocationViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Checkin
    UIViewController *vc1 = [[UIViewController alloc] initWithNibName:@"CheckinView" bundle:[NSBundle mainBundle]];
    vc1.tabBarItem.title = NSLocalizedString(@"Checkin", nil);
    
    // Schedule
    RoomLocationViewController *vc2 = [RoomLocationViewController new];
    vc2.tabBarItem.title = NSLocalizedString(@"Schedule", nil);
    
    // Announce
    
    // IRC
    UIViewController *vc4 = [[UIViewController alloc] initWithNibName:@"IRCView" bundle:[NSBundle mainBundle]];
    vc4.tabBarItem.title = NSLocalizedString(@"IRC", nil);
    [NSInvocation InvokeObject:vc4.view
            withSelectorString:@"setURL:"
                 withArguments:@[ @{@"url": LOG_BOT_URL} ]];
    
    // More
    
    [self setViewControllers:[NSArray arrayWithObjects: vc1, vc2, vc4, nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
