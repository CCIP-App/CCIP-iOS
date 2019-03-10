//
//  AppDelegate.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

@import Firebase;
#ifndef IN_BRIDGING_HEADER
#import <OPass-Swift.h>
#endif
#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>
#import <ColorArt/UIImage+ColorArt.h>
#import <Shimmer/FBShimmeringView.h>
#import "NSInvocation+addition.h"
#import "CheckinViewController.h"
#import "headers.h"
#import "FeedbackType.h"
#import "RVCollection.h"

#define STRINGIZE(x)                    #x
#define STRINGIZE2(x)                   STRINGIZE(x)
#define SOURCE_ROOT                     @ STRINGIZE2(SRC_ROOT)
#define __FIB(name, events)             ([AppDelegate sendFIB:name WithEvents:events Func:__func__ File:__FILE__ Line:__LINE__])
#define SEND_FIB(name)                  (__FIB( name, nil ))
#define SEND_FIB_EVENT(nibName, events) (__FIB( nibName, events ))
#define X_TOP(X, NX)                    ([[UIScreen mainScreen] bounds].size.height == 812.0f ? X : NX)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Null_unspecified window;
@property (strong, nonatomic) id _Null_unspecified beacon;
@property (strong, readonly, nonatomic) SLColorArt * _Null_unspecified appArt;
@property (strong, nonatomic) NSDictionary * _Null_unspecified userInfo;
@property (readonly, nonatomic) BOOL isLoginSession;
@property (strong, nonatomic) CheckinViewController * _Null_unspecified checkinView;
@property (readonly, nonatomic) NSArray * _Null_unspecified availableScenarios;

+ (AppDelegate * _Nonnull)delegateInstance;
+ (id _Nonnull)AppConfig:( NSString * _Nonnull )path;
+ (UIColor * _Nonnull)AppConfigColor:( NSString * _Nonnull )path;
+ (void)sendTag:( NSString * _Nonnull )tag value:( NSString * _Nonnull )value;
+ (void)sendTags:( NSDictionary * _Nonnull )keyValuePair;
+ (void)sendTagsWithJsonString:( NSString * _Nonnull )jsonString;
+ (void)sendFIB:( NSString * _Nonnull )_name WithEvents:( NSDictionary * _Nullable )_events Func:( const char * _Nonnull )_func File:( const char * _Nonnull )_file Line:(int)_line;
- (void)setDefaultShortcutItems;

//+ (UIImage * _Nonnull)confLogo;

+ (void)setIsDevMode:(BOOL)isDevMode;
+ (BOOL)isDevMode;

+ (NSArray * _Null_unspecified)parseRange:(NSDictionary * _Nonnull)scenario;
+ (BOOL)haveAccessToken;
+ (void)setAccessToken:(NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessTokenSHA1;

- (void)displayGreetingsForLogin;
- (void)setScenarios:( NSArray * _Nonnull )scenarios;

+ (void)setDevLogo:(FBShimmeringView * _Null_unspecified)sView WithLogo:(UIImage * _Null_unspecified)logo;
+ (void)setLoginSession:(BOOL)isLogin;
+ (NSDictionary * _Null_unspecified)parseScenarioType:(NSString * _Nonnull)id;

+ (NSString * _Nonnull)currentLangUI;
+ (NSString * _Nonnull)shortLangUI;
+ (NSString * _Nullable)longLangUI;

+ (void)triggerFeedback:(FeedbackType)feedbackType;

@end

@interface UIView (AppDelegate)

+ (AppDelegate * _Nonnull)appDelegate;
- (void)registerForceTouch;

@end

@interface UIViewController (AppDelegate)

+ (AppDelegate * _Nonnull)appDelegate;
- (void)registerForceTouch;
- (NSArray<id<UIPreviewActionItem>> * _Null_unspecified)previewActions;

@end
