//
//  Constants.m
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

#import "Constants.h"

#define STRINGIZE(x)                    #x
#define STRINGIZE2(x)                   STRINGIZE(x)
#define SOURCE_ROOT                     @ STRINGIZE2(SRCROOT)

@implementation Constants

#pragma mark - Defines
+ (NSString *)SourceRoot {
    return SOURCE_ROOT;
}

+ (NSString *)AppName {
    return APP_NAME;
}

@end
