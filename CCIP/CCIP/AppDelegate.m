//
//  AppDelegate.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>
#import <iRate/iRate.h>
#import <iVersion/iVersion.h>
#import "UIAlertController+additional.h"
#import "UIImage+addition.h"
#import "UIColor+addition.h"
#import "AppDelegate.h"
#import "GuideViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "WebServiceEndPoint.h"
#import "NSData+PMUtils.h"

#define ONE_SIGNAL_APP_TOKEN        (@"a429ff30-5c0e-4584-a32f-b866ba88c947")
#define SCANDIT_APP_KEY             (@"2BXy4CfQi9QFc12JnjId7mHH58SdYzNC90Uo07luUUY")

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (readwrite, nonatomic) NSArray *availableDays;
@property (readwrite, nonatomic) NSArray *availableScenarios;
@property (readwrite, nonatomic) BOOL isLoginSession;
@property (strong, readwrite, nonatomic) OneSignal *oneSignal;
@property (strong, readwrite, nonatomic) SLColorArt *appArt;

@end

@implementation AppDelegate

+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (void)sendGAI:(NSDictionary *)_gai WithName:(NSString *)_name Func:(const char *)_func File:(const char *)_file Line:(int)_line {
    NSString *__file = [[NSString stringWithUTF8String:_file] stringByReplacingOccurrencesOfString:SOURCE_ROOT
                                                                                        withString:@""];
    NSLog(@"Send GAI: %@ @ %s\t%@:%d", _name, _func, __file, _line);
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (_name != nil) {
        [tracker set:kGAIScreenName
               value:_name];
    }
    [tracker send:_gai];
}

+ (void)initialize {
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 1;
    [iRate sharedInstance].usesUntilPrompt = 5;
    //enable preview mode
    [iRate sharedInstance].previewMode = NO;
    
    //configure iVersion
    //set custom BundleID
    [iVersion sharedInstance].applicationBundleID = @"org.coscup.CCIP-iOS";
    //enable preview mode
    [iVersion sharedInstance].previewMode = NO;
    
    NSLog(@"%@", [iVersion sharedInstance].appStoreCountry);
}

+ (void)setAccessToken:(NSString *)accessToken {
    [UICKeyChainStore removeItemForKey:@"token"];
    [UICKeyChainStore setString:accessToken
                         forKey:@"token"];
    [[AppDelegate appDelegate].oneSignal sendTag:@"token" value:accessToken];
    [[AppDelegate appDelegate] setDefaultShortcutItems];
}

+ (NSString *)accessToken {
    return [UICKeyChainStore stringForKey:@"token"];
}

+ (NSString *)accessTokenSHA1 {
    NSString *token = [self accessToken];
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSData *tokenDataSHA1 = [tokenData sha1Hash];
    NSString *tokenSHA1 = [[tokenDataSHA1 hexString] lowercaseString];
    return tokenSHA1;
}

+ (void)setIsDevMode:(BOOL)isDevMode {
    [[NSUserDefaults standardUserDefaults] setBool:isDevMode forKey:@"DEV_MODE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isDevMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DEV_MODE"];
}

+ (void)setDevLogo:(FBShimmeringView *)sView WithLogo:(UIImage *)logo {
    BOOL isDevMode = [AppDelegate isDevMode];
    if (isDevMode) {
        [((UIImageView *)[sView contentView]) setImage:[logo imageWithColor:[UIColor colorFromHtmlColor:@"#f2a900"]]];
    } else {
        [((UIImageView *)[sView contentView]) setImage:logo];
    }
    [sView setShimmeringSpeed:115];
    [sView setShimmering:isDevMode];
}

+ (void)setLoginSession:(BOOL)isLogin {
    [[AppDelegate appDelegate] setIsLoginSession:isLogin];
}

+ (BOOL)isBeforeEvent {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMdd"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *nowDate = [formatter dateFromString:[formatter stringFromDate:[NSDate new]]];
    NSDate *firstDate = [formatter dateFromString:[[AppDelegate appDelegate].availableDays firstObject]];
    return [nowDate timeIntervalSince1970] <= [firstDate timeIntervalSince1970];
}

