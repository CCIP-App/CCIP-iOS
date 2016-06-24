//
//  AppDelegate.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"

#define ONE_SIGNAL_APP_TOKEN (@"6d125392-be34-4ab9-8e3d-c537ae5d4dd5")

@interface AppDelegate ()

@property (strong, nonatomic) OneSignal *oneSignal;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableArray *viewControllers;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:ONE_SIGNAL_APP_TOKEN
                                           handleNotification:nil];
    
    //initialize the tab bar controller
    self.tabBarController = [UITabBarController new];
    
    GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS(@"asdfasdf")];
    [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
        NSLog(@"%@", json);
        //create an array of all view controllers that will represent the tab at the bottom
        self.viewControllers = [NSMutableArray new];
        for (NSDictionary *obj in [json objectForKey:@"scenario"]) {
            UIViewController *theView = [[UIViewController alloc] initWithNibName:nil
                                                                           bundle:nil];
            [theView setTitle:[obj valueForKey:@"id"]];
            UINavigationController *theNav = [[UINavigationController alloc] initWithRootViewController:theView];
            [self.viewControllers addObject:theNav];
        }
        
        [self.tabBarController setViewControllers:self.viewControllers];
    }];
    
    [self.tabBarController setViewControllers:@[[UIViewController new]]];
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
