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

@end
