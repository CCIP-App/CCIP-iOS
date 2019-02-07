//
//  Constants.m
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "WebServiceEndPoint.h"

@implementation Constants

#pragma mark - DEFINE
+ (NSString *)beaconUUID {
    return BEACON_UUID;
}
+ (NSString *)beaconID {
    return BEACON_ID;
}

+ (void)SendFIB:(id)fib {
    SEND_FIB(fib);
}

+ (NSString *)WebToken:(id)patten useToken:(id)token {
    return WEB_TOKEN(patten, token);
}

+ (NSString *)DashlineViewId {
    return DASHLINE_VIEW_ID;
}

+ (NSString *)urlLogBot {
    return LOG_BOT_URL;
}

+ (NSString *)urlTelegramGroup {
    return TELEGRAM_GROUP_URL;
}

#pragma mark - AppDelegate
+ (id)confLogo {
    return [AppDelegate confLogo];
}

+ (void)setIsDevMode:(BOOL)isDevMode {
    [AppDelegate setIsDevMode:isDevMode];
}

+ (BOOL)isDevMode {
    return [AppDelegate isDevMode];
}

+ (void)setDevLogo:(FBShimmeringView *)sView WithLogo:(UIImage *)logo {
    return [AppDelegate setDevLogo:sView
                          WithLogo:logo];
}

+ (BOOL)haveAccessToken {
    return [AppDelegate haveAccessToken];
}

+ (void)setAccessToken:(NSString *)accessToken {
    return [AppDelegate setAccessToken:accessToken];
}

+ (NSString *)accessToken {
    return [AppDelegate accessToken];
}

+ (NSString *)accessTokenSHA1 {
    return [AppDelegate accessTokenSHA1];
    
}

+ (id)AppConfig:(NSString *)path {
    return [AppDelegate AppConfig:path];
}

+ (UIColor *)AppConfigColor:(NSString *)path {
    return [AppDelegate AppConfigColor:path];
}

+ (NSString *)AppConfigURL:(NSString *)path {
    return [AppDelegate AppConfigURL:path];
}

@end
