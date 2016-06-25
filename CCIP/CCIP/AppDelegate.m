//
//  AppDelegate.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import <Google/Analytics.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

#define ONE_SIGNAL_APP_TOKEN (@"aef99f72-9ee3-4dfa-ac5b-ddf79f16be7d")

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) OneSignal *oneSignal;
@property (strong, readwrite, nonatomic) NSString *accessToken;
@property (strong, readwrite, nonatomic) UISplitViewController *splitViewController;
@property (strong, readwrite, nonatomic) MasterViewController *masterView;
@property (strong, readwrite, nonatomic) DetailViewController *detailView;
@property (strong, readwrite, nonatomic) UINavigationController *masterNav;
@property (strong, readwrite, nonatomic) UINavigationController *detailNav;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    if (url != nil) {
        NSLog(@"Calling from URL: %@", url);
        NSString *urlHost = [url host];
        NSString *urlQuery = [url query];
        if ([urlHost isEqualToString:@"login"] && [urlQuery length] > 0) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [urlQuery componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if ([elts count] < 2) continue;
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }
            
            if ([self.accessToken length] > 0) {
                [UICKeyChainStore removeItemForKey:@"token"];
            }
            self.accessToken = [params objectForKey:@"token"];
            [UICKeyChainStore setString:self.accessToken
                                 forKey:@"token"];
            [self.masterView refreshData];
        }
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Receieved remote system fetching request...\nuserInfo => %@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    [gai setTrackUncaughtExceptions:YES];  // report uncaught exceptions
    [gai.logger setLogLevel:kGAILogLevelVerbose];  // remove before app release
    
    // Configure OneSignal
    self.oneSignal = [[OneSignal alloc]
                      initWithLaunchOptions:launchOptions
                      appId:ONE_SIGNAL_APP_TOKEN
                      handleNotification:^(NSString *message, NSDictionary *additionalData, BOOL isActive) {
                          NSLog(@"OneSignal Notification opened:\nMessage: %@\nadditionalData: %@", message, additionalData);
                          if (additionalData) {
                              // Check for and read any custom values you added to the notification
                              // This done with the "Additonal Data" section the dashbaord.
                              // OR setting the 'data' field on our REST API.
                              NSString *customKey = [additionalData objectForKey:@"customKey"];
                              if (customKey) {
                                  NSLog(@"customKey: %@", customKey);
                              }
                          }
                      }];
    [self.oneSignal enableInAppAlertNotification:YES];
    self.accessToken = [UICKeyChainStore stringForKey:@"token"];
    NSLog(@"Token: <%@>", self.accessToken);
    
    // Configure Root View Controller
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.splitViewController = [UISplitViewController new];
    self.masterView = [MasterViewController new];
    self.detailView = [DetailViewController new];
    [self.masterView setTitle:@"COSCUP 2016"];
    [self.detailView.view setBackgroundColor:[UIColor whiteColor]];
    [self.detailView.navigationItem setLeftBarButtonItem:self.splitViewController.displayModeButtonItem];
    [self.detailView.navigationItem setLeftItemsSupplementBackButton:YES];
    self.masterNav = [[UINavigationController alloc] initWithRootViewController:self.masterView];
    self.detailNav = [[UINavigationController alloc] initWithRootViewController:self.detailView];
    [self.splitViewController setViewControllers:@[self.masterNav, self.detailNav]];
    [self.splitViewController setDelegate:self];
    [self.window setRootViewController:self.splitViewController];
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
