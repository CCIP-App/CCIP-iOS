//
//  AppDelegate.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

@import NetworkExtension;
@import UserNotifications;

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>
#import <Appirater/Appirater.h>
//#import <iRate/iRate.h>
#import <iVersion/iVersion.h>
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "GuideViewController.h"
#import "NSData+PMUtils.h"

#define SCANDIT_APP_KEY             (@"2BXy4CfQi9QFc12JnjId7mHH58SdYzNC90Uo07luUUY")

@interface AppDelegate () <UISplitViewControllerDelegate, UNUserNotificationCenterDelegate>

@property (readwrite, nonatomic) NSArray *availableScenarios;
@property (readwrite, nonatomic) BOOL isLoginSession;
@property (strong, readwrite, nonatomic) SLColorArt *appArt;

@end

@implementation AppDelegate

+ (AppDelegate *)delegateInstance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (id)AppConfig:(NSString *)path {
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"config"
                                                                                             withExtension:@"plist"]];
    config = [config valueForKeyPath:APP_NAME];
    id value = [config valueForKeyPath:path];
    return value;
}

+ (UIColor *)AppConfigColor:(NSString *)path {
    NSString *colorString = [NSString stringWithString:[self AppConfig:[NSString stringWithFormat:@"Themes.%@", path]]];
    UIColor *color = [UIColor clearColor];
    if (colorString == nil || [colorString length] == 0) {
        NSLog(@"[WARN] Config Color `%@` is empty", path);
    } else {
        color = [UIColor colorFromHtmlColor:colorString];
    }
    return color;
}

+ (void)sendTag:(NSString *)tag value:(NSString *)value {
    [OneSignal sendTag:tag
                 value:value];
}

+ (void)sendTags:(NSDictionary *)keyValuePair {
    [OneSignal sendTags:keyValuePair];
}

+ (void)sendTagsWithJsonString:(NSString *)jsonString {
    [OneSignal sendTagsWithJsonString:jsonString];
}

+ (void)sendFIB:(NSString *)_name WithEvents:(NSDictionary *)_events Func:(const char *)_func File:(const char *)_file Line:(int)_line {
    NSString *__file = [[NSString stringWithUTF8String:_file] stringByReplacingOccurrencesOfString:SOURCE_ROOT
                                                                                        withString:@""];
    NSLog(@"Send FIB: %@(%@) @ %s\t%@:%d", _name, _events, _func, __file, _line);
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (_name != nil && _events == nil) {
//        [tracker set:kGAIScreenName
//               value:_name];
        [FIRAnalytics setScreenName:_name
                        screenClass:[NSString stringWithUTF8String:_func]];
    }
    if (_events != nil) {
        [FIRAnalytics logEventWithName:_name
                            parameters:_events];
    }
//    [tracker send:_gai];
}

+ (void)initialize {
//    //configure iRate
//    [iRate sharedInstance].daysUntilPrompt = 1;
//    [iRate sharedInstance].usesUntilPrompt = 5;
//    //enable preview mode
//    [iRate sharedInstance].previewMode = NO;
    
    //configure iVersion
    //set custom BundleID
    [iVersion sharedInstance].applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
    //enable preview mode
    [iVersion sharedInstance].previewMode = NO;
    
    NSLog(@"%@", [iVersion sharedInstance].appStoreCountry);
}

+ (void)setAccessToken:(NSString *)accessToken {
    [UICKeyChainStore removeItemForKey:@"token"];
    [UICKeyChainStore setString:accessToken
                         forKey:@"token"];
    [OneSignal sendTag:@"token"
                 value:accessToken];
    [[AppDelegate delegateInstance] setDefaultShortcutItems];
}

+ (NSString *)accessToken {
    return [UICKeyChainStore stringForKey:@"token"];
}

+ (NSString *)accessTokenSHA1 {
    if ([self haveAccessToken]) {
        NSString *token = [self accessToken];
        NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
        NSData *tokenDataSHA1 = [tokenData sha1Hash];
        NSString *tokenSHA1 = [[tokenDataSHA1 hexString] lowercaseString];
        return tokenSHA1;
    } else {
        return @"";
    }
}

+ (void)setIsDevMode:(BOOL)isDevMode {
    [[NSUserDefaults standardUserDefaults] setBool:isDevMode forKey:@"DEV_MODE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isDevMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"DEV_MODE"];
}

+ (void)setLoginSession:(BOOL)isLogin {
    [[AppDelegate delegateInstance] setIsLoginSession:isLogin];
}

+ (NSDictionary *)parseScenarioType:(NSString *)id {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy/M/d"];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    }
    
    NSString *id_pattern = @"^(day(\\d+))?(\\w+)$";
    NSError *error = nil;
    NSRegularExpression *id_regex = [NSRegularExpression regularExpressionWithPattern:id_pattern
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    NSArray *id_matches = [id_regex matchesInString:id
                                            options:NSMatchingWithTransparentBounds
                                              range:NSMakeRange(0, id.length)];
    NSRange did_range = [[id_matches firstObject] rangeAtIndex:2];
    NSString *did = @"";
    if (did_range.location != NSNotFound) {
        did =  [id substringWithRange:did_range];
    }
    NSRange scenarioRange = [[id_matches firstObject] rangeAtIndex:3];
    NSString *scenarioType = [id substringWithRange:scenarioRange];
    return @{
             @"scenarioType": scenarioType,
             @"did": did
             };
}

+ (NSArray *)parseRange:(NSDictionary *)scenario {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:[self AppConfig:@"DisplayDateTimeFormat"]];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *availDate = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"available_time"] longValue]];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"expire_time"] longValue]];
    NSString *availString = [formatter stringFromDate:availDate];
    NSString *expireString = [formatter stringFromDate:expireDate];
    return @[ availString, expireString ];
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
    [ac showAlert:^{
        [UIImpactFeedback triggerFeedback:UIImpactFeedbackTypeNotificationFeedbackSuccess];
    }];
}

