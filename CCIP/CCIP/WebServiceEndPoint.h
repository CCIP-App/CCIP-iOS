//
//  WebServiceEndPoint.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#define __TIMEOUT_INTERVAL__    (15)
#define ONE_SIGNAL_APP_TOKEN    ([[AppDelegate AppConfig:@"ogToken"] stringValue])

#define STAFF_WEB_PATH          ([AppDelegate AppConfigURL:@"StaffWebPath"])
#define STAFF_WEB_BASE_URL      ([AppDelegate AppConfigURL:@"StaffWebPath"])
#define STAFF_BASE_DOMAIN       ([AppDelegate AppConfigURL:@"StaffBaseDomain"])
#define SPONSOR_WEB_PATH        ([AppDelegate AppConfigURL:@"SponsorWebPath"])
#define SPONSOR_WEB_BASE_URL    ([AppDelegate AppConfigURL:@"SponsorWebPath"])
#define PUZZLE_GAME_BASE_DOMAIN ([AppDelegate AppConfigURL:@"GameDomain"])

#define __API_HOST__            ([NSString stringWithFormat:@"https://%@/", __API_HOST_DOMAIN__])
#define CONF_BASE_URL           ([NSString stringWithFormat:@"https://%@/", CONF_BASE_DOMAIN])
#define STAFF_BASE_URL          ([NSString stringWithFormat:@"https://%@/", STAFF_BASE_DOMAIN])
#define PUZZLE_GAME_BASE_URL    ([NSString stringWithFormat:@"https://%@/", PUZZLE_GAME_BASE_DOMAIN])

#define CC_STATUS(token)        ([__API_HOST__ stringByAppendingFormat:@"status?token=%@", token])
#define CC_USE(token, scenario) ([__API_HOST__ stringByAppendingFormat:@"use/%@?token=%@", scenario, token])
#define CC_ANNOUNCEMENT         ([__API_HOST__ stringByAppendingFormat:@"announcement"])
#define CC_LANDING(token)       ([__API_HOST__ stringByAppendingFormat:@"landing?token=%@", token])

#define CONF_JSON_DATA(asset)   ([CONF_BASE_URL stringByAppendingFormat:@"2018/static/json/%@.json", asset])
#define SCHEDULES_DATA_URL      (CONF_JSON_DATA(@"submissions"))
#define SPONSOR_LIST_URL        (CONF_JSON_DATA(@"sponsor"))
#define STAFF_DATA_URL          (CONF_JSON_DATA(@"staff"))

#define STAFF_WEB_URL(token)    ([NSString stringWithFormat:@"https://%@", [STAFF_WEB_PATH stringByAppendingFormat:@"?mode=app&token=%@", token]])
#define SPONSOR_WEB_URL(token)  ([NSString stringWithFormat:@"https://%@", [SPONSOR_WEB_PATH stringByAppendingFormat:@"?mode=app&token=%@", token]])

//#define STAFF_DATA_URL          ([STAFF_BASE_URL stringByAppendingString:@"api/staffgroups/?format=json"])
#define STAFF_AVATAR(avatar)    ([avatar containsString:@"http"] ? [NSString stringWithFormat:@"%@&s=200", avatar] : [STAFF_BASE_URL stringByAppendingString:avatar])

#define PUZZLE_GAME_URL(token)  ([PUZZLE_GAME_BASE_URL stringByAppendingFormat:@"?mode=app&token=%@", token])

#define TELEGRAM_URL            ([AppDelegate AppConfigURL:@"tg_Chat"])
#define TELEGRAM_GROUP_URL      ([@"https://t.me/" stringByAppendingString:TELEGRAM_URL])
#define TELEGRAM_GROUP_URI      ([@"tg://resolve?domain=" stringByAppendingString:TELEGRAM_URL])

#define LOG_CHANNEL             ([AppDelegate AppConfigURL:@"IRC_Chnnel"])
#define LOG_BOT_URL             ([NSString stringWithFormat:@"https://ysitd.licson.net/channel/%@/today", LOG_CHANNEL])

// Assets

#define ASSETS_IMAGE(b, i)      ([UIImage imageNamed:i \
                                            inBundle:[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", b]]] \
                       compatibleWithTraitCollection:nil])

// Non API

#define GITHUB_REPO(repo)       ([NSString stringWithFormat:@"https://github.com/%@", repo])
#define GITHUB_AVATAR(user)     ([NSString stringWithFormat:@"https://avatars.githubusercontent.com/%@?s=86&v=3", user])
#define GRAVATAR_AVATAR(hash)   ([NSString stringWithFormat:@"https://www.gravatar.com/avatar/%@?s=86%@", hash, [hash length] > 0 ? @"&r=x" : @"&f=y&d=mm"])
