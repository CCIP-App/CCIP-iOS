//
//  AppDelegate.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>
#import <ColorArt/UIImage+ColorArt.h>
#import <Google/Analytics.h>
#import <Shimmer/FBShimmeringView.h>
#import "UIApplication+addition.h"
#import "UIViewController+addition.h"
#import "NSInvocation+addition.h"
#import "CheckinViewController.h"

#define STRINGIZE(x)                    #x
#define STRINGIZE2(x)                   STRINGIZE(x)
#define SOURCE_ROOT                     @ STRINGIZE2(SRC_ROOT)
#define __GAI(gai, name)                ([AppDelegate sendGAI:gai WithName:name Func:__func__ File:__FILE__ Line:__LINE__])
#define SEND_GAI(name)                  (__GAI( [[GAIDictionaryBuilder createScreenView] build], name ))
#define SEND_GAI_EVENT(name, nibName)   (__GAI( [[GAIDictionaryBuilder createEventWithCategory:name action:nibName label:nil value:nil] build], nil ))

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Null_unspecified window;
@property (strong, readonly, nonatomic) OneSignal * _Null_unspecified oneSignal;
@property (strong, readonly, nonatomic) SLColorArt * _Null_unspecified appArt;
@property (strong, nonatomic) NSDictionary * _Null_unspecified userInfo;
@property (readonly, nonatomic) BOOL isLoginSession;
@property (strong, nonatomic) CheckinViewController * _Null_unspecified checkinView;
@property (readonly, nonatomic) NSArray * _Null_unspecified availableDays;
@property (readonly, nonatomic) NSArray * _Null_unspecified availableScenarios;

+ (AppDelegate * _Nonnull)appDelegate;
+ (void)sendGAI:( NSDictionary * _Nonnull )_gai WithName:( NSString * _Nullable )_name Func:( const char * _Nonnull )_func File:( const char * _Nonnull )_file Line:(int)_line;
- (void)setDefaultShortcutItems;

+ (void)setIsDevMode:(BOOL)isDevMode;
+ (BOOL)isDevMode;

+ (BOOL)haveAccessToken;
+ (void)setAccessToken:(NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessToken;

- (void)displayGreetingsForLogin;

+ (void)setDevLogo:(FBShimmeringView * _Null_unspecified)sView;
+ (void)setLoginSession:(BOOL)isLogin;
+ (BOOL)isBeforeEvent;
+ (BOOL)isAfterEvent;
+ (NSDate * _Nullable)firstAvailableDate;
+ (void)parseAvailableDays:(NSArray * _Null_unspecified)scenarios;

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
