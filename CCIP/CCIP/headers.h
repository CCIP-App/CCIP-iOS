//
//  headers.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "NSObject+ValueForKeyPathWithIndexes.h"

#define nilCoalesce(v)              ((v != nil && ![v isKindOfClass:[NSNull class]] ? v : @""))
#define nilCoalesceDefault(v,d)     ((v != nil && ![v isKindOfClass:[NSNull class]] ? v : d))
#define stringCoalesceDefault(v,d)  ((v != nil && ![v isKindOfClass:[NSNull class]] && [v isKindOfClass:[NSString class]] && [v length] > 0 ? v : d))

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  Math Function
 */

#define NEAR_ZERO(A, B)             (MIN(ABS(A), ABS(B)) == ABS(A) ? A : B)