+ (BOOL)isAfterEvent {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMdd"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *nowDate = [formatter dateFromString:[formatter stringFromDate:[NSDate new]]];
    NSDate *lastDate = [formatter dateFromString:[[AppDelegate appDelegate].availableDays lastObject]];
    return [nowDate timeIntervalSince1970] > [lastDate timeIntervalSince1970];
}

+ (NSDate *)firstAvailableDate {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMdd"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    if ([AppDelegate isBeforeEvent]) {
        return [formatter dateFromString:[[AppDelegate appDelegate].availableDays firstObject]];
    } else if ([AppDelegate isAfterEvent]) {
        return nil;
    } else {
        return [formatter dateFromString:[formatter stringFromDate:[NSDate new]]];
    }
}

+ (NSArray *)parseDateRange:(NSDictionary *)scenario {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMdd"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *availDate = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"available_time"] longValue]];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"expire_time"] longValue]];
    NSString *availString = [formatter stringFromDate:availDate];
    NSString *expireString = [formatter stringFromDate:expireDate];
    return @[ availString, expireString ];
}

+ (void)parseAvailableDays:(NSArray *)scenarios {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMdd"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *nowDate = [formatter dateFromString:[formatter stringFromDate:[NSDate new]]];
    NSMutableArray *aD = [NSMutableArray arrayWithArray:[AppDelegate appDelegate].availableDays];
    for (NSDictionary *scenario in scenarios) {
        [aD addObjectsFromArray:[self parseDateRange:scenario]];
    }
    aD = [NSMutableArray arrayWithArray:[[[NSOrderedSet orderedSetWithArray:[aD valueForKeyPath:@"@distinctUnionOfObjects.self"]] array] sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2) {
        return [(NSString *)o1 compare:(NSString *)o2 options:NSNumericSearch];
    }]];
    
    NSLog(@"Available date with: %@", aD);
    [[AppDelegate appDelegate] setAvailableDays:aD];
    
    NSMutableArray *newScenarios = [NSMutableArray new];
    if ([self isBeforeEvent]) {
        // always add first day data before first comes
        for (NSDictionary *scenario in scenarios) {
            NSArray *dates = [AppDelegate parseDateRange:scenario];
            if ([dates containsObject:[[AppDelegate appDelegate].availableDays firstObject]]) {
                [newScenarios addObject:scenario];
            }
        }
    } else {
        // always add now day data
        for (NSDictionary *scenario in scenarios) {
            NSArray *dates = [AppDelegate parseDateRange:scenario];
            if ([dates containsObject:[formatter stringFromDate:nowDate]]) {
                [newScenarios addObject:scenario];
            }
        }
    }
    [[AppDelegate appDelegate] setAvailableScenarios:[NSArray arrayWithArray:newScenarios]];
}

+ (BOOL)haveAccessToken {
    return ([[AppDelegate accessToken] length] > 0) ? YES : NO;
}

