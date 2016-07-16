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
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = [UIColor colorWithRed:65/255.0 green:117/255.0 blue:5/255.0 alpha:1.0];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: titleHighlightedColor, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    // Checkin
    UIViewController *vc1 = [[UIViewController alloc] initWithNibName:@"CheckinView" bundle:[NSBundle mainBundle]];
    vc1.tabBarItem.title = NSLocalizedString(@"Checkin", nil);
    vc1.tabBarItem.image = [[UIImage imageNamed:@"icon_ios_pin"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc1.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_ios_pin_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // Schedule
    RoomLocationViewController *vc2 = [RoomLocationViewController new];
    vc2.tabBarItem.title = NSLocalizedString(@"Schedule", nil);
    vc2.tabBarItem.image = [[UIImage imageNamed:@"icon_ios_topcharts"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc2.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_ios_topcharts_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // Announce
    UIViewController *vc3 = [[UIViewController alloc] initWithNibName:@"CheckinView" bundle:[NSBundle mainBundle]];
    vc3.tabBarItem.title = NSLocalizedString(@"Announce", nil);
    vc3.tabBarItem.image = [[UIImage imageNamed:@"icon_ios_bell"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc3.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_ios_bell_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // IRC
    UIViewController *vc4 = [[UIViewController alloc] initWithNibName:@"IRCView" bundle:[NSBundle mainBundle]];
    vc4.tabBarItem.title = NSLocalizedString(@"IRC", nil);
    [NSInvocation InvokeObject:vc4.view withSelectorString:@"setURL:" withArguments:@[ @{@"url": LOG_BOT_URL} ]];
    vc4.tabBarItem.image = [[UIImage imageNamed:@"icon_ios_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc4.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_ios_chat_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // More
    UIViewController *vc5 = [[UIViewController alloc] initWithNibName:@"CheckinView" bundle:[NSBundle mainBundle]];
    vc5.tabBarItem.title = NSLocalizedString(@"More", nil);
    vc5.tabBarItem.image = [[UIImage imageNamed:@"icon_ios_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc5.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_ios_more_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self setViewControllers:@[vc1, vc2, vc3, vc4, vc5]];
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
