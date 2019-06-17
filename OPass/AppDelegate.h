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
#import "headers.h"
#import "RVCollection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Null_unspecified window;
@property (strong, nonatomic) id _Null_unspecified beacon;
@property (strong, readonly, nonatomic) SLColorArt * _Null_unspecified appArt;
@property (strong, nonatomic) id _Null_unspecified userInfo;
@property (readonly, nonatomic) BOOL isLoginSession;
#ifndef IN_BRIDGING_HEADER
@property (strong, nonatomic) CheckinViewController * _Null_unspecified checkinView;
#else
@property (strong, nonatomic) UIViewController * _Null_unspecified checkinView;
#endif
@property (readonly, nonatomic) NSArray * _Nullable availableScenarios;

+ (AppDelegate * _Nonnull)delegateInstance;
+ (id _Nonnull)AppConfig:( NSString * _Nonnull )path;
+ (UIColor * _Nonnull)AppConfigColor:( NSString * _Nonnull )path;
+ (void)sendTag:( NSString * _Nonnull )tag value:( NSString * _Nonnull )value;
+ (void)sendTags:( NSDictionary * _Nonnull )keyValuePair;
+ (void)sendTagsWithJsonString:( NSString * _Nonnull )jsonString;
- (void)setDefaultShortcutItems;

//+ (UIImage * _Nonnull)confLogo;

+ (void)setIsDevMode:(BOOL)isDevMode;
+ (BOOL)isDevMode;

+ (BOOL)haveAccessToken;
+ (void)setAccessToken:(NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessTokenSHA1;

- (void)displayGreetingsForLogin;
- (void)setScenarios:( NSArray * _Nonnull )scenarios;

+ (void)setLoginSession:(BOOL)isLogin;

+ (NSString * _Nonnull)currentLangUI;
+ (NSString * _Nonnull)shortLangUI;
+ (NSString * _Nullable)longLangUI;

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