- (void)setScenarios:(NSArray *)scenarios {
    self.availableScenarios = scenarios;
}

+ (NSString *)currentLangUI {
    return NSLocalizedString(@"CurrentLang", nil);
}

+ (NSString *)shortLangUI {
    NSString *lang = [AppDelegate currentLangUI];
    NSString *pattern = @"^(?<major>[\\w]{2})(-(?<minor>[\\w]{2,4}))?$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:lang
                                      options:NSMatchingWithTransparentBounds
                                        range:NSMakeRange(0, lang.length)];
    return [lang substringWithRange:[[matches firstObject] rangeAtIndex:1]];
}

+ (NSString *)longLangUI {
    NSString *shortLang = [AppDelegate shortLangUI];
    NSDictionary *langMap = @{
                              @"en": @"en-US",
                              @"zh": @"zh-TW"
                              };
    return [[langMap allKeys] containsObject:shortLang] ? [langMap objectForKey:shortLang] : nil;
}
    
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        if (dynamicLink.url != nil) {
            return [self parseUniversalLinkAndURL:YES
                                         WithLink:dynamicLink.url];
        }
    } else {
        if (url != nil) {
            return [self parseUniversalLinkAndURL:YES
                                         WithLink:url];
        }
    }
    return NO;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {

    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // User did tap at remote notification
    }

    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self setDefaultShortcutItems];
    NSLog(@"Receieved remote system fetching request...\nuserInfo => %@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    // Override point for customization after application launch.
    [self setIsLoginSession:NO];
    // Configure tracker from GoogleService-Info.plist.
    [FIROptions defaultOptions].deepLinkURLScheme = [[[NSBundle mainBundle] infoDictionary] valueForKeyPathWithIndexes:@"CFBundleURLTypes[0].CFBundleURLSchemes[0]"];
    [FIRApp configure];
//    NSError *configureError;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    // Optional: configure GAI options.
//    GAI *gai = [GAI sharedInstance];
//    [gai setTrackUncaughtExceptions:YES];  // report uncaught exceptions

#ifdef DEBUG
//    [gai.logger setLogLevel:kGAILogLevelVerbose];  // remove before app release
#endif
    
    // Configure Appirater
    NSUInteger uTrackId = [[iVersion sharedInstance] appStoreID];
    NSString *trackId = [NSString stringWithFormat:@"%@",  @(uTrackId)];
    [Appirater setAppId:trackId];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];

    // Configure OneSignal
    NSString *oneSignalToken = [NSString stringWithString:[AppDelegate AppConfig:@"ogToken"]];
    
    id notificationReceiverBlock = ^(OSNotification *notification) {
        NSLog(@"Received Notification - %@", notification.payload.notificationID);
    };
    id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
        // This block gets called when the user reacts to a notification received
        OSNotificationPayload* payload = result.notification.payload;
        
        NSString* messageTitle = @"OneSignal Message";
        NSString* fullMessage = [payload.body copy];
        
        if (payload.additionalData) {
            
            if(payload.title)
                messageTitle = payload.title;
            
            NSDictionary* additionalData = payload.additionalData;
            
            if (additionalData[@"actionSelected"])
                fullMessage = [fullMessage stringByAppendingString:[NSString stringWithFormat:@"\nPressed ButtonId:%@", additionalData[@"actionSelected"]]];
        }
        NSLog(@"OneSignal Notification %@: %@", messageTitle, fullMessage);
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:messageTitle
//                                                            message:fullMessage
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Close"
//                                                  otherButtonTitles:nil, nil];
//        [alertView show];
        
    };
    id onesignalInitSettings = @{kOSSettingsKeyAutoPrompt : @YES};
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:oneSignalToken
          handleNotificationReceived:notificationReceiverBlock
            handleNotificationAction:notificationOpenedBlock
                            settings:onesignalInitSettings];

    [AppDelegate setAccessToken:[UICKeyChainStore stringForKey:@"token"]];
    NSLog(@"User Token: <%@>", [AppDelegate accessToken]);
    
    // Provide the app key for your scandit license.
    [SBSLicense setAppKey:SCANDIT_APP_KEY];
    
    [self registerAppIconArt];
    [self setDefaultShortcutItems];
    
    [self setBeacon:[iBeacon new]];

    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *))restorationHandler {
    NSLog(@"Receieved Activity URL -> %@", userActivity.webpageURL);
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                            completion:^(FIRDynamicLink * _Nullable dynamicLink, NSError * _Nullable error) {
                                                                [self parseUniversalLinkAndURL:NO
                                                                                      WithLink:[dynamicLink url]];
                                                            }];
    if (!handled) {
        // non Firbase Dynamic Link
        handled = [self parseUniversalLinkAndURL:NO
                                        WithLink:userActivity.webpageURL];
    }
    return handled;
}

