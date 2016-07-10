//
//  AppDelegate.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import <Google/Analytics.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "GatewayWebService/GatewayWebService.h"
#import "GuideViewController.h"
#import <iRate/iRate.h>

#define ONE_SIGNAL_APP_TOKEN (@"aef99f72-9ee3-4dfa-ac5b-ddf79f16be7d")

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, readwrite, nonatomic) OneSignal *oneSignal;
@property (strong, readwrite, nonatomic) SLColorArt *appArt;

@end

@implementation AppDelegate

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 8;
    //enable preview mode
    [iRate sharedInstance].previewMode = YES;
}

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
            [self.oneSignal sendTag:@"token" value:self.accessToken];
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
    [self.oneSignal sendTag:@"token" value:self.accessToken];
    
    [self registerAppIconArt];
    
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
    BOOL hasToken = [self.accessToken length] > 0;
    UIViewController *presentedView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController];
    if (hasToken && [presentedView class] == [GuideViewController class]) {
        GuideViewController *guideVC = (GuideViewController *)presentedView;
        [guideVC.redeemCodeText setText:self.accessToken];
        double delayInSeconds = 0.75f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [guideVC dismissViewControllerAnimated:YES
                                        completion:^{
                                            [self.masterView refreshData];
                                        }];
        });
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)registerAppIconArt {
    __block NSString *appIconName = @"";
    // find the biggest icon for AppArt
    ^{
        // find biggest app icon file name
        NSDictionary *bundleDictionary = [[NSBundle mainBundle] infoDictionary];
        NSArray *bundleIcons = [bundleDictionary valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"];
        NSArray *bundleFiles = [[[NSFileManager alloc] init] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath]
                                                                                 error:nil];
        NSMutableArray *availIcon = [NSMutableArray new];
        for (NSString *iconPrefix in bundleIcons) {
            for (NSString *file in bundleFiles) {
                if ([file rangeOfString:iconPrefix
                                options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [availIcon addObject:file];
                }
            }
        }
        // find the biggest image metrix
        __block int sizeMetrix = 0;
        __block NSString *fileName = nil;
        for (NSString *iconName in availIcon) {
            NSError *error = nil;
            NSRegularExpressionOptions matchOptions = NSRegularExpressionCaseInsensitive;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([\\d]+).([\\d]+)(@[\\d]+x)*"
                                                                                   options:matchOptions
                                                                                     error:&error];
            [regex enumerateMatchesInString:iconName
                                    options:NSMatchingReportCompletion
                                      range:NSMakeRange(0, [iconName length])
                                 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                                     int width = [[iconName substringWithRange:[match rangeAtIndex:1]] intValue];
                                     int height = [[iconName substringWithRange:[match rangeAtIndex:2]] intValue];
                                     int mutiple = 1;
                                     NSRange mpRange = [match rangeAtIndex:3];
                                     if (mpRange.location != NSNotFound) {
                                         NSString *mp = [iconName substringWithRange:mpRange];
                                         mutiple = [[mp stringByReplacingOccurrencesOfString:@"@" withString:@""] intValue];
                                     }
                                     int size = width * height * mutiple;
                                     if (size > sizeMetrix) {
                                         sizeMetrix = size;
                                         fileName = iconName;
                                     }
                                 }];
        }
        appIconName = [fileName stringByDeletingPathExtension];
    }();
    [self setAppArt:[[UIImage imageNamed:appIconName] colorArt]];
    [self setAppearance:self.appArt];
}

- (void)setAppearance:(SLColorArt *)appArt {
    [[UINavigationBar appearance] setBarTintColor:[appArt backgroundColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [appArt detailColor] }];
    [[UINavigationBar appearance] setTintColor:[appArt detailColor]];
    [[UIToolbar appearance] setBarTintColor:[appArt backgroundColor]];
    [[UIToolbar appearance] setTintColor:[appArt detailColor]];
    [[UITabBar appearance] setTintColor:[appArt detailColor]];
    [[UISegmentedControl appearance] setTintColor:[appArt detailColor]];
    [[UIProgressView appearance] setTintColor:[appArt detailColor]];
    [[UILabel appearance] setTintColor:[appArt detailColor]];
    [[UIButton appearance] setTintColor:[appArt detailColor]];
    [[UISearchBar appearance] setTintColor:[appArt detailColor]];
}

@end
