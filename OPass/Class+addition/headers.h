//
//  headers.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#define STRINGIZE(x)                    #x
#define STRINGIZE2(x)                   STRINGIZE(x)
#define SOURCE_ROOT                     @ STRINGIZE2(SRC_ROOT)

#define __FIB(name, events)             ([Constants SendFib:name WithEvents:events Func:[NSString stringWithUTF8String:__func__] File:[NSString stringWithUTF8String:__FILE__] Line:__LINE__ Col:0])
#define SEND_FIB(name)                  (__FIB( name, nil ))
#define SEND_FIB_EVENT(nibName, events) (__FIB( nibName, events ))

#define nilCoalesce(v)              ((v != nil && ![v isKindOfClass:[NSNull class]] ? v : @""))
#define nilCoalesceDefault(v,d)     ((v != nil && ![v isKindOfClass:[NSNull class]] ? v : d))
//#define stringCoalesceDefault(v,d)  ((v != nil && ![v isKindOfClass:[NSNull class]] && [v isKindOfClass:[NSString class]] && [v length] > 0 ? v : d))

/*
 *  System Versioning Preprocessor Macros
 */

//#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
//#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  Math Function
 */

#define NEAR_ZERO(A, B)             (MIN(ABS(A), ABS(B)) == ABS(A) ? A : B)

/*
 *  Cache
 */

#define SCHEDULE_CACHE_CLEAR    (@"ClearScheduleContentCache")
#define SCHEDULE_CACHE_KEY      (@"ScheduleContentCache")
