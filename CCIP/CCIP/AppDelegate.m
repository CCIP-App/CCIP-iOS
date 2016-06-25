//
//  AppDelegate.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "MasterViewController.h"
#import "DetailViewController.h"

#define ONE_SIGNAL_APP_TOKEN (@"a429ff30-5c0e-4584-a32f-b866ba88c947")

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) OneSignal *oneSignal;
@property (strong, readwrite, nonatomic) NSString *accessToken;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    if (url != nil) {
        NSLog(@"Calling from URL: %@", url);
        NSString *tokenHost = [url host];
        NSString *token = [url query];
        if ([tokenHost isEqualToString:@"token"] && [token length] > 0) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }
            
            [UICKeyChainStore setData:[[params objectForKey:@"token"] dataUsingEncoding:NSUTF8StringEncoding]
                               forKey:@"token"];
            self.accessToken = [params objectForKey:@"token"];
        }
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:ONE_SIGNAL_APP_TOKEN
                                           handleNotification:nil];
    self.accessToken = [[NSString alloc] initWithData:[UICKeyChainStore dataForKey:@"token"]
                                            encoding:NSUTF8StringEncoding];
    NSLog(@"Token: <%@>", self.accessToken);
    
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    
    MasterViewController *masterView = [[MasterViewController alloc] init];
    DetailViewController *detailView = [[DetailViewController alloc] init];
    [detailView.view setBackgroundColor:[UIColor whiteColor]];
    [detailView.navigationItem setLeftBarButtonItem:splitViewController.displayModeButtonItem];
    [detailView.navigationItem setLeftItemsSupplementBackButton:YES];
    
    UINavigationController *masterNav = [[UINavigationController alloc] initWithRootViewController:masterView];
    UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detailView];
    
    splitViewController.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    splitViewController.delegate = self;
    
    [self.window setRootViewController:splitViewController];
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

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end