- (NSDictionary *)parseQuery:(NSString *)query {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [query componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if ([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

- (bool)parseUniversalLinkAndURL:(bool)isOldScheme WithLink:(id)link {
    NSURL *url;
    if ([link isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:link];
    } else if ([link isKindOfClass:[NSURL class]]) {
        url = link;
    } else {
        NSLog(@"Failling from: %@", url);
        return NO;
    }
    NSLog(@"Calling from: %@", url);
//    NSString *urlHost = [url host];
    NSString *urlQuery = [url query];
    NSDictionary *params = [urlQuery length] > 0 ? [self parseQuery:urlQuery] : @{};
    id event_id = [params objectForKey:@"event_id"];
    id token = [params objectForKey:@"token"];
    if (!isOldScheme) {
        UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"GuideViewTokenErrorTitle", nil)
                                                    withMessage:NSLocalizedString(@"GuideViewTokenErrorDesc", nil)
                                               cancelButtonText:NSLocalizedString(@"GotIt", nil)
                                                    cancelStyle:UIAlertActionStyleCancel
                                                   cancelAction:nil];
        // from Universal Link
        if (event_id != nil && token != nil) {
            [OPassAPI DoLoginByEventId:event_id
                              withToken:token
                           onCompletion:^(BOOL success, id data, NSError *error) {
                               if (!success && data != nil) {
                                   [ac showAlert:^{
                                       [UIImpactFeedback triggerFeedback:UIImpactFeedbackTypeNotificationFeedbackError];
                                   }];
                               }
                           }];
            return YES;
        }
        if (event_id == nil && token != nil && [Constants HasSetEvent]) {
            [OPassAPI RedeemCodeForEvent:@""
                               withToken:token
                              completion:^(BOOL success, id data, NSError *error) {
                                  if (!success && data != nil) {
                                      [ac showAlert:^{
                                          [UIImpactFeedback triggerFeedback:UIImpactFeedbackTypeNotificationFeedbackError];
                                      }];
                                  }
                              }];
            return YES;
        }
    }
    [Constants OpenInAppSafariForURL:url];
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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault registerDefaults:@{ SCHEDULE_CACHE_CLEAR: @(NO), SCHEDULE_CACHE_KEY: @{} }];
    [userDefault synchronize];
    if ([[userDefault objectForKey:SCHEDULE_CACHE_CLEAR] boolValue]) {
        [userDefault setObject:@(NO)
                        forKey:SCHEDULE_CACHE_CLEAR];
        [userDefault setObject:@{}
                        forKey:SCHEDULE_CACHE_KEY];
        [userDefault synchronize];
    }
    
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
        __block NSString *fileName = @"";
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
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[ [UINavigationController class] ]] setTintColor:[AppDelegate AppConfigColor:@"NavigationIndicatorColor"]];

    id imagePickerNavBarAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ [UIImagePickerController class] ]];
    [imagePickerNavBarAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] }];
    [imagePickerNavBarAppearance setTintColor:Constants.tintColor];
    id imagePickerBarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[ [UIImagePickerController class] ]];
    [imagePickerBarButtonItemAppearance setTintColor:Constants.tintColor];
    id imagePickerButtonAppearance = [UIButton appearanceWhenContainedInInstancesOfClasses:@[ [UIImagePickerController class] ]];
    [imagePickerButtonAppearance setTintColor:Constants.tintColor];

    [[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[ [UINavigationController class] ]] setBarTintColor:[appArt backgroundColor]];

    [[UITabBar appearance] setTintColor:[AppDelegate AppConfigColor:@"LabelTextColor"]];
    [[UISegmentedControl appearance] setTintColor:[AppDelegate AppConfigColor:@"LabelTextColor"]];
    [[UIProgressView appearance] setTintColor:[AppDelegate AppConfigColor:@"LabelTextColor"]];
    [[UILabel appearance] setTintColor:[AppDelegate AppConfigColor:@"LabelTextColor"]];
    [[UISearchBar appearance] setTintColor:[AppDelegate AppConfigColor:@"LabelTextColor"]];
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
    
    SEND_FIB_EVENT(@"performActionForShortcutItem", @{@"Title": shortcutItem.localizedTitle});
}

- (void)setDefaultShortcutItems {
    [[UIApplication sharedApplication] setShortcutItems:@[]];
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
    return [AppDelegate delegateInstance];
}

- (void)registerForceTouch {
    [((UIViewController *)[self nextResponder]) registerForceTouch];
}

@end

@implementation UIViewController (AppDelegate)

+ (AppDelegate *)appDelegate {
    return [AppDelegate delegateInstance];
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
