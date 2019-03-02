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
+ (void)SendFIBEvent:(id)fib Event:(id)event;

+ (NSString *)WebToken:(id)patten useToken:(id)token;

+ (NSString *)DashlineViewId;

@end

NS_ASSUME_NONNULL_END
