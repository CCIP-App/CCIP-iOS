//
//  Constants.h
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DASHLINE_VIEW_ID    (@"DashedLine")

#define BEACON_UUID         (@"014567cf-d0ef-4b74-8161-47ce52f3df64")
#define BEACON_ID           (@"OPass-Beacon")

NS_ASSUME_NONNULL_BEGIN

@interface Constants : NSObject

#pragma mark - DEFINE
+ (NSString *)beaconUUID;
+ (NSString *)beaconID;

+ (void)SendFIB:(id)fib;

+ (NSString *)WebToken:(id)patten useToken:(id)token;

+ (NSString *)DashlineViewId;

+ (NSString *)urlLogBot;
+ (NSString *)urlTelegramGroup;

#pragma mark - AppDelegate
+ (UIImage *)confLogo;
+ (void)setIsDevMode:(BOOL)isDevMode;
+ (BOOL)isDevMode;
+ (void)setDevLogo:(FBShimmeringView * _Null_unspecified)sView WithLogo:(UIImage * _Null_unspecified)logo;

+ (BOOL)haveAccessToken;
+ (void)setAccessToken:(NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessToken;
+ (NSString * _Null_unspecified)accessTokenSHA1;

+ (id _Nonnull)AppConfig:( NSString * _Nonnull )path;
+ (UIColor * _Nonnull)AppConfigColor:( NSString * _Nonnull )path;
+ (NSString * _Nonnull)AppConfigURL:( NSString * _Nonnull )path;

@end

NS_ASSUME_NONNULL_END