- (void)displayGreetingsForLogin {
    [self setIsLoginSession:NO];
    UIAlertController *ac = [UIAlertController alertOfTitle:@""
                                                withMessage:[NSString stringWithFormat:NSLocalizedString(@"LoginGreeting", nil), [self.userInfo objectForKey:@"user_id"]]
                                           cancelButtonText:NSLocalizedString(@"Okay", nil)
                                                cancelStyle:UIAlertActionStyleDestructive
                                               cancelAction:nil];
    [ac showAlert:nil];
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
            [[AppDelegate appDelegate] setIsLoginSession:YES];
            [AppDelegate setAccessToken:[params objectForKey:@"token"]];
            
            if (self.checkinView != nil) {
                [self.checkinView reloadCard];
            }
        }
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self setDefaultShortcutItems];
    NSLog(@"Receieved remote system fetching request...\nuserInfo => %@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setIsLoginSession:NO];
    [self setAvailableDays:[NSMutableArray new]];
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    [gai setTrackUncaughtExceptions:YES];  // report uncaught exceptions

#ifdef DEBUG
    [gai.logger setLogLevel:kGAILogLevelVerbose];  // remove before app release
#endif
    
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

    [AppDelegate setAccessToken:[UICKeyChainStore stringForKey:@"token"]];
    NSLog(@"User Token: <%@>", [AppDelegate accessToken]);
    
    // Provide the app key for your scandit license.
    [SBSLicense setAppKey:SCANDIT_APP_KEY];
    
    [self registerAppIconArt];
    [self setDefaultShortcutItems];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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
    [self setDefaultShortcutItems];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UIViewController *presentedView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController];
    if ([AppDelegate haveAccessToken] && [presentedView class] == [GuideViewController class]) {
        GuideViewController *guideVC = (GuideViewController *)presentedView;
        [guideVC.redeemCodeText setText:[AppDelegate accessToken]];
        double delayInSeconds = 0.75f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [guideVC dismissViewControllerAnimated:YES
                                        completion:^{
                                            // TODO: refresh card data
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
    //[[UINavigationBar appearance] setBarTintColor:[appArt backgroundColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UIButton appearanceWhenContainedIn:[UINavigationController class], nil] setTintColor:[appArt detailColor]];
    [[UIToolbar appearanceWhenContainedIn:[UINavigationController class], nil] setBarTintColor:[appArt backgroundColor]];
    
//    [[UIToolbar appearance] setTintColor:[appArt detailColor]];
    [[UITabBar appearance] setTintColor:[appArt detailColor]];
    [[UISegmentedControl appearance] setTintColor:[appArt detailColor]];
    [[UIProgressView appearance] setTintColor:[appArt detailColor]];
    [[UILabel appearance] setTintColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
//    [[UIButton appearance] setTintColor:[appArt detailColor]];
    [[UISearchBar appearance] setTintColor:[appArt detailColor]];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    // shortcutItem.type
    // shortcutItem.localizedTitle
    // shortcutItem.localizedSubtitle
    // shortcutItem.userInfo (NSDictionary*)
    
    NSInteger mainTabBarViewIndex = 0;
    if ([shortcutItem.type isEqualToString:@"Checkin"]) {
        mainTabBarViewIndex = 0;
        // TODO: switch to currect card
        [[NSUserDefaults standardUserDefaults] setObject:shortcutItem.userInfo
                                                  forKey:@"CheckinCard"];
    }
    else if ([shortcutItem.type isEqualToString:@"Schedule"]) {
        mainTabBarViewIndex = 1;
        [[NSUserDefaults standardUserDefaults] setObject:shortcutItem.localizedTitle
                                                  forKey:@"ScheduleIndexText"];
        [[NSUserDefaults standardUserDefaults] setObject:shortcutItem.userInfo
                                                  forKey:@"ScheduleData"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:mainTabBarViewIndex]
                                              forKey:@"MainTabBarViewIndex"];
    
    // Save UserDefaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SEND_GAI_EVENT(@"performActionForShortcutItem", shortcutItem.localizedTitle);
}

- (void)setDefaultShortcutItems {
//    static NSDateFormatter *formatter_full = nil;
//    if (formatter_full == nil) {
//        formatter_full = [NSDateFormatter new];
//        [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
//        [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    }
//
//    static NSDateFormatter *formatter_date = nil;
//    if (formatter_date == nil) {
//        formatter_date = [NSDateFormatter new];
//        [formatter_date setDateFormat:@"MM/dd"];
//    }
//    static NSDate *startTime;
//    static NSString *time_date;
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:CC_STATUS([AppDelegate accessToken]) parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//        if (responseObject != nil) {
//            NSDictionary *scenarios = [responseObject objectForKey:@"scenarios"];
//            [manager GET:PROGRAM_DATA_URL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//                NSLog(@"JSON: %@", responseObject);
//                if (responseObject != nil) {
//                    NSArray *programs = responseObject;
//
//                    NSMutableDictionary *datesDict = [NSMutableDictionary new];
//                    for (NSDictionary *program in programs) {
//                        startTime = [formatter_full dateFromString:[program objectForKey:@"starttime"]];
//                        time_date = [formatter_date stringFromDate:startTime];
//
//                        NSMutableArray *tempArray = [datesDict objectForKey:time_date];
//                        if (tempArray == nil) {
//                            tempArray = [NSMutableArray new];
//                        }
//                        [tempArray addObject:program];
//                        [datesDict setObject:tempArray forKey:time_date];
//                    }
//
//                    NSMutableDictionary *program_date = datesDict;
//                    NSArray *segmentsTextArray = [[program_date allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
//                    // UIApplicationShortcutIcon
//                    // UIApplicationShortcutItem
//                    if(NSClassFromString(@"UIApplicationShortcutItem")) {
//                        NSMutableArray *shortcutItems = [NSMutableArray new];
//
//                        for (NSDictionary *scenario in scenarios) {
//                            NSString *id = [scenario objectForKey:@"id"];
//                            if ([id rangeOfString:@"day" options:NSCaseInsensitiveSearch].length > 0) {
//                                NSTimeInterval available = [[NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"available_time"] doubleValue]] timeIntervalSince1970];
//                                NSTimeInterval expire = [[NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"expire_time"] doubleValue]] timeIntervalSince1970];
//                                NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
//                                if (([id rangeOfString:@"day1" options:NSCaseInsensitiveSearch].length > 0 && now <= expire) || (now >= available && now <= expire)) {
//                                    UIApplicationShortcutIconType iconType = [scenario objectForKey:@"used"] != nil
//                                    ? UIApplicationShortcutIconTypeTaskCompleted
//                                    : UIApplicationShortcutIconTypeTask;
//                                    [shortcutItems addObject:[[UIApplicationShortcutItem alloc] initWithType:@"Checkin"
//                                                                                              localizedTitle:NSLocalizedString(id, nil)
//                                                                                           localizedSubtitle:nil
//                                                                                                        icon:[UIApplicationShortcutIcon iconWithType:iconType]
//                                                                                                    userInfo:@{
//                                                                                                               @"key": id
//                                                                                                               }]];
//                                }
//                            }
//                        }
//
//                        for (NSString *dateText in segmentsTextArray) {
//                            [shortcutItems addObject:[[UIApplicationShortcutItem alloc] initWithType:@"Schedule"
//                                                                                      localizedTitle:dateText
//                                                                                   localizedSubtitle:@"議程"
//                                                                                                icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeDate]
//                                                                                            userInfo:@{
//                                                                                                       @"segmentsTextArray": segmentsTextArray,
//                                                                                                       @"program_date": program_date
//                                                                                                       }]];
//                        }
//
//                        [[UIApplication sharedApplication] setShortcutItems:shortcutItems];
//                    }
//                }
//            } failure:^(NSURLSessionTask *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//            }];
//        }
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
}

@end

@implementation UIView (AppDelegate)

+ (AppDelegate *)appDelegate {
    return [AppDelegate appDelegate];
}

- (void)registerForceTouch {
    [((UIViewController *)[self nextResponder]) registerForceTouch];
}

@end

@implementation UIViewController (AppDelegate)

+ (AppDelegate *)appDelegate {
    return [AppDelegate appDelegate];
}

- (void)registerForceTouch {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
        [self registerForPreviewingWithDelegate:(id<UIViewControllerPreviewingDelegate>)self sourceView:self.view];
    }
}

- (NSArray<id<UIPreviewActionItem>> *)previewActions {
    static NSArray<id<UIPreviewActionItem>> *previewActions;
    if (previewActions == nil) {
//        UIPreviewAction *printAction = [UIPreviewAction
//                                        actionWithTitle:@"Print"
//                                        style:UIPreviewActionStyleDefault
//                                        handler:^(UIPreviewAction * _Nonnull action,
//                                                  UIViewController * _Nonnull previewViewController) {
//                                            // ... code to handle action here
//                                        }];
//        previewActions = @[ printAction ];
        previewActions = @[];
        
    }
    return previewActions;
}

@end
